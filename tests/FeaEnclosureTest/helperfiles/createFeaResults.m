%[text] # Create the FEA Results of FeaEnclosureTest
%[text] Creates the reference data of `FeaEnclosureTest` from the Workbench project in `fea`, next to this script: for each model the files `pRear.txt`, `pFront.txt` and `pMic.txt` in its own subfolder. Run it after a change of an FEA model, with Workbench closed, and commit the new text files. How it works is described in `tests\common\doc\ansysautomation\ansysautomationdoc.m`.
%%
%[text] ## Job
%[text:table]
%[text] | Subfolder | System folder | Display name in Workbench |
%[text] | --- | --- | --- |
%[text] | `full100l` | `SYS` | ClosedBox 100L |
%[text] | `quartersymmetry100l` | `SYS-3` | ClosedBox 100L Quarter symmetry |
%[text] | `full50l` | `SYS-2` | ClosedBox 50L |
%[text:table]
%[text] The system folder is the folder of the system in `AnsysFeaValidationFiles_files\dp0`. It need not match the name of the system in Workbench: the quarter-symmetry system is called `SYS 1` but has the folder `SYS-3`.
root = currentProject().RootFolder;
helperFolder = fullfile(root,"tests","FeaEnclosureTest","helperfiles");
job.WorkbenchFile = fullfile(helperFolder,"fea","AnsysFeaValidationFiles.wbpj");
job.Models = ["full100l","SYS"; "quartersymmetry100l","SYS-3"; "full50l","SYS-2"];
job.Selections = ["DiaphragmRear","pRear.txt"; "DiaphragmFront","pFront.txt"; "MicRadius","pMic.txt"];
job.OutFolder = helperFolder;
%%
%[text] ## Start in the background
%[text] Returns at once; the log is in `scratch`. Do not run `FeaEnclosureTest` meanwhile.
exportFeaPressureResults(job); %[output:6f2ebad4]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
%[output:6f2ebad4]
%   data: {"dataType":"text","outputData":{"text":"Started in the background; log: D:\\GIT\\JVsound Toolbox\\scratch\\exportFeaPressureResults.log\n","truncated":false}}
%---
