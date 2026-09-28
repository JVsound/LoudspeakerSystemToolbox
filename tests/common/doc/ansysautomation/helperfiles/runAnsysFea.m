function files = runAnsysFea(modelFile,outFolder,selections)
%RUNANSYSFEA Solve an Ansys Mechanical model and export the pressures for comp.FeaEnclosure
%   files = runAnsysFea(modelFile,outFolder,selections) solves the Mechanical model modelFile (.mechdb) with Ansys
%   and writes, for each named selection, the pressure averaged over its nodes to a text file in outFolder.
%   selections is a string array with two columns: the named selection and the file name. files is a string array
%   with the full paths of the files, in the order of selections, ready for comp.FeaEnclosure.
%
%   When modelFile is a result file (.rst) of a model that is already solved, the solve is skipped and the
%   pressures are only read; readAnsysFea does this.
%
%   The work is done by solveFea.py, next to this file, in a separate Python process: PyMechanical solves and
%   PyDPF reads the result file. It uses the Python of pyenv, which must hold ansys-mechanical-core and
%   ansys-dpf-core. The model file itself is not changed; a copy is solved in outFolder.
%
%   Example:
%       selections = ["DiaphragmRear","pRear.txt"; "DiaphragmFront","pFront.txt"; "MicRadius","pMic.txt"];
%       files = runAnsysFea("ClosedBoxQuarter.mechdb","results",selections);
%
%   See also readAnsysFea.
arguments
    modelFile (1,1) string {mustBeFile}
    outFolder (1,1) string
    selections (:,2) string
end

[~,~,extension] = fileparts(modelFile);
if ~any(strcmpi(extension,[".mechdb",".rst"]))
    error("runAnsysFea:fileType","The model file must be a .mechdb or a .rst file, not ""%s"".",modelFile)
end

python = pyenv().Executable;
if python == ""
    error("runAnsysFea:noPython","No Python is set: call pyenv(Version=...) with the PyAnsys environment first.")
end
script = fullfile(fileparts(which("runAnsysFea")),"solveFea.py");

% Python resolves relative paths from the current folder of MATLAB, which system passes on.
pairs = join(selections(:,1) + "=" + selections(:,2)," ");
command = sprintf('"%s" "%s" "%s" "%s" %s',python,script,modelFile,outFolder,pairs);
[status,output] = system(command);
disp(strtrim(output))
if status ~= 0
    error("runAnsysFea:failed","Ansys run failed with exit code %d.",status)
end
folderInfo = dir(outFolder);
files = fullfile(folderInfo(1).folder,selections(:,2));
end
