classdef lspsys
    %LSPSYS Loudspeaker system object
    %   A loudspeaker system consists of a driver in an enclosure (Enclosure), driven by a voltage
    %   source (SourceVoltage). solve2PortNetwork and createResult calculate the response over
    %   Frequency with a two-port network model.

    properties (Access = public)
        Frequency (1,:) double {mustBePositive} = logspace(log10(2e1),log10(2e4),1e3); % Frequencies in [Hz]
        SourceVoltage (1,1) double {mustBePositive} = 2.83; % RMS voltage of the source in [V]
        RadiationAngle (1,1) string {mustBeMember(RadiationAngle,"2pi")} = "2pi"; % Radiation angle of the enclosure
        Enclosure (1,1) comp.Enclosure = comp.ClosedBox; % Enclosure that contains the driver
    end

    properties (Dependent, Hidden)
        AngularFrequency % Angular frequency in [rad/s]
        WaveNumber % Wave number in [rad/m]
        Wavelength % Wavelength in [m]
        NumFrequencies % Number of frequencies
    end

    properties (Constant, Hidden)
        SpeedOfSound = 343; % Speed of sound [m/s], at 20deg C. Source: Wikipedia
        AirDensity = 1.225; % Density of air [kg/m3] at sea level, at 20deg C. Source: Wikipedia
        ReferencePressure = 20e-6; % Reference pressure [Pa] for sound pressure level calculations
    end

    methods
        function obj = lspsys
            %LSPSYS Create a loudspeaker system object
            %   obj = lspsys creates a system with the default frequencies, source voltage and enclosure.
        end

        function val = get.AngularFrequency(obj)
            %ANGULARFREQUENCY Angular frequency in [rad/s]
            val = obj.Frequency*2*pi;
        end

        function val = get.WaveNumber(obj)
            %WAVENUMBER Wave number in [rad/m]
            val = lspsys.f2k(obj.Frequency);
        end

        function val = get.Wavelength(obj)
            %WAVELENGTH Wavelength in [m]
            val = lspsys.f2Lambda(obj.Frequency);
        end

        function val = get.NumFrequencies(obj)
            %NUMFREQUENCIES Number of frequencies
            val = numel(obj.Frequency);
        end

        function val = solve2PortNetwork(obj)
            %SOLVE2PORTNETWORK Solve the two-port network of the loudspeaker system
            %   val = solve2PortNetwork(obj) reduces the 4-ports tae (enclosure) and tarad (radiation) of the
            %   enclosure to the 2-port Ta of the acoustical side, multiplies it with the transmission matrices
            %   of the driver for each frequency, and solves the network with port 2 of Ta open. val is a
            %   structure with the fields DiaphragmVolumeVelocity, RadiatedVolumeVelocity and SourceCurrent,
            %   each a row vector over Frequency.

            % We need: Te, Tbl, Tm, Tsd, Tae, Tarad
            Te = obj.Enclosure.Driver.te(obj.Frequency);
            Tbl = obj.Enclosure.Driver.tbl;
            Tm = obj.Enclosure.Driver.tm(obj.Frequency);
            Tsd = obj.Enclosure.Driver.tsd;
            Tae = obj.Enclosure.tae(obj.Frequency,obj.RadiationAngle);
            Tarad = obj.Enclosure.tarad(obj.Frequency,obj.RadiationAngle);

            % Repeat the frequency independent matrices for each frequency:
            Tbl = repmat(Tbl,1,1,obj.NumFrequencies);
            Tsd = repmat(Tsd,1,1,obj.NumFrequencies);

            % Allocate Ud, Urad and ig:
            Ud = zeros(1,obj.NumFrequencies);
            Urad = zeros(1,obj.NumFrequencies);
            ig = zeros(1,obj.NumFrequencies);

            % Port 2 of the 4-ports: p_2 = p_f - p_r and U_f = U_r = U_2 (front and rear flow), with the free
            % pressure p_r: x = P*[p_2; U_2] + q*p_r. Flows count to the right on the front conductor and to the
            % left on the rear conductor.
            P = [1 0; 0 1; 0 0; 0 1];
            q = [1; 0; 1; 0];

            for i = 1:obj.NumFrequencies
                % Reduce the 4-ports to the 2-port Ta. Rows 2 and 4 of M both give U_d, which fixes p_r; port 1
                % is p_1 = p_f - p_r (rows 1 and 3) and U_d (row 2):
                M = Tae(:,:,i)*Tarad(:,:,i);
                d = M(2,:) - M(4,:);
                K = P - q*(d*P)/(d*q);
                Ta = [M(1,:) - M(3,:); M(2,:)]*K;

                % Complete 2-port transmission matrix:
                T = Te(:,:,i)*Tbl(:,:,i)*Tm(:,:,i)*Tsd(:,:,i)*Ta;

                % Port 2 of Ta is open (U_2 = 0), so the first column gives its pressure p_2:
                p2 = obj.SourceVoltage/T(1,1);

                % Diaphragm volume velocity:
                Ud(i) = Ta(2,1)*p2;

                % Electric current:
                ig(i) = T(2,1)*p2;

                % Radiated volume velocity: the flow that the radiation 4-port leads to the ambient pressure,
                % from its output (x3) and its input (x2):
                x3 = K*[p2; 0];
                x2 = Tarad(:,:,i)*x3;
                Urad(i) = (x2(2) - x3(2)) - (x2(4) - x3(4));
            end

            val.DiaphragmVolumeVelocity = Ud;
            val.RadiatedVolumeVelocity = Urad;
            val.SourceCurrent = ig;
        end

        function val = createResult(obj)
            %CREATERESULT Create a result object for the loudspeaker system
            %   val = createResult(obj) solves the two-port network and returns a result object with the
            %   frequency, source voltage, diaphragm and radiated volume velocity and source current, and the
            %   transfer to the microphone (micTransfer) of the enclosure, which is empty for most enclosures, and
            %   the driver with its choice of limits (ExcursionLimit, PowerLimit), which splMax of the result uses.

            % Solve 2-port network:
            s2p = obj.solve2PortNetwork;

            % Initiate object for results collection:
            val = result;

            % Assign results
            val.Frequency = obj.Frequency;
            val.SourceVoltage = ones(1,obj.NumFrequencies,1)*obj.SourceVoltage;
            val.DiaphragmVolumeVelocity = s2p.DiaphragmVolumeVelocity;
            val.RadiatedVolumeVelocity = s2p.RadiatedVolumeVelocity;
            val.SourceCurrent = s2p.SourceCurrent;
            val.MicTransfer = obj.Enclosure.micTransfer(obj.Frequency,obj.RadiationAngle);
            val.Driver = obj.Enclosure.Driver;
            val.ExcursionLimit = obj.Enclosure.Driver.ExcursionLimit;
            val.PowerLimit = obj.Enclosure.Driver.PowerLimit;
        end
    end

    methods (Static)
        function val = f2Lambda(f)
            %F2LAMBDA Frequency to wavelength
            %   val = lspsys.f2Lambda(f) returns the wavelength in [m] for the frequency f in [Hz].
            val = lspsys.SpeedOfSound./f;
        end

        function val = f2k(f)
            %F2K Frequency to wave number
            %   val = lspsys.f2k(f) returns the wave number in [rad/m] for the frequency f in [Hz].
            val = 2*pi*f/lspsys.SpeedOfSound;
        end
    end
end
