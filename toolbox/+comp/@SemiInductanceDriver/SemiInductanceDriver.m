classdef SemiInductanceDriver < comp.Driver
    %SEMIINDUCTANCEDRIVER Loudspeaker driver with a semi-inductance in the impedance of the voice coil
    %   The blocked electrical impedance has, besides the resistance Re and the inductance Le of comp.Driver, the
    %   semi-inductance Ke (SemiInductance) of the model of J. Vanderkooy: Zeb = Re + j*w*Le + Ke*sqrt(j*w). The
    %   term describes the losses by eddy currents in the pole piece, which make the impedance rise with the square
    %   root of the frequency. Le and Ke must come from the same fit of the measured impedance. All other
    %   parameters and methods are those of comp.Driver; te, and so lspsys, use zeb.

    properties
        SemiInductance (1,1) double {mustBeNonnegative} = 0; % Semi-inductance Ke of the voice coil in [Ohm s^0.5]
    end

    methods
        function obj = SemiInductanceDriver
            %SEMIINDUCTANCEDRIVER Create a loudspeaker driver with a semi-inductance
            %   obj = SemiInductanceDriver creates a driver with all parameters set to zero.
        end

        function val = zeb(obj,f)
            %ZEB Blocked electrical impedance with the semi-inductance
            %   val = zeb(obj,f) returns the electrical impedance of the voice coil with the diaphragm blocked,
            %   Re + j*w*Le + Ke*sqrt(j*w), in [Ohm] at the frequencies f in [Hz].

            % Frequency in [rad/s]:
            w = 2*pi*f;

            % Blocked electrical impedance of comp.Driver plus the semi-inductance [Ohm]:
            val = zeb@comp.Driver(obj,f) + obj.SemiInductance*sqrt(1i*w);
        end
    end
end
