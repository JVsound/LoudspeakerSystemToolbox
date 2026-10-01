classdef (InferiorClasses = {?matlab.graphics.axis.Axes}) result
    %RESULT Results of a loudspeaker system calculation
    %   A result object holds the arrays that lspsys calculates over Frequency: the source voltage and
    %   current and the volume velocities of the diaphragm and the radiated sound. lspsys.createResult
    %   creates it. ElectricalImpedance, Pressure, SoundPressureLevel, DiaphragmExcursion and
    %   DiaphragmPeakExcursion are derived from these arrays. Pressure comes from the transfer to the microphone
    %   (MicTransfer) when the enclosure gives one, and otherwise from the radiated volume velocity at the
    %   distance MicRadius. splMax, splPowerLimited, splExcursionLimited and splMaxPeakVoltage give the highest
    %   level and its voltage that ExcursionLimit and PowerLimit allow: the limits of the driver (Driver) that
    %   lspsys.createResult copies from Driver.ExcursionLimit and Driver.PowerLimit, or other values that you set.
    %   plot shows the sound pressure levels, the magnitude of ElectricalImpedance and DiaphragmPeakExcursion against
    %   Frequency.

    properties (SetAccess = ?lspsys)
        Frequency (1,:) double = 0; % Frequencies of the calculation in [Hz]
        SourceVoltage (1,:) double = 0; % RMS voltage of the source in [V]
        SourceCurrent (1,:) double = 0; % Current of the source in [A]
        DiaphragmVolumeVelocity (1,:) double = 0; % Volume velocity of the diaphragm in [m3/s]
        RadiatedVolumeVelocity (1,:) double = 0; % Volume velocity of the radiated sound in [m3/s]
        RadiationAngle (1,1) string = "2pi"; % Radiation angle of the enclosure
        MicTransfer (1,:) double = zeros(1,0); % Transfer p_mic/U_d in [Pa.s/m3] from the enclosure, or empty
        Driver (1,1) comp.Driver = comp.Driver; % Driver of the system, with its limits for splMax
    end

    properties
        MicRadius (1,1) double {mustBePositive} = 1; % Distance in [m] from the radiation surface to the microphone
        ExcursionLimit {mustBeExcursionLimit} = "Xvar"; % Excursion limit for splMax: a name of Driver or a peak in [m]
        PowerLimit {mustBePowerLimit} = "Pnom"; % Power limit for splMax: a name of Driver or a power in [W]
    end

    properties (Dependent)
        ElectricalImpedance % Electrical impedance of the system in [Ohm]
        Pressure % Complex sound pressure at MicRadius in [Pa]
        SoundPressureLevel % Sound pressure level at MicRadius in [dB]
        DiaphragmExcursion % Complex excursion of the diaphragm in [m], RMS like SourceVoltage
        DiaphragmPeakExcursion % Peak excursion of the diaphragm for a sine signal in [m], one way
    end

    methods
        function obj = result
            %RESULT Create a result object
            %   obj = result creates a result object with all arrays set to zero.
        end

        function val = get.ElectricalImpedance(obj)
            %ELECTRICALIMPEDANCE Electrical impedance of the system in [Ohm]
            val = obj.SourceVoltage./obj.SourceCurrent;
        end

        function val = get.Pressure(obj)
            %PRESSURE Complex sound pressure at MicRadius in [Pa]

            % When the enclosure gives the transfer to the microphone (for example from an FEA model), the
            % pressure is that transfer times the diaphragm volume velocity; MicRadius is then fixed by the model:
            if ~isempty(obj.MicTransfer)
                val = obj.MicTransfer.*obj.DiaphragmVolumeVelocity;
                return
            end

            % Otherwise, pressure on the axis of a source with volume velocity Urad that radiates into the solid
            % angle of RadiationAngle, at distance rMic in the far field:
            % p = j*w*rho*Urad*exp(-j*k*rMic)/(solidAngle*rMic).
            % Source: L. Beranek and T. Mellow, Acoustics: Sound Fields, Transducers and Vibration, 2nd ed.,
            % Academic Press, 2019 (sound sources: monopole and piston in an infinite baffle).

            % Solid angle in [sr]. Give every supported RadiationAngle its solid angle here:
            switch obj.RadiationAngle
                case "2pi"
                    solidAngle = 2*pi;
                otherwise
                    error("result:unsupportedRadiationAngle","Unsupported radiation angle ""%s"".",obj.RadiationAngle)
            end

            % Angular frequency in [rad/s]:
            w = 2*pi*obj.Frequency;

            % Wave number in [rad/m]:
            k = lspsys.f2k(obj.Frequency);

            % Density of air in [kg/m3], volume velocity in [m3/s] and distance in [m]:
            rho = lspsys.AirDensity;
            Urad = obj.RadiatedVolumeVelocity;
            rMic = obj.MicRadius;

            % Sound pressure:
            val = 1i*rho*w.*Urad.*exp(-1i*k*rMic)/(solidAngle*rMic);
        end

        function val = get.SoundPressureLevel(obj)
            %SOUNDPRESSURELEVEL Sound pressure level at MicRadius in [dB]

            % Level of the RMS pressure relative to the reference pressure of lspsys:
            val = 20*log10(abs(obj.Pressure)/lspsys.ReferencePressure);
        end

        function val = get.DiaphragmExcursion(obj)
            %DIAPHRAGMEXCURSION Complex excursion of the diaphragm in [m], RMS like SourceVoltage

            % The excursion is the volume velocity divided by j*w and the effective area of the diaphragm:
            w = 2*pi*obj.Frequency;
            val = obj.DiaphragmVolumeVelocity./(1i*w*obj.Driver.Sd);
        end

        function val = get.DiaphragmPeakExcursion(obj)
            %DIAPHRAGMPEAKEXCURSION Peak excursion of the diaphragm for a sine signal in [m], one way

            % The peak of a sine signal is sqrt(2) times its RMS value:
            val = sqrt(2)*abs(obj.DiaphragmExcursion);
        end

        function val = splMax(obj)
            %SPLMAX Highest sound pressure level that the power and the excursion limits allow
            %   val = splMax(obj) returns the maximum sound pressure level in [dB] at each frequency, for a sine
            %   signal, with the limits in ExcursionLimit and PowerLimit: the lower of splPowerLimited and
            %   splExcursionLimited. Set ExcursionLimit or PowerLimit of the result to use other limits without
            %   changing the driver.
            maxVoltage = min(obj.excursionVoltage(obj.ExcursionLimit),obj.powerVoltage(obj.PowerLimit));
            val = obj.SoundPressureLevel + 20*log10(maxVoltage./obj.SourceVoltage);
        end

        function val = splPowerLimited(obj)
            %SPLPOWERLIMITED Sound pressure level that the power limit alone allows
            %   val = splPowerLimited(obj) returns the sound pressure level in [dB] at each frequency, for a sine
            %   signal, at the voltage that the power limit in PowerLimit allows.
            %
            %   A power limit of the driver limits the RMS voltage to sqrt(P*Z), with the impedance of its
            %   definition: Zmin for Pnom, Pcont and Paes1984 (AES2-1984), Znom for Paes2012 (AES2-2012). A power
            %   in [W] is the real power into the actual electrical impedance Z_e: the RMS voltage is
            %   |Z_e|*sqrt(P/Re(Z_e)).
            val = obj.SoundPressureLevel + 20*log10(obj.powerVoltage(obj.PowerLimit)./obj.SourceVoltage);
        end

        function val = splExcursionLimited(obj)
            %SPLEXCURSIONLIMITED Sound pressure level that the excursion limit alone allows
            %   val = splExcursionLimited(obj) returns the sound pressure level in [dB] at each frequency, for a
            %   sine signal, at the voltage at which the peak excursion of the diaphragm (DiaphragmPeakExcursion)
            %   reaches the excursion limit in ExcursionLimit.
            val = obj.SoundPressureLevel + 20*log10(obj.excursionVoltage(obj.ExcursionLimit)./obj.SourceVoltage);
        end

        function val = splMaxPeakVoltage(obj)
            %SPLMAXPEAKVOLTAGE Peak source voltage at which the sound pressure level reaches splMax
            %   val = splMaxPeakVoltage(obj) returns the peak voltage in [V] of a sine signal at each frequency
            %   that gives the maximum sound pressure level of splMax, with the limits in ExcursionLimit and
            %   PowerLimit: sqrt(2) times the lower of the RMS voltages that the excursion and the power limit
            %   allow.
            val = sqrt(2)*min(obj.excursionVoltage(obj.ExcursionLimit),obj.powerVoltage(obj.PowerLimit));
        end

        function [ax,lines] = plot(varargin)
            %PLOT Plot a quantity of the result against frequency
            %   [ax,lines] = plot(obj,name) plots the quantity name against Frequency on a logarithmic frequency
            %   axis in the current axes and returns the axes and the line. name is one of "SoundPressureLevel",
            %   "splMax", "splPowerLimited", "splExcursionLimited", "ElectricalImpedance" (magnitude in [Ohm]) and
            %   "DiaphragmPeakExcursion" (in [mm]).
            %
            %   [ax,lines] = plot(ax,obj,name) plots in the axes ax, as plot of MATLAB does. Use hold on to add the
            %   lines of another result to the same axes.
            %
            %   [ax,lines] = plot(obj,names) with a string array of names plots several quantities in one axes,
            %   with a legend, and returns one line for each name, in the order of names. The quantities must have
            %   the same unit: the names that give a sound pressure level can be combined.
            %
            %   Each line has the readable name of its quantity as DisplayName, which legend shows.
            narginchk(2,3)
            if isgraphics(varargin{1},"axes")
                ax = varargin{1};
                varargin(1) = [];
            else
                ax = gca;
            end
            obj = varargin{1};
            names = string(varargin{2});

            % One column of values and one axis label for each name:
            y = zeros(numel(obj.Frequency),numel(names));
            labels = strings(1,numel(names));
            displayNames = strings(1,numel(names));
            for k = 1:numel(names)
                [values,labels(k),displayNames(k)] = obj.plotQuantity(names(k));
                y(:,k) = values(:);
            end
            if numel(unique(labels)) > 1
                error("result:mixedQuantities","Quantities with different units cannot be in one plot.")
            end

            % The DisplayName of each line is the text that legend shows for it:
            lines = semilogx(ax,obj.Frequency(:),y);
            for k = 1:numel(lines)
                lines(k).DisplayName = displayNames(k);
            end
            ax.XScale = "log";
            grid(ax,"on")
            xlabel(ax,"Frequency [Hz]")
            ylabel(ax,labels(1))
            if numel(names) > 1
                legend(ax,"show")
            end
        end
    end

    methods (Access = private)
        function [val,label,displayName] = plotQuantity(obj,name)
            %PLOTQUANTITY Values, axis label and legend text of a quantity that plot can show
            label = "Sound pressure level [dB]";
            switch name
                case "SoundPressureLevel"
                    val = obj.SoundPressureLevel;
                    displayName = "Sound pressure level";
                case "splMax"
                    val = obj.splMax;
                    displayName = "Maximum sound pressure level";
                case "splPowerLimited"
                    val = obj.splPowerLimited;
                    displayName = "Sound pressure level, power limit";
                case "splExcursionLimited"
                    val = obj.splExcursionLimited;
                    displayName = "Sound pressure level, excursion limit";
                case "ElectricalImpedance"
                    val = abs(obj.ElectricalImpedance);
                    label = "Electrical impedance magnitude [Ohm]";
                    displayName = "Electrical impedance";
                case "DiaphragmPeakExcursion"
                    val = 1e3*obj.DiaphragmPeakExcursion;
                    label = "Diaphragm peak excursion [mm]";
                    displayName = "Diaphragm peak excursion";
                otherwise
                    error("result:unknownQuantity","Unknown quantity ""%s"": use one of %s.",name, ...
                        strjoin(["SoundPressureLevel","splMax","splPowerLimited","splExcursionLimited", ...
                        "ElectricalImpedance","DiaphragmPeakExcursion"],", "))
            end
        end

        function val = excursionVoltage(obj,excursion)
            %EXCURSIONVOLTAGE RMS source voltage at which the peak excursion reaches the excursion limit, in [V]
            %   The model is linear, so the excursion scales with the source voltage.
            excursionLimit = obj.driverLimit(excursion,["Xmax","Xvar","Xlim","Xmech"]);
            val = obj.SourceVoltage.*excursionLimit./obj.DiaphragmPeakExcursion;
        end

        function val = powerVoltage(obj,power)
            %POWERVOLTAGE RMS source voltage that the power limit allows, in [V]
            %   A power limit of the driver uses the impedance of its definition; a power in [W] is the real power
            %   into the actual electrical impedance.
            powerLimit = obj.driverLimit(power,["Pnom","Pcont","Paes1984","Paes2012"]);
            if isnumeric(power)
                % Real power into the actual electrical impedance:
                Ze = obj.ElectricalImpedance;
                val = abs(Ze).*sqrt(powerLimit./real(Ze));
            else
                % Impedance of the definition of the power limit:
                if string(power) == "Paes2012"
                    impedanceName = "Znom";
                else
                    impedanceName = "Zmin";
                end
                impedance = obj.driverLimit(impedanceName,impedanceName);
                val = sqrt(powerLimit*impedance)*ones(size(obj.Frequency));
            end
        end

        function val = driverLimit(obj,limit,names)
            %DRIVERLIMIT Value of a limit, given as a number or as the name of a property of the driver
            %   A name must be one of names, and the property of the driver must not be 0 (not given).
            if isnumeric(limit)
                val = limit;
                return
            end
            limit = string(limit);
            if ~ismember(limit,names)
                error("result:unknownLimit","Unknown limit ""%s"": use one of %s.",limit,strjoin(names,", "))
            end
            val = obj.Driver.(limit);
            if val == 0
                error("result:missingLimit","Driver.%s is not given.",limit)
            end
        end
    end
end

function mustBeExcursionLimit(value)
%MUSTBEEXCURSIONLIMIT Validate an excursion limit: a name of an excursion limit of the driver or a peak in [m]
if isnumeric(value)
    mustBeNonempty(value)
    mustBeScalarOrEmpty(value)
    mustBeNonnegative(value)
else
    mustBeMember(value,["Xmax","Xvar","Xlim","Xmech"])
end
end

function mustBePowerLimit(value)
%MUSTBEPOWERLIMIT Validate a power limit: a name of a power limit of the driver or a power in [W]
if isnumeric(value)
    mustBeNonempty(value)
    mustBeScalarOrEmpty(value)
    mustBeNonnegative(value)
else
    mustBeMember(value,["Pnom","Pcont","Paes1984","Paes2012"])
end
end