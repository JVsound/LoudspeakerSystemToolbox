classdef FeaEnclosureTest < matlab.unittest.TestCase
    %FEAENCLOSURETEST Test of comp.FeaEnclosure against the closed box of the model
    %   The main test compares the sound pressure level at 1 m, like the main test of ClosedBoxTest, here for the
    %   boxes of 50 L and 100 L, from 10 Hz to 350 Hz. The tests after it are specific to this class.
    %
    %   levelFollowsClosedBox calculates the sound pressure level (result.SoundPressureLevel) of a B&C 21SW152-8
    %   with a comp.FeaEnclosure, from the pressures of the full FEA model in Ansys of a closed box, and compares it
    %   with the level of the same driver in a comp.ClosedBox of the same volume at 1 m. It runs once for each box
    %   (TestParameter Box). The test fails when the FEA files are read wrongly, when the loads of the FEA on the
    %   diaphragm or the transfer to the microphone are wrong, or when the FEA model and the lumped model of the
    %   closed box disagree.
    %
    %   Tolerance: 0.75 dB, at the frequencies of the FEA files up to 350 Hz (MaxFrequency). The boxes are cylinders
    %   of 0.60 m diameter with the diaphragm in the middle of one end; their length sets the volume. The first
    %   standing wave along the length lies at c/(2*length): about 980 Hz for 50 L and 490 Hz for 100 L. Up to
    %   350 Hz it stays out of the result; the lumped model of the closed box has no standing waves.
    %
    %   impedanceFollowsClosedBox and peakExcursionFollowsClosedBox compare the magnitude of the electrical
    %   impedance (result.ElectricalImpedance) in [Ohm] and the peak excursion of the diaphragm
    %   (result.DiaphragmPeakExcursion) in [mm] of the same two results, over the same frequencies. Tolerances:
    %   impedance 30 Ohm, peak excursion 0.01 mm. Both are provisional. The largest differences are 24.0 Ohm (50 L)
    %   and 16.6 Ohm (100 L), and 0.0041 mm and 0.0031 mm. The impedance differs most because the resonance of the
    %   FEA model lies about 2 Hz (3 %) above that of the closed box, at 73.8 Hz against 71.7 Hz for 50 L: on the
    %   steep flank of the peak that is a large difference in Ohm, where the heights of the peaks agree within 1 Ohm.
    %
    %   quarterSymmetryFollowsFull compares the level with the quarter-symmetry FEA model of the box of 100 L, a
    %   quarter of the box with two planes of symmetry, with the level with the full model, at all frequencies of
    %   the FEA files. Both models hold the standing wave along the length, so it is compared as well. It fails when
    %   the planes of symmetry or the scaling of the quarter model are wrong. Tolerance: 0.75 dB.
    %
    %   The pressures of each FEA model are in a subfolder of helperfiles (full50l, full100l, quartersymmetry100l);
    %   createFeaResults there creates them from the Ansys project in helperfiles\fea. The FEA models impose 1e-3 m/s
    %   on the diaphragm and have the microphone at 1 m in a half space. The driver comes from createTestDriver in
    %   tests\common\helperfiles, with the values of the datasheet B&C 21SW152-8.pdf there.
    %
    %   Each test logs a figure of both levels and their difference (plotSplComparison in tests\common\helperfiles),
    %   also when it passes; generateHTMLReport on the test results shows it.
    %
    %   Run the test with buildtool, or with runtests("tests",IncludeSubfolders=true) from the project folder.

    properties (Constant)
        MaxFrequency = 350; % Highest frequency of the main test in [Hz], below the first standing wave
    end

    properties (TestParameter)
        Box = struct( ...
            Box50L=struct(Folder="full50l",Volume=50e-3), ...
            Box100L=struct(Folder="full100l",Volume=100e-3)); % Full FEA models: folder and volume of the box
    end

    methods (Test)
        function levelFollowsClosedBox(testCase,Box)
            %LEVELFOLLOWSCLOSEDBOX Level with the full FEA model follows the level of a closed box of the same volume

            % B&C 21SW152-8 in the FEA enclosure, at the frequencies of the FEA files up to MaxFrequency:
            res = FeaEnclosureTest.createResultObjectForFea(Box.Folder,FeaEnclosureTest.MaxFrequency);

            % The same driver in a closed box of the same volume, with the microphone at 1 m:
            expected = FeaEnclosureTest.createClosedBoxResult(Box.Volume,res.Frequency).SoundPressureLevel;

            tolerance = 0.75;
            plotSplComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end

        function impedanceFollowsClosedBox(testCase,Box)
            %IMPEDANCEFOLLOWSCLOSEDBOX Magnitude of the impedance with the full FEA model follows a closed box, in [Ohm]
            res = FeaEnclosureTest.createResultObjectForFea(Box.Folder,FeaEnclosureTest.MaxFrequency);
            expected = abs(FeaEnclosureTest.createClosedBoxResult(Box.Volume,res.Frequency).ElectricalImpedance);

            tolerance = 30;
            actual = abs(res.ElectricalImpedance);
            plotSplComparison(testCase,res.Frequency,actual,expected,tolerance,"|Z|","Ohm")
            testCase.verifyEqual(actual,expected,AbsTol=tolerance);
        end

        function peakExcursionFollowsClosedBox(testCase,Box)
            %PEAKEXCURSIONFOLLOWSCLOSEDBOX Peak excursion with the full FEA model follows a closed box, in [mm]
            res = FeaEnclosureTest.createResultObjectForFea(Box.Folder,FeaEnclosureTest.MaxFrequency);
            expected = 1e3*FeaEnclosureTest.createClosedBoxResult(Box.Volume,res.Frequency).DiaphragmPeakExcursion;

            tolerance = 0.01;
            actual = 1e3*res.DiaphragmPeakExcursion;
            plotSplComparison(testCase,res.Frequency,actual,expected,tolerance,"Peak excursion","mm")
            testCase.verifyEqual(actual,expected,AbsTol=tolerance);
        end

        function quarterSymmetryFollowsFull(testCase)
            %QUARTERSYMMETRYFOLLOWSFULL Level with the quarter-symmetry model follows the full model, box of 100 L
            res = FeaEnclosureTest.createResultObjectForFea("quartersymmetry100l",Inf);
            expected = FeaEnclosureTest.createResultObjectForFea("full100l",Inf).SoundPressureLevel;

            tolerance = 0.75;
            plotSplComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end
    end

    methods (Static, Access = private)
        function res = createClosedBoxResult(volume,frequency)
            %CREATECLOSEDBOXRESULT Result of the test driver in a closed box of the given volume
            %   res = FeaEnclosureTest.createClosedBoxResult(volume,frequency) returns the result of the test driver
            %   in a comp.ClosedBox of volume in [m3] at the frequencies in [Hz], with the microphone at 1 m.
            box = comp.ClosedBox;
            box.Driver = createTestDriver;
            box.RearVolume = volume;
            sys = lspsys;
            sys.Enclosure = box;
            sys.Frequency = frequency;
            res = sys.createResult;
        end

        function res = createResultObjectForFea(folderName,maxFrequency)
            %CREATERESULTOBJECTFORFEA Result of the test driver in the FEA enclosure, from a helperfiles folder
            %   res = FeaEnclosureTest.createResultObjectForFea(folderName,maxFrequency) reads the pressures in the
            %   subfolder folderName of helperfiles and returns the result object at the frequencies of the FEA files
            %   up to maxFrequency in [Hz]; Inf takes all of them.
            folder = fullfile(fileparts(which("FeaEnclosureTest")),"helperfiles",folderName);
            fea = comp.FeaEnclosure;
            fea.Driver = createTestDriver;
            fea.DiaphragmVelocity = 1e-3;
            fea.PressureRearFileName = fullfile(folder,"pRear.txt");
            fea.PressureFrontFileName = fullfile(folder,"pFront.txt");
            fea.PressureFarFieldFileName = fullfile(folder,"pMic.txt");
            sys = lspsys;
            sys.Enclosure = fea;
            sys.Frequency = fea.Frequency(fea.Frequency <= maxFrequency);
            res = sys.createResult;
        end
    end
end
