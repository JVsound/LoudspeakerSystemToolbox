function files = readAnsysFea(rstFile,outFolder,selections)
%READANSYSFEA Export the pressures of a solved Ansys model for comp.FeaEnclosure
%   files = readAnsysFea(rstFile,outFolder,selections) reads the result file rstFile of a model that is already
%   solved in Mechanical and writes, for each named selection, the pressure averaged over its nodes to a text file
%   in outFolder. selections is a string array with two columns: the named selection and the file name. files is a
%   string array with the full paths of the files, in the order of selections, ready for comp.FeaEnclosure.
%
%   In a Workbench project the result file of a system is <project>_files\dp0\SYS-<n>\MECH\file.rst. Save the
%   project after solving, so that the file is up to date. Only PyDPF is used, so this takes a few seconds.
%
%   Example:
%       selections = ["DiaphragmRear","pRear.txt"; "DiaphragmFront","pFront.txt"; "MicRadius","pMic.txt"];
%       files = readAnsysFea("AnsysFeaValidationFiles_files\dp0\SYS-1\MECH\file.rst","results",selections);
%
%   See also runAnsysFea.
arguments
    rstFile (1,1) string {mustBeFile}
    outFolder (1,1) string
    selections (:,2) string
end

[~,~,extension] = fileparts(rstFile);
if ~strcmpi(extension,".rst")
    error("readAnsysFea:fileType","The result file must be a .rst file, not ""%s"".",rstFile)
end
files = runAnsysFea(rstFile,outFolder,selections);
end
