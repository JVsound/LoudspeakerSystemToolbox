# TODO

Cross-cutting tasks for the Loudspeaker System Toolbox. Tasks that belong to one specific file go in
that file as `% TODO: ...` (see the TODO/FIXME Report in the MATLAB Current Folder panel).

## Open

- [ ] Closed-box loudspeaker system (`comp.ClosedBox`): tests against the standard closed-box formulas
  - [x] Sound pressure level at 1 m against the response of Small (`tests\ClosedBoxTest\ClosedBoxTest.m`, 2026-09-24)
  - [ ] Electrical impedance against the standard formulas
  - [ ] Excursion of the diaphragm against the standard formulas (`result.DiaphragmExcursion`, added 2026-09-26)
- [ ] FEA-enclosure loudspeaker system (`comp.FeaEnclosure`): the same tests, against FEA simulation results
  - [ ] Simulation results from FEA (by the user)
  - [ ] Sound pressure level at 1 m
  - [ ] Electrical impedance
  - [ ] Excursion of the diaphragm
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


## Other

- [ ] Support radiation angles other than `"2pi"` (postponed on 2026-09-24: only `"2pi"` for now)
  - [ ] Extend the `RadiationAngle` validation in `lspsys` and the `ra == "2pi"` branches in the enclosures
  - [ ] Add the solid angle to the `switch` in `result.get.Pressure`
