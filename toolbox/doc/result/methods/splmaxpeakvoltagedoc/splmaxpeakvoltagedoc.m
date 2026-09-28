%[text] # splMaxPeakVoltage
%[text] Peak source voltage at which the sound pressure level reaches splMax
%[text] Class: result
%%
%[text] ## Syntax
%[text] ```matlabCodeExample
%[text] val = splMaxPeakVoltage(obj)
%[text] ```
%%
%[text] ## Description
%[text] `val = splMaxPeakVoltage(obj)` returns the peak voltage of a sine signal at each frequency that gives the maximum sound pressure level of `splMax`: the voltage that the amplifier must deliver.
%[text] The limits are the properties `ExcursionLimit` and `PowerLimit` of the `result` object. `lspsys.createResult` copies them from `Driver.ExcursionLimit` and `Driver.PowerLimit` (by default `"Xvar"` and `"Pnom"`). Set them on the result to use other limits without changing the driver: a name of a limit of the driver, or a number.
%%
%[text] ## Output Arguments
%[text] `val` — Peak source voltage $ \\hat{e}\_{g,max} $ in V, returned as a row vector over `Frequency`.
%%
%[text] ## Algorithms
%[text] - `ExcursionLimit`: `"Xmax"`, `"Xvar"`, `"Xlim"` or `"Xmech"`, or a peak excursion in m, one way. The excursion limits the RMS source voltage $ V\_x $ at which the peak excursion $ \\hat{x}\_d $ (`DiaphragmPeakExcursion`) reaches the limit $ X $; the model is linear, so the excursion scales with the source voltage $ e\_g $.
%[text] - `PowerLimit`: `"Pnom"`, `"Pcont"`, `"Paes1984"` or `"Paes2012"`, or a power in W. A power limit of the driver allows the RMS voltage $ V\_P = \\sqrt{P Z} $ with the impedance of its definition: $ Z = Z\_{min} $ for `Pnom`, `Pcont` and `Paes1984` (AES2-1984), $ Z = Z\_{nom} $ for `Paes2012` (AES2-2012). A power given as a number is the real power into the electrical impedance $ Z\_e $: $ V\_P = |Z\_e| \\sqrt{P / \\mathrm{Re}\\{Z\_e\\}} $. \
%[text]{"align":"center"} $ V\_x = e\_g \\frac{X}{\\hat{x}\_d} $
%[text]{"align":"center"} $ \\hat{e}\_{g,max} = \\sqrt{2} \\, \\min(V\_x, V\_P) $
%[text] $ V\_x $ and $ V\_P $ are RMS voltages; the peak of a sine signal is $ \\sqrt{2} $ times its RMS value.
%%
%[text] ## See Also
%[text] [`splMax`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxdoc','splmaxdoc.m'))) | [`splPowerLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splpowerlimiteddoc','splpowerlimiteddoc.m'))) | [`splExcursionLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splexcursionlimiteddoc','splexcursionlimiteddoc.m'))) | [`splMaxPeakVoltage`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxpeakvoltagedoc','splmaxpeakvoltagedoc.m'))) | [`result`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','resultdoc.m'))) | [`comp.Driver`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','driver','driverdoc.m')))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
