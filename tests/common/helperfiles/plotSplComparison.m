function plotSplComparison(testCase,frequency,actual,expected,tolerance,quantity,unit)
%PLOTSPLCOMPARISON Add a figure of the actual SPL against the expected SPL to the test report
%   plotSplComparison(testCase,frequency,actual,expected,tolerance) plots the actual and the expected sound pressure
%   level in [dB] over the frequencies in [Hz], as verifyEqual(actual,expected) compares them, and below it their
%   difference with the band of the tolerance in [dB]. The figure is logged with a FigureDiagnostic, also when the
%   test passes: MATLAB saves it as a .png and a .fig file, prints where, and shows it in an HTML report of the test
%   results (generateHTMLReport). The figure is invisible and is closed when the test ends.
%
%   plotSplComparison(testCase,frequency,actual,expected,tolerance,quantity,unit) also gives the name and the unit
%   of another quantity, for example "|Z|" and "Ohm": the y-axes are then labelled "|Z| [Ohm]" and
%   "Actual - expected [Ohm]", and the tolerance is in that unit. The defaults are "SPL" and "dB".

if nargin < 6
    quantity = "SPL";
    unit = "dB";
end

fig = figure(Visible="off");
testCase.addTeardown(@close,fig)
layout = tiledlayout(fig,2,1);
xRange = [min(frequency) max(frequency)];

ax = nexttile(layout);
semilogx(ax,frequency,expected,frequency,actual,"--",LineWidth=1.5)
xlim(ax,xRange)
grid(ax,"on")
ylabel(ax,quantity + " [" + unit + "]")
legend(ax,"Expected","Actual",Location="southeast")

ax = nexttile(layout);
difference = actual - expected;
semilogx(ax,frequency,difference,LineWidth=1.5)
yline(ax,[-tolerance tolerance],"r:",LineWidth=1.5)
xlim(ax,xRange)
ylim(ax,[-1 1]*max(2*tolerance,1.1*max(abs(difference))))
grid(ax,"on")
xlabel(ax,"Frequency [Hz]")
ylabel(ax,"Actual - expected [" + unit + "]")

testCase.log(matlab.automation.Verbosity.Terse,matlab.unittest.diagnostics.FigureDiagnostic(fig))
end
