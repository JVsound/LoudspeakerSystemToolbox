function exportFeaPressureResults(job)
%EXPORTFEAPRESSURERESULTS Export the pressures of several Workbench systems to text files, in a second MATLAB
%   exportFeaPressureResults(job) calls readAnsysFea for each system in job.Models, which solves the system when
%   it has no result file yet, and writes the text files of each system to its own subfolder of job.OutFolder.
%   job is a structure with the fields:
%   - WorkbenchFile: the Workbench project (.wbpj)
%   - Models: string array with two columns: the subfolder of job.OutFolder and the folder of the system in the
%     project, for example ["full200l","SYS"; "quartersymmetry200l","SYS-1"]
%   - Selections: string array with two columns: the named selection and the file name, for example
%     ["DiaphragmRear","pRear.txt"; "MicRadius","pMic.txt"]
%   - OutFolder: the folder that gets the subfolders
%
%   The work always runs in a second MATLAB without a window, so MATLAB stays free: the function saves job to
%   scratch\exportFeaPressureResults.mat of the project, starts the second MATLAB and returns at once. The second
%   MATLAB opens the project and calls this function again with the saved job; batchStartupOptionUsed is true there,
%   so it does the work and closes when it is done. It shows its output in a console window of its own and writes
%   it to scratch\exportFeaPressureResults.log, with a line per finished model. Starting it takes 10 to 20 s.
%
%   See also readAnsysFea.
arguments
    job (1,1) struct
end

if batchStartupOptionUsed
    % In the second MATLAB: do the work.
    for iModel = 1:height(job.Models)
        outFolder = fullfile(job.OutFolder,job.Models(iModel,1));
        readAnsysFea(job.WorkbenchFile,job.Models(iModel,2),outFolder,job.Selections);
        disp("Done: " + job.Models(iModel,1))
    end
else
    % In the MATLAB of the user: save the job and start the second MATLAB. The & at the end makes system return at
    % once; -batch runs the statement and closes MATLAB afterwards.
    root = currentProject().RootFolder;
    jobFile = fullfile(root,"scratch","exportFeaPressureResults.mat");
    logFile = fullfile(root,"scratch","exportFeaPressureResults.log");
    if ~isfolder(fileparts(jobFile))
        mkdir(fileparts(jobFile))
    end
    save(jobFile,"-struct","job")
    command = sprintf('"%s" -logfile "%s" -batch "openProject(''%s''); exportFeaPressureResults(load(''%s''))" &', ...
        fullfile(matlabroot,"bin","matlab"),logFile,root,jobFile);
    system(command);
    disp("Started in the background; log: " + logFile)
end
end
