%[text] # Ansys Automation
%[text] **J.G. Vermond, JVsound**
%[text] How to run Ansys from MATLAB and export the FEA results that `comp.FeaEnclosure` reads: the setup of the computer, the working method and what was found along the way. The results serve as reference data for the tests. Status of 2026-09-28.
%[text:tableOfContents]{"heading":"Contents"}
%%
%[text] ## Overview
%[text] Ansys has no direct link with MATLAB. MATLAB starts a Python script as a separate process, the script uses PyAnsys, the Python libraries of Ansys, and writes the results to text files, and MATLAB reads those files:
%[text] 1. MATLAB calls `runAnsysFea` (solve and read) or `readAnsysFea` (read only).
%[text] 2. The Python script `solveFea.py` solves the Mechanical model with PyMechanical, or skips this for a model that is already solved.
%[text] 3. The script reads the pressure on the named selections from the result file with PyDPF and writes the three frequency responses (rear, front and microphone) to text files.
%[text] 4. MATLAB reads the files with `comp.FeaEnclosure.importAnsysPressureResults`. \
%[text] All files are in `helperfiles`, next to this page.
%%
%[text] ## Computer setup
%[text:table]
%[text] | Item | Value |
%[text] | --- | --- |
%[text] | Ansys | Ansys Student 2026 R1 (v261), `C:\\Program Files\\ANSYS Inc\\ANSYS Student\\v261` |
%[text] | Environment variable | `AWP_ROOT261` points to the Ansys folder |
%[text] | Size limit | 128k nodes/elements for structural and acoustic analyses (MAPDL), 1M cells for fluids, 4 cores |
%[text] | MATLAB | R2026a (26.1) |
%[text] | Graphics | NVIDIA RTX A3000 Laptop GPU and Intel UHD Graphics (hybrid) |
%[text] | Python | 3.13.15 from python.org (MATLAB R2026a supports 3.9 to 3.13, PyAnsys needs 3.10 or newer) |
%[text] | PyAnsys | `ansys-mechanical-core` 0.13.3 and `ansys-dpf-core` 0.16.1 in `C:\\Users\\Jeroen Vermond\\venvs\\pyansys` |
%[text:table]
%[text] **White panes in Mechanical.** With NVIDIA driver 595.95 the Scripting pane and the material selection of Mechanical stayed white. The panes did draw, but only showed while the window was resized. Updating the NVIDIA driver to 32.0.15.9716 (September 2026) solved it. `AnsysWBU.exe` is set to High performance in Windows Settings, System, Display, Graphics. The tips on the Ansys forum (`ANSYS_MECHANICAL_BROWSER`, toggling New Scripting UI, `JScriptReplacement`) did not help.
%%
%[text] ## Python environment
%[text] PyMechanical (`ansys-mechanical-core`) runs Mechanical as an object inside Python, without Workbench. PyDPF (`ansys-dpf-core`) reads the result file (`file.rst`) of the solver directly: no Mechanical window, full precision and units with the data. Both work with Ansys Student. Setup, done once:
%[text] 1. Install Python 3.13 (Windows installer, 64-bit) from python.org, with Add python.exe to PATH. The Python of the Microsoft Store does not work with MATLAB.
%[text] 2. Create a virtual environment outside the project: `python -m venv "C:\\Users\\Jeroen Vermond\\venvs\\pyansys"`.
%[text] 3. Install PyAnsys in it: `"C:\\Users\\Jeroen Vermond\\venvs\\pyansys\\Scripts\\python.exe" -m pip install ansys-mechanical-core ansys-dpf-core`.
%[text] 4. Tell MATLAB which Python to use. MATLAB keeps this setting for the next sessions. \
%[text] ```matlabCodeExample
%[text] pyenv(Version="C:\Users\Jeroen Vermond\venvs\pyansys\Scripts\python.exe",ExecutionMode="OutOfProcess");
%[text] ```
%[text] With a new Ansys release, update both packages (`pip install --upgrade ...`) and the version number `ANSYS_VERSION` in `solveFea.py`.
%%
%[text] ## Working method
%[text] Prepare and check the model in Mechanical (geometry, mesh, boundary conditions and named selections) and save the Workbench project. Then either:
%[text] - solve in Mechanical, save the project and call `readAnsysFea` on the result file, which takes about 1 s, or
%[text] - call `runAnsysFea` on the model file, which solves a copy and takes a bit over a minute. \
%[text] ```matlabCodeExample
%[text] addpath(helperFolder)   % folder with runAnsysFea.m, readAnsysFea.m and solveFea.py
%[text] selections = ["DiaphragmRear","pRear.txt"; "DiaphragmFront","pFront.txt"; "MicRadius","pMic.txt"];
%[text] files = readAnsysFea("AnsysFeaValidationFiles_files\dp0\SYS-1\MECH\file.rst","results",selections);
%[text] files = runAnsysFea("AnsysFeaValidationFiles_files\dp0\global\MECH\SYS-1.mechdb","results",selections);
%[text] data = comp.FeaEnclosure.importAnsysPressureResults(files(3));
%[text] ```
%[text] Where the files of a Workbench project are, with `SYS-<n>` the internal name of the system (system B, ClosedBox 200L QuarterSymmetry, is `SYS-1`; the name follows the order in which the systems were made, not the display name):
%[text] - Mechanical model: `<project>_files/dp0/global/MECH/SYS-<n>.mechdb`
%[text] - Result file: `<project>_files/dp0/SYS-<n>/MECH/file.rst` \
%[text] Mind:
%[text] - Workbench writes both files when the project is saved. After a change of the geometry, refresh the geometry and update the model in Workbench before saving.
%[text] - The script finds the named selections by name; capitals do not matter. A missing one stops the run with an error.
%[text] - The script solves only the first analysis of a model, and accepts only Pa or MPa as the unit of the pressure. \
%%
%[text] ## How it works
%[text] `runAnsysFea` runs `solveFea.py` as a separate Python process with `system`, with the Python of `pyenv`, and throws an error when the script fails. `readAnsysFea` checks that the file is a result file and calls `runAnsysFea`. The script:
%[text] 1. With a `.mechdb` file: copies the model to the output folder, opens the copy with PyMechanical, solves the first analysis and saves it. The model file itself is not changed.
%[text] 2. Starts a local DPF server of Ansys (from `AWP_ROOT261`) and opens the result file.
%[text] 3. Reads the complex pressure on the nodes of each named selection at all frequencies and averages the real and the imaginary part over the nodes.
%[text] 4. Writes one text file per named selection in the format of `importAnsysPressureResults`: Frequency (Hz), Amplitude (MPa), Phase Angle (deg), Real (MPa) and Imaginary (MPa), with 10 significant digits. \
%[text] ```matlabCodeExample
%[text] import ansys.mechanical.core as mech
%[text] app = mech.App(version=261)                  # Mechanical inside Python
%[text] app.open(mechdbFile)
%[text] analysis = app.DataModel.Project.Model.Analyses[0]
%[text] analysis.Solution.Solve(True)                # wait until the solve is done
%[text] app.save()                                   # before close, or the result folder is deleted
%[text] rstFile = analysis.ResultFileName
%[text] app.close()
%[text] ```
%[text] Why a separate process instead of `pyenv`:
%[text] - Mechanical can start only once in a Python process. A new process per run always starts clean.
%[text] - A crash of Ansys ends the Python process, not MATLAB. \
%%
%[text] ## What was found
%[text] - The frequency responses in Mechanical are of type `AcousticPressureFrequencyResponse`. In 2026 R1 this type has no `ExportToTextFile` and no `PlotData`, and the button Export to Text File is not recorded by the scripting recorder. A script inside Mechanical can only read the Tabular Data pane, which needs a Mechanical window and gives 5 significant digits. That is why the results are read from the result file with PyDPF.
%[text] - The named selections of Mechanical are in the result file in capitals (`DIAPHRAGMREAR`, `DIAPHRAGMFRONT`, `MICRADIUS`). `MICRADIUS` is a single node, the diaphragm selections have 16 nodes each.
%[text] - The plain mean over the nodes equals the frequency response of Mechanical with Spatial Resolution Use Average: the largest relative difference with the manual export of Mechanical is $ 4 \\cdot 10^{-5} $, which is the rounding of that export to 5 digits. Solving with PyMechanical gives the same result as solving in Workbench.
%[text] - The result file carries its unit system (NMM: mm, ton, N, s), so the unit of the pressure (MPa) comes with the data instead of being assumed.
%[text] - Starting Mechanical takes about 30 s and solving system B about 36 s. Reading the three responses takes about 1 s.
%[text] - Save the model before `app.close()`: without it Mechanical deletes the result folder when it closes. `save_as` moves the result folder to the new model name, so take `ResultFileName` after saving.
%[text] - Messages of earlier sessions are stored in the model and show up again in `Messages`.
%[text] - MATLAB cannot convert a read-only array of DPF to `double`; convert to a copy in Python first. \
%%
%[text] ## Open points
%[text] - Changing the geometry from Python needs an import of the geometry file into the model; this has not been tried. For now the model is prepared by hand in Workbench and Mechanical.
%[text] - `runAnsysFea.m`, `readAnsysFea.m` and `solveFea.py` are test versions in `helperfiles`; where they belong in the project has not been decided. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
