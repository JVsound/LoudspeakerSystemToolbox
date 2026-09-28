%[text] # splExcursionLimited
%[text] Sound pressure level that the excursion limit alone allows
%[text] Class: result
%%
%[text] ## Syntax
%[text] ```matlabCodeExample
%[text] val = splExcursionLimited(obj)
%[text] ```
%%
%[text] ## Description
%[text] `val = splExcursionLimited(obj)` returns the sound pressure level at each frequency, for a sine signal, at the voltage at which the peak excursion of the diaphragm reaches the excursion limit in `ExcursionLimit`. `splMax` is the lower of this level and `splPowerLimited`.
%[text] The limits are the properties `ExcursionLimit` and `PowerLimit` of the `result` object. `lspsys.createResult` copies them from `Driver.ExcursionLimit` and `Driver.PowerLimit` (by default `"Xvar"` and `"Pnom"`). Set them on the result to use other limits without changing the driver: a name of a limit of the driver, or a number.
%%
%[text] ## Output Arguments
%[text] `val` — Sound pressure level in dB that the excursion limit allows, returned as a row vector over `Frequency`.
%%
%[text] ## Algorithms
%[text] - `ExcursionLimit`: `"Xmax"`, `"Xvar"`, `"Xlim"` or `"Xmech"`, or a peak excursion in m, one way. The excursion limits the RMS source voltage $ V\_x $ at which the peak excursion $ \\hat{x}\_d $ (`DiaphragmPeakExcursion`) reaches the limit $ X $; the model is linear, so the excursion scales with the source voltage $ e\_g $.
%[text]{"align":"center"} $ V\_x = e\_g \\frac{X}{\\hat{x}\_d} $
%[text]{"align":"center"} $ \\mathrm{SPL}(V) = \\mathrm{SPL} + 20 \\log\_{10} \\frac{V}{e\_g} $
%[text] with $ V = V\_x $. A chosen limit of 0 (not given in the driver) gives an error.
%%
%[text] ## See Also
%[text] [`splMax`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxdoc','splmaxdoc.m'))) | [`splPowerLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splpowerlimiteddoc','splpowerlimiteddoc.m'))) | [`splExcursionLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splexcursionlimiteddoc','splexcursionlimiteddoc.m'))) | [`splMaxPeakVoltage`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxpeakvoltagedoc','splmaxpeakvoltagedoc.m'))) | [`result`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','resultdoc.m'))) | [`comp.Driver`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','driver','driverdoc.m')))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
