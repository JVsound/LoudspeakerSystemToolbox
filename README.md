# Loudspeaker System Toolbox

[![MATLAB](https://img.shields.io/badge/MATLAB-R2025a+-blue.svg)]()

Model and simulate loudspeaker systems in the frequency domain, with a variety in enclosure types. A driver
(`comp.Driver`) is mounted in an enclosure (a subclass of `comp.Enclosure`) and combined into a loudspeaker system
(`lspsys`) that calculates the response of the system: the electrical impedance, the sound pressure level, the
excursion of the diaphragm and the highest level that the limits of the driver allow. The first release has a closed
box (`comp.ClosedBox`) and an enclosure described by the results of an FEA model in Ansys (`comp.FeaEnclosure`).

## Installation

### From the toolbox file
Download `LoudspeakerSystemToolbox.mltbx` and double-click it in MATLAB, or install it from the Add-On Manager.
MATLAB R2025a or newer is needed: the documentation pages are live scripts in the plain-text format.

### From source
1. Clone this repository.
2. Open `lspsystbx.prj` in MATLAB.
3. Run `buildtool` to run the tests.

## Getting Started

Open `toolbox/doc/GettingStarted.m` for an interactive introduction, or run:

```matlab
open GettingStarted
```

The documentation overview links to the page of every class:

```matlab
open overview
```

## Classes

| Class | Description |
|-------|-------------|
| `lspsys` | Loudspeaker system object |
| `result` | Results of a loudspeaker system calculation |
| `comp.Driver` | Class definition for a loudspeaker driver |
| `comp.Enclosure` | Base class for the enclosure of a loudspeaker driver (abstract) |
| `comp.ClosedBox` | Closed-box enclosure of a loudspeaker driver |
| `comp.FeaEnclosure` | Enclosure described by the results of an FEA model in Ansys |

## Examples

See the `toolbox/examples/` folder for live script examples:
- `closedBoxExample.m` — a closed box: impedance, sound pressure level and the effect of the box volume.
- `feaEnclosureExample.m` — an enclosure with a horn at the front, from the results of an FEA model, with the
  maximum sound pressure level.

## License

To be decided.

---

## For Contributors

- The MATLAB Project `lspsystbx.prj` holds the files; `toolbox/` is what the toolbox package contains.
- `buildtool` runs the tests in `tests/` (`ClosedBoxTest` against the closed-box theory of R. H. Small and
  `FeaEnclosureTest` against FEA results). `buildtool package` runs the tests first and then packages `toolbox/` into
  `release/LoudspeakerSystemToolbox.mltbx`, which git ignores.
- Code and documentation follow the conventions in `conventions/`: `classdefconventions.m`,
  `documentationdefault.m` and `documentationhierarchy.m`.
- The interface specification and the dependency manifest of the toolbox are in `buildUtilities/`.
