classdef ClosedBoxTest < matlab.unittest.TestCase
    %CLOSEDBOXTEST Test of the loudspeaker model against the closed-box theory of R. H. Small
    %   The test calculates the sound pressure level (result.SoundPressureLevel) of a B&C 21SW152-8 in a closed
    %   box at 1 m, from 10 Hz to 400 Hz, and compares it with the second-order high-pass response that Small gives
    %   for a closed box. The test runs once for each box (TestParameter RearVolume): 50 L and 200 L, the volume of
    %   the FEA models of FeaEnclosureTest.
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
    %   The driver comes from createTestDriver in tests\common\helperfiles, with the values of the datasheet
    %   B&C 21SW152-8.pdf there. The voice coil inductance Le is set to zero, because the theory of Small leaves it
    %   out.
    %
    %   Tolerance: 0.3 dB. The model uses the full radiation impedance of the diaphragm, where Small uses a
    %   constant air mass; that difference grows with frequency and reaches 0.27 dB at 400 Hz.
    %
    %   The test logs a figure of both levels and their difference (logLevelComparison in tests\common\helperfiles),
    %   also when it passes; generateHTMLReport on the test results shows it.
    %
    %   Run the test with buildtool, or with runtests("tests",IncludeSubfolders=true) from the project folder.

    properties (TestParameter)
        RearVolume = struct(Box50L=50e-3,Box200L=200e-3); % Volume of the closed box in [m3]
    end

    methods (Test)
        function levelFollowsClosedBoxResponse(testCase,RearVolume)
            %LEVELFOLLOWSCLOSEDBOXRESPONSE Level follows the second-order high-pass response of Small

            % B&C 21SW152-8 without voice coil inductance, in the closed box:
            driver = createTestDriver;
            driver.Le = 0;
            box = comp.ClosedBox;
            box.Driver = driver;
            box.RearVolume = RearVolume;
            sys = lspsys;
            sys.Enclosure = box;
            sys.Frequency = logspace(log10(10),log10(400),400);
            res = sys.createResult;

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

            tolerance = 0.3;
            logLevelComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end
    end
end
