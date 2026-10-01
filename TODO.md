# TODO

Cross-cutting tasks for the Loudspeaker System Toolbox. Tasks that belong to one specific file go in
that file as `% TODO: ...` (see the TODO/FIXME Report in the MATLAB Current Folder panel).

## Open

- [ ] First release as a toolbox package (`.mltbx`, `buildtool package`): 1 driver (`comp.Driver`) and 2 enclosures
  (`comp.ClosedBox`, `comp.FeaEnclosure`); the other enclosures and `comp.SemiInductanceDriver` stay on branch `dev`
  - [ ] First merge of `master` into `dev`: then revert the clean-up commit on `dev`, so that the extra enclosures
    stay there and later merges are clean
  - [ ] Explain how best to number versions (the toolbox version, `0.1.0` now in `buildfile.m`, and the git tags)
  - [ ] Then the packaging pipeline of the `matlab-package-toolbox` skill: API spec, dependencies, readiness check,
    build plan (`buildfile.m` exists, version `0.1.0`), build and publish with a version tag
- [ ] Review by Jeroen: `tests\ClosedBoxTest\ClosedBoxTest.m`
- [ ] Review by Jeroen: `tests\FeaEnclosureTest\FeaEnclosureTest.m`
- [ ] Optional: let `buildtool` make the test report (`plotSplComparison`, report in `tests\testreport`)


## Other

- [ ] Support radiation angles other than `"2pi"` (postponed on 2026-09-24: only `"2pi"` for now)
  - [ ] Extend the `RadiationAngle` validation in `lspsys` and the `ra == "2pi"` branches in the enclosures
  - [ ] Add the solid angle to the `switch` in `result.get.Pressure`

- [ ] `result.plot`: more quantities (phase, complex quantities, volume velocities) and a test for `plot`
