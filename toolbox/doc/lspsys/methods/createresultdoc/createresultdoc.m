%[text] # createResult
%[text] Solve the loudspeaker system and return its results
%[text] Class: lspsys
%%
%[text] ## Syntax
%[text] ```matlabCodeExample
%[text] val = createResult(obj)
%[text] ```
%%
%[text] ## Description
%[text] `val = createResult(obj)` solves the two-port network of the `lspsys` object `obj` with `solve2PortNetwork` and returns a `result` object with the response over `Frequency`.
%%
%[text] ## Output Arguments
%[text] `val` — Results of the calculation, returned as a [`result`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','resultdoc.m'))) object. `createResult` sets these properties:
%[text:table]
%[text] | Property | Value |
%[text] | --- | --- |
%[text] | `Frequency` | `obj.Frequency` |
%[text] | `SourceVoltage` | `obj.SourceVoltage` at every frequency |
%[text] | `SourceCurrent`, `DiaphragmVolumeVelocity`, `RadiatedVolumeVelocity` | the solution of `solve2PortNetwork` |
%[text] | `MicTransfer` | `obj.Enclosure.micTransfer`, the transfer to the microphone; empty for most enclosures |
%[text] | `Driver` | a copy of `obj.Enclosure.Driver`, whose limits `result.splMax` uses |
%[text] | `ExcursionLimit`, `PowerLimit` | `Driver.ExcursionLimit` and `Driver.PowerLimit`, the limits for `result.splMax`; you can change them on the result |
%[text:table]
%[text] The electrical impedance, the pressure and the sound pressure level are dependent properties of the `result` object, calculated from these values when they are read.
%%
%[text] ## See Also
%[text] [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) | [`lspsys`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','lspsysdoc.m'))) | [`result`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','result','resultdoc.m')))

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
