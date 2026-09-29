function logLevelComparison(testCase,frequency,actual,expected,tolerance)
%LOGLEVELCOMPARISON Add a figure of the model level against the reference level to the test report
%   logLevelComparison(testCase,frequency,actual,expected,tolerance) plots the level of the model (actual) and of
%   the reference (expected) in [dB] over the frequencies in [Hz], and below it their difference with the band of
%   the tolerance in [dB]. The figure is logged with a FigureDiagnostic, also when the test passes: MATLAB saves it
%   as a .png and a .fig file, prints where, and shows it in an HTML report of the test results
%   (generateHTMLReport). The figure is invisible and is closed when the test ends.

fig = figure(Visible="off");
testCase.addTeardown(@close,fig)
layout = tiledlayout(fig,2,1);
xRange = [min(frequency) max(frequency)];

ax = nexttile(layout);
semilogx(ax,frequency,expected,frequency,actual,"--",LineWidth=1.5)
xlim(ax,xRange)
grid(ax,"on")
ylabel(ax,"Level [dB]")
legend(ax,"Reference","Model",Location="southeast")

ax = nexttile(layout);
difference = actual - expected;
semilogx(ax,frequency,difference,LineWidth=1.5)
yline(ax,[-tolerance tolerance],"r:",LineWidth=1.5)
xlim(ax,xRange)
ylim(ax,[-1 1]*max(2*tolerance,1.1*max(abs(difference))))
grid(ax,"on")
xlabel(ax,"Frequency [Hz]")
ylabel(ax,"Model - reference [dB]")

testCase.log(matlab.automation.Verbosity.Terse,matlab.unittest.diagnostics.FigureDiagnostic(fig))
end
