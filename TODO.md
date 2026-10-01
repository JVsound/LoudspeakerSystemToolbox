# TODO

Cross-cutting tasks for the Loudspeaker System Toolbox. Tasks that belong to one specific file go in
that file as `% TODO: ...` (see the TODO/FIXME Report in the MATLAB Current Folder panel).

## Open

- [ ] Closed-box loudspeaker system (`comp.ClosedBox`): tests against the standard closed-box formulas
  - [x] Sound pressure level at 1 m against the response of Small (`tests\ClosedBoxTest\ClosedBoxTest.m`, 2026-09-24;
    boxes of 50 L, 100 L and 200 L as TestParameter, 10 Hz to 400 Hz, and a figure in the report, 2026-09-29)
  - [ ] Electrical impedance against the standard formulas
  - [ ] Excursion of the diaphragm against the standard formulas (`result.DiaphragmExcursion`, added 2026-09-26)
- [ ] FEA-enclosure loudspeaker system (`comp.FeaEnclosure`): the same kinds of main tests, against FEA results
  - [ ] Simulation results from FEA (by the user): `tests\FeaEnclosureTest\helperfiles\createFeaResults.m` with
    `exportFeaPressureResults`, solved by Workbench itself through PyWorkbench (2026-09-29)
    - [x] Air in Ansys set to c = 343 m/s, as in `lspsys` (2026-09-29)
    - [ ] Run for 100 L full (`SYS`), 100 L quarter symmetry (`SYS-3`) and 50 L full (`SYS-2`), started 2026-09-29;
      check the log for three times "Done:"
    - [ ] Check that the quarter-symmetry model of 100 L is a real quarter: it was made as a copy of the full model
      with shared geometry
    - [ ] Remove the old folders `full200l`, `quartersymmetry200l` and `quartersymmetry50l` from `helperfiles` and
      from the project
  - [ ] Sound pressure level at 1 m (`tests\FeaEnclosureTest\FeaEnclosureTest.m`): boxes of 50 L and 100 L, up to
    350 Hz, below the standing wave along the cylinder (2026-09-29)
    - [ ] Look at the result with c = 343 m/s: with 346.25 m/s the 50 L box deviated up to 0.51 dB
  - [x] Quarter-symmetry model against the full model, now for the box of 100 L (class-specific test, 2026-09-29)
  - [ ] Electrical impedance
  - [ ] Excursion of the diaphragm
- [x] Test report with a figure per test: `plotSplComparison` in `tests\common\helperfiles`, report in
  `tests\testreport` (git ignores it), made by the project shortcut Create test report (2026-09-29)
  - [ ] Optional: let `buildtool` make the report
- [ ] Driver with a semi-inductance (`comp.SemiInductanceDriver`, subclass of `comp.Driver`)
  - [x] Class with `SemiInductance` (Ke, model of Vanderkooy), class page, symbols and class diagram (2026-09-29)
  - [ ] Change to the model of Hornresp with `Leb`, `Le`, `Ke` and `Rss`: first the exact circuit from the help of
    Hornresp or the paper of Thorborg and Futtrup (sources disagree on what is in series and in parallel)
- [ ] Bass-reflex loudspeaker system (`comp.BassReflex`) creation
  - [x] First try of `bassreflexdoc.m` with the diagram of its 4-ports (draft, 2026-09-26)
  - [x] Losses in the draft: leakage `R_a1`, absorption `R_a2` and port resistance `R_a3` (2026-09-26)
  - [ ] Decide the open points of the design (end correction, how the losses are given: Q values or
    resistances and their defaults, microphone position) and implement the class
- [ ] Front-loaded horn loudspeaker system (`comp.FrontLoadedHorn`) creation
  - [x] First try of `frontloadedhorndoc.m` with the diagram of its 4-ports (draft, 2026-09-26)
  - [x] Losses of the rear chamber in the draft: leakage `R_a1` and absorption `R_a2` (2026-09-26)
  - [ ] Decide the open points of the design (horn profile, segments, front air load, how the losses are
    given, losses in the horn) and implement the class
- [ ] Tapped horn loudspeaker system (`comp.TappedHorn`) creation
  - [x] First try of `tappedhorndoc.m` with the diagram of its 4-ports (draft, 2026-09-29)
  - [x] Front chamber and blind end of the horn (T_h1 below the rail) in the draft (2026-09-29)
  - [ ] Decide the open points of the design (horn profile, segments, positions of the taps, losses of the front
    chamber, air load, losses in the horn, signs at the taps) and implement the class
- [x] Network diagrams: every Simscape icon at one percentage of its own size (`iconPercent` in
  `generatenetworkdiagramsvg`), all diagrams regenerated (2026-09-29)
  - [x] `classdiagram.mldatx` with `comp.SemiInductanceDriver`, and the SVG/PNG class diagrams (2026-09-29)


## Other

- [ ] Support radiation angles other than `"2pi"` (postponed on 2026-09-24: only `"2pi"` for now)
  - [ ] Extend the `RadiationAngle` validation in `lspsys` and the `ra == "2pi"` branches in the enclosures
  - [ ] Add the solid angle to the `switch` in `result.get.Pressure`
