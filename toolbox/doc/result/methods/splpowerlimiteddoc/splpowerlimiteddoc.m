%[text] # splPowerLimited
%[text] Sound pressure level that the power limit alone allows
%[text] Class: result
%%
%[text] ## Syntax
%[text] ```matlabCodeExample
%[text] val = splPowerLimited(obj)
%[text] ```
%%
%[text] ## Description
%[text] `val = splPowerLimited(obj)` returns the sound pressure level at each frequency, for a sine signal, at the voltage that the power limit in `PowerLimit` allows. `splMax` is the lower of this level and `splExcursionLimited`.
%[text] The limits are the properties `ExcursionLimit` and `PowerLimit` of the `result` object. `lspsys.createResult` copies them from `Driver.ExcursionLimit` and `Driver.PowerLimit` (by default `"Xvar"` and `"Pnom"`). Set them on the result to use other limits without changing the driver: a name of a limit of the driver, or a number.
%%
%[text] ## Output Arguments
%[text] `val` — Sound pressure level in dB that the power limit allows, returned as a row vector over `Frequency`.
%%
%[text] ## Algorithms
%[text] - `PowerLimit`: `"Pnom"`, `"Pcont"`, `"Paes1984"` or `"Paes2012"`, or a power in W. A power limit of the driver allows the RMS voltage $ V\_P = \\sqrt{P Z} $ with the impedance of its definition: $ Z = Z\_{min} $ for `Pnom`, `Pcont` and `Paes1984` (AES2-1984), $ Z = Z\_{nom} $ for `Paes2012` (AES2-2012). A power given as a number is the real power into the electrical impedance $ Z\_e $: $ V\_P = |Z\_e| \\sqrt{P / \\mathrm{Re}\\{Z\_e\\}} $. \
%[text]{"align":"center"} $ \\mathrm{SPL}(V) = \\mathrm{SPL} + 20 \\log\_{10} \\frac{V}{e\_g} $
%[text] with $ V = V\_P $. A chosen limit or impedance of 0 (not given in the driver) gives an error.
%%
%[text] ## See Also
%[text] [`splMax`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxdoc','splmaxdoc.m'))) | [`splPowerLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splpowerlimiteddoc','splpowerlimiteddoc.m'))) | [`splExcursionLimited`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splexcursionlimiteddoc','splexcursionlimiteddoc.m'))) | [`splMaxPeakVoltage`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','methods','splmaxpeakvoltagedoc','splmaxpeakvoltagedoc.m'))) | [`result`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','resultdoc.m'))) | [`comp.Driver`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','driver','driverdoc.m')))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
