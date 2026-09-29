classdef FeaEnclosureTest < matlab.unittest.TestCase
    %FEAENCLOSURETEST Test of comp.FeaEnclosure against the closed box of the model
    %   The main test is the same as in ClosedBoxTest: the sound pressure level at 1 m for two boxes. The tests after
    %   it are specific to this class.
    %
    %   levelFollowsClosedBox calculates the sound pressure level (result.SoundPressureLevel) of a B&C 21SW152-8
    %   with a comp.FeaEnclosure, from the pressures of the full FEA model in Ansys of a closed box, and compares it
    %   with the level of the same driver in a comp.ClosedBox of the same volume at 1 m. It runs once for each box
    %   (TestParameter Box): 50 L and 200 L, like ClosedBoxTest. The test fails when the FEA files are read wrongly,
    %   when the loads of the FEA on the diaphragm or the transfer to the microphone are wrong, or when the FEA model
    %   and the lumped model of the closed box disagree.
    %
    %   Tolerance: 0.5 dB, from 10 Hz to 500 Hz, the frequencies of the FEA files. The whole range is tested on
    %   purpose, so that the figure shows it: above about 195 Hz the FEA deviates from the closed box (in the box of
    %   200 L, 250 frequencies of 2026-09-28: a dip of 10.6 dB at 243 Hz, a peak at 250 Hz and a peak of 16.1 dB at
    %   492 Hz), and the test fails there.
    %
    %   quarterSymmetryFollowsFull compares the level with the quarter-symmetry FEA model of the box of 200 L, a
    %   quarter of the box with two planes of symmetry, with the level with the full model. It fails when the planes
    %   of symmetry or the scaling of the quarter model are wrong. Tolerance: 0.1 dB; the two differ by at most
    %   0.044 dB with the results of 2026-09-28.
    %
    %   The pressures of each FEA model are in a subfolder of helperfiles (full50l, full200l, quartersymmetry200l);
    %   createFeaResults there creates them from the Ansys project in helperfiles\fea. The FEA models impose 1e-3 m/s
    %   on the diaphragm and have the microphone at 1 m in a half space. The driver comes from createTestDriver in
    %   tests\common\helperfiles, with the values of the datasheet B&C 21SW152-8.pdf there.
    %
    %   Each test logs a figure of both levels and their difference (logLevelComparison in tests\common\helperfiles),
    %   also when it passes; generateHTMLReport on the test results shows it.
    %
    %   Run the test with buildtool, or with runtests("tests",IncludeSubfolders=true) from the project folder.

    properties (TestParameter)
        Box = struct( ...
            Box50L=struct(Folder="full50l",Volume=50e-3), ...
            Box200L=struct(Folder="full200l",Volume=200e-3)); % Full FEA models: folder and volume of the box
    end

    methods (Test)
        function levelFollowsClosedBox(testCase,Box)
            %LEVELFOLLOWSCLOSEDBOX Level with the full FEA model follows the level of a closed box of the same volume

            % B&C 21SW152-8 in the FEA enclosure, at the frequencies of the FEA files:
            res = FeaEnclosureTest.createResultObjectForFea(Box.Folder);

            % The same driver in a closed box of the same volume, with the microphone at 1 m:
            box = comp.ClosedBox;
            box.Driver = createTestDriver;
            box.RearVolume = Box.Volume;
            reference = lspsys;
            reference.Enclosure = box;
            reference.Frequency = res.Frequency;
            expected = reference.createResult.SoundPressureLevel;

            tolerance = 0.5;
            logLevelComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end

        function quarterSymmetryFollowsFull(testCase)
            %QUARTERSYMMETRYFOLLOWSFULL Level with the quarter-symmetry model follows the full model, box of 200 L
            res = FeaEnclosureTest.createResultObjectForFea("quartersymmetry200l");
            expected = FeaEnclosureTest.createResultObjectForFea("full200l").SoundPressureLevel;

            tolerance = 0.1;
            logLevelComparison(testCase,res.Frequency,res.SoundPressureLevel,expected,tolerance)
            testCase.verifyEqual(res.SoundPressureLevel,expected,AbsTol=tolerance);
        end
    end

    methods (Static, Access = private)
        function res = createResultObjectForFea(folderName)
            %CREATERESULTOBJECTFORFEA Result of the test driver in the FEA enclosure, from a helperfiles folder
            %   res = FeaEnclosureTest.createResultObjectForFea(folderName) reads the pressures in the subfolder
            %   folderName of helperfiles and returns the result object at the frequencies of the FEA files.
            folder = fullfile(fileparts(which("FeaEnclosureTest")),"helperfiles",folderName);
            fea = comp.FeaEnclosure;
            fea.Driver = createTestDriver;
            fea.DiaphragmVelocity = 1e-3;
            fea.PressureRearFileName = fullfile(folder,"pRear.txt");
            fea.PressureFrontFileName = fullfile(folder,"pFront.txt");
            fea.PressureFarFieldFileName = fullfile(folder,"pMic.txt");
            sys = lspsys;
            sys.Enclosure = fea;
            sys.Frequency = fea.Frequency;
            res = sys.createResult;
        end
    end
end