%[text] # Create the FEA Results of FeaEnclosureTest
%[text] Creates the reference data of `FeaEnclosureTest` from the Workbench project in `fea`, next to this script: for each model the files `pRear.txt`, `pFront.txt` and `pMic.txt` in its own subfolder. Run it after a change of an FEA model, with Workbench closed, and commit the new text files. How it works is described in `tests\common\doc\ansysautomation\ansysautomationdoc.m`.
%%
%[text] ## Job
%[text:table]
%[text] | Subfolder | System | Display name in Workbench |
%[text] | --- | --- | --- |
%[text] | `full200l` | `SYS` | ClosedBox 200L |
%[text] | `quartersymmetry200l` | `SYS-1` | ClosedBox 200L QuarterSymmetry |
%[text] | `full50l` | `SYS-2` | ClosedBox 50L |
%[text] | `quartersymmetry50l` | `SYS-3` | ClosedBox 50L QuarterSymmetry |
%[text:table]
root = currentProject().RootFolder;
helperFolder = fullfile(root,"tests","FeaEnclosureTest","helperfiles");
job.WorkbenchFile = fullfile(helperFolder,"fea","AnsysFeaValidationFiles.wbpj");
job.Models = ["full200l","SYS"; "quartersymmetry200l","SYS-1"; "full50l","SYS-2"; "quartersymmetry50l","SYS-3"];
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
