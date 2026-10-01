%[text] # Symbols
%[text] **J.G. Vermond, JVsound**
%[text] Every symbol used in the Loudspeaker System Toolbox, alphabetically, with its unit. The first table lists the quantities with the property or method that holds them; the second table lists the elements and port quantities of the equivalent circuits. New here? Start with [Getting Started](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','GettingStarted.m'))); for links to the class documentation, see the [documentation overview](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','overview.m'))).
%%
%[text] ## Quantities
%[text:table]{"columnWidths":[80,80,-1]}
%[text] | Symbol | Unit | Property |
%[text] | --- | --- | --- |
%[text] | $ Bl $ | Tm | `Bl` |
%[text] | $ c $ | m/s | `SpeedOfSound` |
%[text] | $ C\_{ms} $ | m/N | `Cms` |
%[text] | $ e\_g $ | V (RMS) | `SourceVoltage` |
%[text] | $ \\hat{e}\_{g,max} $ | V (peak) | `splMaxPeakVoltage` |
%[text] | $ f $ | Hz | `Frequency` |
%[text] | $ f\_s $ | Hz | `Fs` |
%[text] | $ H\_{mic} $ | Pa.s/m3 | `MicTransfer`, `micTransfer` |
%[text] | $ i\_g $ | A | `SourceCurrent` |
%[text] | $ k $ | rad/m | `WaveNumber` |
%[text] | $ \\lambda $ | m | `Wavelength` |
%[text] | $ L\_e $ | H | `Le` |
%[text] | $ M\_{md} $ | kg | `Mmd` |
%[text] | $ M\_{mi} $ | kg | `Mmi` |
%[text] | $ M\_{ms} $ | kg | `Mms` |
%[text] | $ \\omega $ | rad/s | `AngularFrequency` |
%[text] | $ \\Omega $ | sr | `RadiationAngle` |
%[text] | $ p $ | Pa | `Pressure` |
%[text] | $ p\_0 $ | Pa | `ReferencePressure` |
%[text] | $ P\_{AES,1984} $ | W | `Paes1984` |
%[text] | $ P\_{AES,2012} $ | W | `Paes2012` |
%[text] | $ P\_{cont} $ | W | `Pcont` |
%[text] | $ P\_{nom} $ | W | `Pnom` |
%[text] | $ Q\_{es} $ | \- | `Qes` |
%[text] | $ Q\_{ms} $ | \- | `Qms` |
%[text] | $ Q\_{ts} $ | \- | `Qts` |
%[text] | $ r\_d $ | m | `DiaphragmRadius` |
%[text] | $ R\_e $ | Ohm | `Re` |
%[text] | $ \\rho $ | kg/m3 | `AirDensity` |
%[text] | $ r\_{mic} $ | m | `MicRadius` |
%[text] | $ R\_{ms} $ | Ns/m | `Rms` |
%[text] | $ S\_d $ | m2 | `Sd` |
%[text] | $ \\mathrm{SPL} $ | dB | `SoundPressureLevel` |
%[text] | $ \\mathrm{SPL}\_{max} $ | dB | `splMax` |
%[text] | $ U\_d $ | m3/s | `DiaphragmVolumeVelocity` |
%[text] | $ U\_{rad} $ | m3/s | `RadiatedVolumeVelocity` |
%[text] | $ V\_{as} $ | m3 | `Vas` |
%[text] | $ V\_r $ | m3 | `RearVolume` (the literature writes $ V\_b $) |
%[text] | $ X\_{lim} $ | m | `Xlim` |
%[text] | $ X\_{max} $ | m | `Xmax` |
%[text] | $ X\_{mech} $ | m | `Xmech` |
%[text] | $ X\_{var} $ | m | `Xvar` |
%[text] | $ x\_d $ | m (RMS) | `DiaphragmExcursion` |
%[text] | $ \\hat{x}\_d $ | m | `DiaphragmPeakExcursion` |
%[text] | $ Z\_{a,f} $ | Pa.s/m3 | `zaFront` |
%[text] | $ Z\_{a,r} $ | Pa.s/m3 | `zaRear` |
%[text] | $ Z\_e $ | Ohm | `ElectricalImpedance` |
%[text] | $ Z\_{eb} $ | Ohm | `zeb` |
%[text] | $ Z\_m $ | Ns/m | `zm` |
%[text] | $ Z\_{min} $ | Ohm | `Zmin` |
%[text] | $ Z\_{nom} $ | Ohm | `Znom` |
%[text:table]
%%
%[text] ## Circuit elements
%[text] Symbols of the elements and the port quantities in the equivalent circuits. They are not held by one property: the diagram on the page in the last column shows where they sit. When a circuit holds more elements of the same kind, they are numbered, for example $ C\_{a1} $ and $ C\_{a2} $.
%[text:table]{"columnWidths":[80,80,-1,-1]}
%[text] | Symbol | Unit | Meaning | Diagram |
%[text] | --- | --- | --- | --- |
%[text] | $ C\_a $ | m5/N | Acoustic compliance of a closed volume | [`comp.ClosedBox`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','closedbox','closedboxdoc.m'))) |
%[text] | $ M\_a $ | kg/m4 | Acoustic mass of the air that moves with the diaphragm | [`comp.ClosedBox`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','closedbox','closedboxdoc.m'))) |
%[text] | $ p\_f $ | Pa | Pressure of the front conductor relative to the ambient pressure | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ p\_r $ | Pa | Pressure of the rear conductor relative to the ambient pressure | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ \\mathbf{T}\_a $ | \- | Transmission matrix of the acoustical side, 2 × 2, reduced from \\$ \\mathbf{T}*{a,e}* $ and $ *\\mathbf{T}*{a,rad} \\$ | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ \\mathbf{T}\_{a,e} $ | \- | Transmission matrix of the enclosure, 4 × 4 (`tae`) | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ \\mathbf{T}\_{a,rad} $ | \- | Transmission matrix of the radiation, 4 × 4 (`tarad`) | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ U\_f $ | m3/s | Volume velocity in the front conductor | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ U\_r $ | m3/s | Volume velocity in the rear conductor | [`solve2PortNetwork`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','methods','solve2portnetworkdoc','solve2portnetworkdoc.m'))) |
%[text] | $ Z\_{rad} $ | Pa.s/m3 | Radiation impedance | [`comp.ClosedBox`](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','comp','closedbox','closedboxdoc.m'))) |
%[text:table]

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
