%CREATETESTREPORT Run all tests and open an HTML report with the figures of the tests
%   Removes the old report in tests\testreport, runs all tests in tests and its subfolders, writes the report with
%   generateHTMLReport to tests\testreport and opens it in the web browser of the system. The figures that the tests
%   log with plotSplComparison are in the report. git ignores tests\testreport.
%
%   The script is the shortcut Create test report in the Project toolstrip.

root = currentProject().RootFolder;
reportFolder = fullfile(root,"tests","testreport");
if isfolder(reportFolder)
    rmdir(reportFolder,"s")
end

% Without OutputDetail="None": that option also drops the logged figures from the results.
results = runtests(fullfile(root,"tests"),IncludeSubfolders=true);
generateHTMLReport(results,reportFolder);
web(fullfile(reportFolder,"index.html"),"-browser")
