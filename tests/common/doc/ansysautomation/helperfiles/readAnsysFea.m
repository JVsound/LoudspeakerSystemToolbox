function files = readAnsysFea(workbenchFile,systemFolder,outFolder,selections)
%READANSYSFEA Export the pressures of a Workbench system for comp.FeaEnclosure, and solve the system if needed
%   files = readAnsysFea(workbenchFile,systemFolder,outFolder,selections) writes, for each named selection of system
%   systemFolder of the Workbench project workbenchFile (.wbpj), the pressure averaged over its nodes to a text file
%   in outFolder. systemFolder is the folder of the system in the project, for example "SYS" or "SYS-1". selections
%   is a string array with two columns: the named selection and the file name. files is a string array with the
%   full paths of the files, in the order of selections, ready for comp.FeaEnclosure.
%
%   The pressures are read from the result file of the system, <project>_files\dp0\<systemFolder>\MECH\file.rst,
%   which takes a few seconds. When that file does not exist, Workbench first updates the system, which solves it,
%   and saves the project; that takes minutes, and Workbench must be closed meanwhile. To solve a system again,
%   clear its generated data in Workbench and save the project.
%
%   The work is done by solveFea.py, next to this file, in a separate Python process: PyWorkbench solves and PyDPF
%   reads the result file. It uses the Python of pyenv, which must hold ansys-workbench-core and ansys-dpf-core.
%
%   Example:
%       selections = ["DiaphragmRear","pRear.txt"; "DiaphragmFront","pFront.txt"; "MicRadius","pMic.txt"];
%       files = readAnsysFea("AnsysFeaValidationFiles.wbpj","SYS-1","results",selections);
%
%   See also exportFeaPressureResults.
arguments
    workbenchFile (1,1) string {mustBeFile}
    systemFolder (1,1) string
    outFolder (1,1) string
    selections (:,2) string
end

python = pyenv().Executable;
if python == ""
    error("readAnsysFea:noPython","No Python is set: call pyenv(Version=...) with the PyAnsys environment first.")
end
script = fullfile(fileparts(mfilename("fullpath")),"solveFea.py");

% Python resolves relative paths from the current folder of MATLAB, which system passes on.
pairs = join(selections(:,1) + "=" + selections(:,2)," ");
command = sprintf('"%s" "%s" "%s" "%s" "%s" %s',python,script,workbenchFile,systemFolder,outFolder,pairs);
[status,output] = system(command);
disp(strtrim(output))
if status ~= 0
    error("readAnsysFea:failed","Ansys run failed with exit code %d.",status)
end
folderInfo = dir(outFolder);
files = fullfile(folderInfo(1).folder,selections(:,2));
end
