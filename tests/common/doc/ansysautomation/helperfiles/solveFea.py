"""Export pressure frequency responses of a Workbench system for comp.FeaEnclosure, and solve the system if needed.

Usage:
    python solveFea.py <wbpj file> <system folder> <output folder> <named selection>=<file name> [...]

The system folder is the folder of the system in the Workbench project, for example SYS or SYS-1. When the system has
no result file yet (<project>_files/dp0/<system folder>/MECH/file.rst), PyWorkbench starts Workbench without a window,
updates the system, which solves it, and saves the project. Then the pressure on the nodes of each named selection is
read from the result file with PyDPF, averaged over the nodes and written to a tab-separated file with the columns
Frequency (Hz), Amplitude (MPa), Phase Angle (deg), Real (MPa) and Imaginary (MPa), the format of
comp.FeaEnclosure.importAnsysPressureResults. Workbench must be closed while a system is solved. Exit code 0 means
success.
"""
# The text between the triple quotes above is the docstring of this file: like the help text of a MATLAB file.
# Python prints it with help(), and main() below prints it when the arguments are missing.

# --- Imports ----------------------------------------------------------------------------------------------------------
# Python has few built-in functions; everything else comes from modules that you import first. MATLAB has everything
# on the path, Python needs an import per module.
import os    # operating system: paths, folders, environment variables (like fullfile, isfile, getenv in MATLAB)
import re    # regular expressions: search patterns in text (like regexp in MATLAB)
import sys   # the Python process itself: command line arguments (sys.argv) and the exit code (sys.exit)
import time  # clock: time.time() gives the time in seconds, used like tic/toc

import numpy as np                  # NumPy: arrays and math like in MATLAB; "as np" gives it the short name np
from ansys.dpf import core as dpf   # PyDPF: reads Ansys result files; available as dpf

# --- Constants --------------------------------------------------------------------------------------------------------
# Names in capitals are constants by convention; Python does not enforce it.
ANSYS_VERSION = 261   # Ansys 2026 R1; change this with a new Ansys release
# A dictionary maps keys to values, like a MATLAB dictionary or a struct with the unit as field name.
# It gives the factor to convert a pressure in the unit of the result file to MPa.
PRESSURE_TO_MPA = {"MPa": 1.0, "Pa": 1e-6}

# Workbench script that updates one system and saves the project. It runs inside Workbench (IronPython, the language
# of a Workbench journal), not in this Python. PROJECT_PATH and SYSTEM_NAME are filled in before it is sent.
UPDATE_SCRIPT = r'''
Open(FilePath="PROJECT_PATH")
system = GetSystem(Name="SYSTEM_NAME")
system.Update(AllDependencies=True)
Save(Overwrite=True)
'''


# --- Functions --------------------------------------------------------------------------------------------------------
# "def name(arguments):" starts a function. Python has no "end": the indented lines below belong to the function,
# so the indentation is part of the syntax. The same holds for if, for, try and with.

def findSystemName(workbenchFile, systemFolder):
    """Return the name of the system in the Workbench project that has the folder systemFolder."""
    # The name of a system ("SYS 1") and its folder ("SYS-3") need not match: Workbench keeps the folder when systems
    # are removed or changed. The .wbpj file holds both, per system, in an <Object> element: the name in
    # <object-name> and the folder in "UniqueSystemDirectoryName" in <member-data>.
    with open(workbenchFile, encoding="utf-8") as file:     # read the whole project file as text
        text = file.read()
    # re.findall returns, for each match, the two parts between parentheses: the name and the folder. [^<]* means any
    # characters except "<", also line ends, so the search stays inside one <object-name> and one <member-data>.
    pattern = (r'<object-name valType="String">([^<]*)</object-name>\s*<member-data[^>]*>[^<]*?'
               r'"UniqueSystemDirectoryName": "([^"]*)"')
    for name, folder in re.findall(pattern, text):
        if folder == systemFolder:
            return name
    raise ValueError("No system with the folder %s in %s" % (systemFolder, workbenchFile))


def solve(workbenchFile, systemFolder, rstFile):
    """Update one system of the Workbench project with PyWorkbench, which solves it, and save the project."""
    # Imported here and not at the top: reading a result file that exists already does not need PyWorkbench.
    from ansys.workbench.core import launch_workbench
    systemName = findSystemName(workbenchFile, systemFolder)    # for example "SYS 1" for the folder "SYS-3"
    # Workbench wants forward slashes in the path; .replace swaps them, like strrep in MATLAB.
    script = UPDATE_SCRIPT.replace("PROJECT_PATH", workbenchFile.replace("\\", "/")).replace("SYSTEM_NAME", systemName)
    t0 = time.time()                                            # like tic: remember the start time
    wb = launch_workbench(show_gui=False, version=str(ANSYS_VERSION))   # Workbench without a window (about 20 s)
    # try/finally: the lines under finally always run, also when an error occurs in the try block. So Workbench is
    # always closed. In MATLAB you would use try/catch or onCleanup for this.
    try:
        wb.run_script_string(script)                            # open, update (solve) and save, inside Workbench
    finally:
        wb.exit()                                               # close Workbench
    # Check the result. "not" is ~ in MATLAB.
    if not os.path.isfile(rstFile):
        # raise throws an error, like error() in MATLAB. "%s" in the text is filled in with the values after "%",
        # like sprintf in MATLAB.
        raise RuntimeError("Solve of %s failed: no result file %s" % (systemFolder, rstFile))
    print("Solved %s in %.0f s: %s" % (systemFolder, time.time() - t0, rstFile))   # time.time() - t0 is like toc


