function plan = buildfile
%BUILDFILE Build plan of the Loudspeaker System Toolbox
%   buildtool reads this file when you type buildtool in the Command Window, from the project folder. A build
%   plan is a list of tasks (steps) and the order in which they run.
%
%   buildtool           runs the default task: test
%   buildtool package   runs test first and, only if the test passes, packages the toolbox
%   buildtool -tasks    lists the tasks with their description

% Create the plan. localfunctions passes the functions at the bottom of this file, so that each function
% whose name ends in Task becomes a task: packageTask becomes the task "package".
plan = buildplan(localfunctions);

% Task "test": a built-in task of MATLAB that runs all tests in the folder tests and its subfolders, like
% runtests("tests",IncludeSubfolders=true).
% The build stops when a test fails.
plan("test") = matlab.buildtool.tasks.TestTask("tests");

% The task "package" depends on "test": buildtool always runs the test first, and packages only if it passes.
plan("package").Dependencies = "test";

% Task that runs when you type buildtool without a task name.
plan.DefaultTasks = "test";
end

function packageTask(~)
% Package the toolbox into an installable .mltbx file
% (buildtool shows the first comment line of a task function as its description in buildtool -tasks.)

% Options of the toolbox: the folder to package and the UUID. The UUID identifies the toolbox, so that MATLAB
% installs a new version as an update of the old one: never change it.
opts = matlab.addons.toolbox.ToolboxOptions("toolbox","98dea6eb-1812-45cf-ba18-258adb322641");

% Name that users see in the Add-On Manager of MATLAB.
opts.ToolboxName = "Loudspeaker System Toolbox";

% Version of the toolbox: raise it for every version that you give to others.
opts.ToolboxVersion = "0.1.0";

% Live script that MATLAB opens after the installation.
opts.ToolboxGettingStartedGuide = "toolbox/doc/GettingStarted.m";

% File to create; the folder release is not in git (see .gitignore).
opts.OutputFile = "release/LoudspeakerSystemToolbox.mltbx";

% Create the .mltbx file with these options.
matlab.addons.toolbox.packageToolbox(opts);
end
