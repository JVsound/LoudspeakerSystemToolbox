classdef ClosedBoxTest < matlab.unittest.TestCase
    %CLOSEDBOXTEST Test of the loudspeaker model against the closed-box theory of R. H. Small
    %   The tests calculate the result of a B&C 21SW152-8 in a closed box at 1 m, from 10 Hz to 400 Hz, and compare
    %   it with the theory of a closed box. Each test runs once for each box (TestParameter RearVolume): 50 L, 100 L
    %   and 200 L.
    %
    %   levelFollowsClosedBoxResponse compares the sound pressure level (result.SoundPressureLevel) with the
    %   second-order high-pass response that Small gives for a closed box.
    %
    %       SPL = SPLpb + 20*log10(x^2/sqrt(x^4 + (1/Qtc^2 - 2)*x^2 + 1)),   x = f/fc
    %       fc = Fs*sqrt(1 + Vas/Vr),   Qtc = Qts*sqrt(1 + Vas/Vr)
    %
    %   Vr is the volume of the box (RearVolume), which the literature writes as Vb.
    %
    %   SPLpb is the passband level, from the reference efficiency eta0 = 4*pi^2*Fs^3*Vas/(c^3*Qes) and the
    %   electrical power e^2/Re, radiated into a half space. The test fails when the enclosure, the driver, the
    %   network or the pressure formula is wrong, or when the model ignores the box.
    %
    %   impedanceFollowsClosedBoxResponse compares the magnitude of the electrical impedance
    %   (result.ElectricalImpedance) in [Ohm], and peakExcursionFollowsClosedBoxResponse the peak excursion of the
    %   diaphragm (result.DiaphragmPeakExcursion) in [mm], with the equivalent circuit of the driver in a closed box:
    %
    %       Zm = Rms + Rrad + j*w*Mms + 1/(j*w*Cmc),   Cmc = Cms/(1 + Vas/Vr)
    %       Ze = Re + Bl^2/Zm,   v = Bl*e/(Re*Zm + Bl^2),   peak excursion = sqrt(2)*|v|/w
    %
    %   Mms, Cms, Bl and Rms follow from the Thiele-Small parameters of the datasheet. Rrad is the radiation
    %   resistance of a piston in an infinite baffle, Rrad = rho*c*Sd*(1 - 2*J1(x)/x) with x = 2*k*a (Beranek and
    %   Mellow): the model radiates at the front of the diaphragm, which the closed-box theory of Small leaves out.
    %   Without Rrad the impedance at the resonance would differ by 17 Ohm for the box of 50 L.
    %
    %   The driver comes from createTestDriver in tests\common\helperfiles, with the values of the datasheet
    %   B&C 21SW152-8.pdf there. The voice coil inductance Le is set to zero, because the theory leaves it out.
    %
    %   Tolerances: the level 0.75 dB, the impedance 1.5 Ohm (the largest difference is 0.93 Ohm, for the box of
    %   50 L) and the peak excursion 0.001 mm (the largest difference is 0.0004 mm, at 400 Hz). The model uses the
    %   full radiation impedance of the diaphragm, where the theory has no radiation mass or a constant air mass;
    %   that difference grows with frequency.
    %
    %   Each test logs a figure of both curves and their difference (plotSplComparison in tests\common\helperfiles),
    %   also when it passes; generateHTMLReport on the test results shows it.
    %
    %   Run the test with buildtool, or with runtests("tests",IncludeSubfolders=true) from the project folder.

    properties (TestParameter)
        RearVolume = struct(Box50L=50e-3,Box100L=100e-3,Box200L=200e-3); % Volume of the closed box in [m3]
    end

    methods (Test)
        function levelFollowsClosedBoxResponse(testCase,RearVolume)
            %LEVELFOLLOWSCLOSEDBOXRESPONSE Level follows the second-order high-pass response of Small
            [res,driver,box] = ClosedBoxTest.createClosedBoxResult(RearVolume);

            % Response of Small:
            c = lspsys.SpeedOfSound;
            factor = sqrt(1 + driver.Vas/box.RearVolume);
            fc = driver.Fs*factor;
            Qtc = driver.Qts*factor;
            eta0 = 4*pi^2*driver.Fs^3*driver.Vas/(c^3*driver.Qes);
            intensity = eta0*res.SourceVoltage(1)^2/driver.Re/(2*pi*res.MicRadius^2);
            passbandLevel = 10*log10(lspsys.AirDensity*c*intensity/lspsys.ReferencePressure^2);
            x = res.Frequency/fc;
            expected = passbandLevel + 20*log10(x.^2./sqrt(x.^4 + (1/Qtc^2-2)*x.^2 + 1));

            tolerance = 0.75;
            plotSplComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end

        function impedanceFollowsClosedBoxResponse(testCase,RearVolume)
            %IMPEDANCEFOLLOWSCLOSEDBOXRESPONSE Magnitude of the impedance follows the equivalent circuit, in [Ohm]
            [res,driver] = ClosedBoxTest.createClosedBoxResult(RearVolume);
            [Zm,Bl] = ClosedBoxTest.createMechanicalImpedance(driver,RearVolume,res.Frequency);

            % Electrical impedance of the driver without voice coil inductance:
            expected = abs(driver.Re + Bl^2./Zm);

            tolerance = 1.5;
            actual = abs(res.ElectricalImpedance);
            plotSplComparison(testCase,res.Frequency,actual,expected,tolerance,"|Z|","Ohm")
            testCase.verifyEqual(actual,expected,AbsTol=tolerance);
        end

        function peakExcursionFollowsClosedBoxResponse(testCase,RearVolume)
            %PEAKEXCURSIONFOLLOWSCLOSEDBOXRESPONSE Peak excursion follows the equivalent circuit, in [mm]
            [res,driver] = ClosedBoxTest.createClosedBoxResult(RearVolume);
            [Zm,Bl] = ClosedBoxTest.createMechanicalImpedance(driver,RearVolume,res.Frequency);

            % Velocity of the diaphragm at the RMS source voltage, and the peak excursion of a sine signal in [mm]:
            velocity = Bl*res.SourceVoltage(1)./(driver.Re*Zm + Bl^2);
            expected = 1e3*sqrt(2)*abs(velocity)./(2*pi*res.Frequency);

            tolerance = 0.001;
            actual = 1e3*res.DiaphragmPeakExcursion;
            plotSplComparison(testCase,res.Frequency,actual,expected,tolerance,"Peak excursion","mm")
            testCase.verifyEqual(actual,expected,AbsTol=tolerance);
        end
    end

    methods (Static, Access = private)
        function [res,driver,box] = createClosedBoxResult(rearVolume)
            %CREATECLOSEDBOXRESULT Result of the test driver without voice coil inductance in a closed box
            %   [res,driver,box] = ClosedBoxTest.createClosedBoxResult(rearVolume) returns the result at 1 m from
            %   10 Hz to 400 Hz, with the driver and the box of volume rearVolume in [m3] that it uses.
            driver = createTestDriver;
            driver.Le = 0;
            box = comp.ClosedBox;
            box.Driver = driver;
            box.RearVolume = rearVolume;
            sys = lspsys;
            sys.Enclosure = box;
            sys.Frequency = logspace(log10(10),log10(400),400);
            res = sys.createResult;
        end

        function [Zm,Bl] = createMechanicalImpedance(driver,rearVolume,frequency)
            %CREATEMECHANICALIMPEDANCE Mechanical impedance of the driver in a closed box, and its force factor
            %   [Zm,Bl] = ClosedBoxTest.createMechanicalImpedance(driver,rearVolume,frequency) returns Zm in
            %   [N.s/m] at the frequencies in [Hz] and Bl in [T.m], from the Thiele-Small parameters of the driver
            %   and the radiation resistance of a piston in an infinite baffle (L. Beranek and T. Mellow, Acoustics:
            %   Sound Fields, Transducers and Vibration, 2nd ed., Academic Press, 2019).
            w = 2*pi*frequency;
            ws = 2*pi*driver.Fs;
            c = lspsys.SpeedOfSound;
            rho = lspsys.AirDensity;

            % Suspension, moving mass, force factor and mechanical losses from the Thiele-Small parameters:
            Cms = driver.Vas/(rho*c^2*driver.Sd^2);
            Mms = 1/(ws^2*Cms);
            Bl = sqrt(ws*Mms*driver.Re/driver.Qes);
            Rms = ws*Mms/driver.Qms;

            % The air in the box is in series with the suspension:
            Cmc = Cms/(1 + driver.Vas/rearVolume);

            % Radiation resistance of the piston with radius a, x = 2*k*a:
            a = sqrt(driver.Sd/pi);
            x = 2*w/c*a;
            Rrad = rho*c*driver.Sd*(1 - 2*besselj(1,x)./x);

            Zm = Rms + Rrad + 1i*w*Mms + 1./(1i*w*Cmc);
        end
    end
end