def exportPressure(rstFile, outDir, selections):
    """Write the node-averaged pressure of each named selection to a text file."""
    # Start a DPF server: a separate program of Ansys that does the reading. os.environ is a dictionary with the
    # environment variables; "AWP_ROOT%d" % 261 gives "AWP_ROOT261", the Ansys folder. as_global=False keeps this
    # server for this function only.
    server = dpf.start_local_server(ansys_path=os.environ["AWP_ROOT%d" % ANSYS_VERSION], as_global=False)
    model = dpf.Model(rstFile, server=server)          # open the result file
    # The frequencies of all solved steps. np.array(..., copy=True) makes a normal array of it, because MATLAB can
    # not convert the read-only array of DPF.
    freq = np.array(model.metadata.time_freq_support.time_frequencies.data, dtype=float, copy=True)
    nFreq = len(freq)                                   # len() is numel() for a list or a 1-D array
    # selections is a list of pairs like ["MicRadius", "pMic.txt"]. The for loop takes one pair per turn and unpacks
    # it into the two names.
    for namedSelection, fileName in selections:
        # Read the pressure on the nodes of the named selection, at all frequencies. The result file holds the names
        # in capitals, so .upper() makes the name capitals too. .eval() does the actual reading. fc is a "fields
        # container": a list of fields, one per frequency and per part (real or imaginary).
        fc = model.results.pressure.on_all_time_freqs.on_named_selection(namedSelection.upper()).eval()
        unit = fc[0].unit                               # unit of the first field, for example "MPa"
        # "not in" checks whether the unit is a key of the dictionary.
        if unit not in PRESSURE_TO_MPA:
            raise ValueError("Unknown pressure unit %s of %s: use a unit system with Pa or MPa"
                             % (unit, namedSelection))
        scale = PRESSURE_TO_MPA[unit]                   # conversion factor to MPa
        # Pre-allocate a complex array, like zeros(1,nFreq) in MATLAB.
        p = np.zeros(nFreq, dtype=complex)
        # range(nFreq) gives 0, 1, ..., nFreq-1: like 0:nFreq-1 in MATLAB.
        for i in range(nFreq):
            # DPF numbers the frequencies from 1: "time" is the step number, "complex" 0 is the real part and 1 the
            # imaginary part. .data holds the value on each node; np.mean averages over the nodes.
            real = np.mean(fc.get_field({"time": i + 1, "complex": 0}).data)
            imag = np.mean(fc.get_field({"time": i + 1, "complex": 1}).data)
            p[i] = scale*(real + 1j*imag)               # 1j is the imaginary unit, like 1i in MATLAB
        # Put the five columns next to each other, like [freq(:), abs(p(:)), ...] in MATLAB. np.angle gives the
        # angle in radians; np.degrees converts it to degrees.
        data = np.column_stack((freq, np.abs(p), np.degrees(np.angle(p)), p.real, p.imag))
        # Write the table as text: 10 significant digits ("%.10g"), columns separated by a tab ("\t"), one header
        # line. comments="" stops NumPy from putting "#" before the header. os.path.join is fullfile.
        np.savetxt(os.path.join(outDir, fileName), data, fmt="%.10g", delimiter="\t", comments="",
                   header="Frequency (Hz)\tAmplitude (MPa)\tPhase Angle (deg)\tReal (MPa)\tImaginary (MPa)")
        # Report what was written: the number of nodes is the length of the list of node numbers.
        print("Exported %s (%d nodes) to %s" % (namedSelection, len(fc[0].scoping.ids), fileName))


def main(args):
    """Run the script with the command line arguments args; return the exit code."""
    # args is a list of texts: the words after "python solveFea.py" on the command line.
    if len(args) < 4:
        print(__doc__)                                  # too few arguments: print the usage text at the top
        return 2
    # args[0] is the first argument, args[1] the second. os.path.abspath makes a full path of a relative one.
    workbenchFile, systemFolder, outDir = os.path.abspath(args[0]), args[1], os.path.abspath(args[2])
    # args[3:] is the list from the fourth argument to the end, like args(4:end) in MATLAB. The expression in square
    # brackets is a "list comprehension": a compact for loop that builds a list. It splits each "name=file" at the
    # first "=" into the pair [name, file].
    selections = [a.split("=", 1) for a in args[3:]]
    # The result file of the system: <project>_files/dp0/<system folder>/MECH/file.rst. os.path.splitext removes the
    # extension .wbpj, like fileparts in MATLAB.
    rstFile = os.path.join(os.path.splitext(workbenchFile)[0] + "_files", "dp0", systemFolder, "MECH", "file.rst")
    if not os.path.isfile(rstFile):                     # no result yet: solve the system in Workbench first
        solve(workbenchFile, systemFolder, rstFile)
    os.makedirs(outDir, exist_ok=True)                  # make the output folder; no error if it exists already
    exportPressure(rstFile, outDir, selections)
    return 0                                            # exit code 0: success


# --- Start ------------------------------------------------------------------------------------------------------------
# __name__ is "__main__" when this file is run as a script (python solveFea.py ...), and not when another script
# imports it. So the lines below only run when the file is started as a program.
if __name__ == "__main__":
    try:
        # sys.argv is the list of command line words; sys.argv[0] is the name of this script, so [1:] takes the rest.
        # sys.exit ends Python with the exit code that main returns; readAnsysFea reads it as status.
        sys.exit(main(sys.argv[1:]))
    except Exception as err:
        # Any error ends up here: print it to the error output and end with exit code 1, so that readAnsysFea
        # throws an error in MATLAB.
        print("Error: %s" % err, file=sys.stderr)
        sys.exit(1)
