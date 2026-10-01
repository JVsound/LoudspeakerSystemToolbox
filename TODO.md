# TODO

Cross-cutting tasks for the Loudspeaker System Toolbox. Tasks that belong to one specific file go in
that file as `% TODO: ...` (see the TODO/FIXME Report in the MATLAB Current Folder panel).

## Open

- [ ] First release as a toolbox package (`.mltbx`, `buildtool package`): 1 driver (`comp.Driver`) and 2 enclosures
  (`comp.ClosedBox`, `comp.FeaEnclosure`); the other enclosures and `comp.SemiInductanceDriver` stay on branch `dev`
  - [ ] First merge of `master` into `dev`: then revert the clean-up commit on `dev`, so that the extra enclosures
    stay there and later merges are clean
  - [ ] More functionality and more tests for the release classes (see below)
  - [ ] Documentation pages brought up to date in one pass, from the code (not before the code is complete)
  - [ ] Explain how best to number versions (the toolbox version, `0.1.0` now in `buildfile.m`, and the git tags)
  - [ ] Then the packaging pipeline of the `matlab-package-toolbox` skill: API spec, dependencies, readiness check,
    build plan (`buildfile.m` exists, version `0.1.0`), build and publish with a version tag
- [ ] `result.plot`: more quantities (phase, complex quantities, volume velocities) and a test for `plot`
- [ ] Closed-box loudspeaker system (`comp.ClosedBox`): tests against the standard closed-box formulas
  - [ ] Electrical impedance against the standard formulas
  - [ ] Excursion of the diaphragm against the standard formulas (`result.DiaphragmExcursion`, added 2026-09-26)
- [ ] FEA-enclosure loudspeaker system (`comp.FeaEnclosure`): the same kinds of main tests, against FEA results
  - [ ] Simulation results from FEA (by the user): `tests\FeaEnclosureTest\helperfiles\createFeaResults.m` with
    `exportFeaPressureResults`, solved by Workbench itself through PyWorkbench (2026-09-29)
    - [ ] Run for 100 L full (`SYS`), 100 L quarter symmetry (`SYS-3`) and 50 L full (`SYS-2`), started 2026-09-29;
      check the log for three times "Done:"
    - [ ] Check that the quarter-symmetry model of 100 L is a real quarter: it was made as a copy of the full model
      with shared geometry
    - [ ] Remove the old folders `full200l`, `quartersymmetry200l` and `quartersymmetry50l` from `helperfiles` and
      from the project
  - [ ] Sound pressure level at 1 m (`tests\FeaEnclosureTest\FeaEnclosureTest.m`): boxes of 50 L and 100 L, up to
    350 Hz, below the standing wave along the cylinder (2026-09-29)
    - [ ] Look at the result with c = 343 m/s: the test of 50 L fails by 0.0001 dB (0.5001 dB against 0.5 dB at
      236-242 Hz, 2026-10-01); check the FEA run for 50 L, then decide on the frequency range or the tolerance
      (it was 0.51 dB with c = 346.25 m/s)
  - [ ] Electrical impedance
  - [ ] Excursion of the diaphragm
- [ ] Optional: let `buildtool` make the test report (`plotSplComparison`, report in `tests\testreport`)


## Other

- [ ] Support radiation angles other than `"2pi"` (postponed on 2026-09-24: only `"2pi"` for now)
  - [ ] Extend the `RadiationAngle` validation in `lspsys` and the `ra == "2pi"` branches in the enclosures
  - [ ] Add the solid angle to the `switch` in `result.get.Pressure`
