%[text] # Documentation hierarchy
%[text] **J.G. Vermond, JVsound**
%[text] ## Hierarchy in documentation folder of Loudspeaker System Toolbox
%[text] Directly in the 'toolbox' folder there is a 'doc' folder, which contains all documentation for the toolbox.
%[text] - First subdivision (folders directly in 'doc'): folders for each class, namespace, or standalone function directly located in the 'toolbox' directory, with the exception of the 'doc' folder itself, which is neither a class, namespace, nor function. The folders have the same name as the class, namespace, or function they document, in lowercase (for example `doc/comp/driver` for `comp.Driver`).
%[text] - Inside a class or function folder: a single live script file describing that class or function (see 'Filename conventions' below), plus a 'helperfiles' subfolder.
%[text] - Inside a namespace folder: **the same structure recurses one level down** — one subfolder per class/function that lives in that namespace, each again containing its own live script and its own 'helperfiles' subfolder. A namespace folder does not itself hold loose live script files; it only holds class/function subfolders (and, if the namespace contains nested namespaces, further namespace subfolders, recursing the same way).
%[text] - Each documentation folder (class, function, or namespace) gets its own subfolder called 'helperfiles', for figures, additional info etc. This keeps helper files unambiguous even for namespaces with several classes, since each class keeps its own 'helperfiles'.
%[text] - A class or function documentation folder may also contain a `methods` subfolder. Only public instance methods substantial enough to warrant their own page go here (trivial accessors don't) — each gets its own subfolder inside `methods`, named after it, again recursing the same class/function pattern one level down: `methods/<methodname>doc/<methodname>doc.m` plus its own `helperfiles` subfolder.
%[text] - `doc/GettingStarted.m` is reserved by MathWorks' own toolbox-packaging convention (used by `packageToolbox`/the `matlab-package-toolbox` skill, following [mathworks/toolboxdesign](https://github.com/mathworks/toolboxdesign)) as the single onboarding script shown automatically on installation. It coexists directly inside `doc/` alongside the class/namespace subfolders described above — never repurpose or overwrite it for class documentation, and it must keep running in under 5 seconds without user interaction.
%[text] - `doc/overview.m` is the landing live script for the whole hierarchy: a short page that links to every top-level class and namespace documentation folder, so a reader does not have to discover the structure by browsing folders.
%[text] - `doc/symbols.m` is a nomenclature reference: a single table, sorted alphabetically by symbol, listing every physical quantity's mathematical symbol (in LaTeX), unit and the MATLAB property or method that holds it. It coexists directly inside `doc/`, like `GettingStarted.m` and `overview.m`, since it spans more than one class. \
%[text] ## Filename conventions
%[text] - A documentation file is named as the class, namespace-member, or function it documents, all lowercase, with the literal suffix `doc` appended directly (no separator): `<name>doc.m`. Examples: `lspsysdoc.m`, `driverdoc.m`, `enclosuredoc.m`. This applies at every nesting level, including inside namespace subfolders. \
%[text] ## Links between documentation files
%[text] Live scripts have no native relative-path link to another file: a markdown link whose target is a relative file path is not resolved as a file link. Use a `matlab:` link that opens the target with `open`, and build the target path from an anchor on the MATLAB path instead of hard-coding it. Pattern (the label is the link text; the path segments after `'doc'` follow the documentation hierarchy above):
%[text] ```matlabCodeExample
%[text] [label](matlab:open(fullfile(fileparts(fileparts(which('lspsys'))),'doc','lspsys','lspsysdoc.m')))
%[text] ```
%[text] - `which('lspsys')` locates the toolbox root through a class that is always on the MATLAB path, both in the development project and in an installed (packaged) toolbox. The two `fileparts` calls strip the file name and the `@lspsys` folder, leaving the `toolbox` folder; the rest of the path is built with `fullfile` relative to it.
%[text] - Do **not** hard-code absolute paths. This is what Insert Hyperlink, Existing file, stores; it breaks as soon as the project is moved or the toolbox is installed elsewhere.
%[text] - Do **not** use `matlab:open` with a bare file name. It relies on every `doc` subfolder being on the MATLAB path: in the project that is a manually maintained list (new folders are not added automatically), and a packaged toolbox does not add `doc` folders to the path by default.
%[text] - Do **not** use `currentProject().RootFolder`. An installed toolbox is not opened as a project, so it fails (or points at an unrelated project) for other users.
%[text] - Requirement: the `doc` folder must be packaged as a sibling of the class folders (inside the toolbox files), so the same anchor-relative path exists in the installed toolbox. If `lspsys` is ever renamed or moved, update the anchor in every link. \
%[text] ## Relation to MathWorks' own toolbox documentation conventions
%[text] These per-class/per-namespace live scripts are the toolbox's **deep reference layer**. They complement, and do not replace, two other layers that MathWorks' toolbox-packaging conventions expect ([mathworks/toolboxdesign](https://github.com/mathworks/toolboxdesign), surfaced locally by the `matlab-package-toolbox` skill):
%[text] - **Inline help** (H1 line + syntax paragraphs in the `classdef`/function file itself) — what answers `help ClassName` / `doc ClassName` on the command line. Covered separately by the `matlab-write-help` skill/guidelines, not by this hierarchy.
%[text] - **`doc/GettingStarted.m`** — single quick-start script auto-shown on install (see above).
%[text] - **`toolbox/examples/`** — runnable examples as live scripts, see 'Examples' below. \
%[text] If this toolbox is ever packaged as an installable add-on, keep these three layers and this documentation hierarchy distinct rather than merging them. \\
%[text] ## Examples
%[text] Examples follow MathWorks' toolbox design ([mathworks/toolboxdesign](https://github.com/mathworks/toolboxdesign)): "We recommend using MATLAB Live Scripts to show how to use different parts of your toolbox and including them in an `examples` folder under the toolbox folder."
%[text] - Examples live in `toolbox/examples`, a sibling of 'doc' and the class folders, so they are packaged with the toolbox. They are not part of the documentation hierarchy above.
%[text] - Each example is one live script in the plain-text format (`.m`), named like a function in lowerCamelCase after what it shows (for example `closedBoxExample.m`; MathWorks' own example is `usingAdd.mlx`). Supporting files go in `toolbox/examples/helperfiles`.
%[text] - An example does not depend on files in 'tests', which is not packaged: it creates everything it needs itself.
%[text] - Documentation pages may link to an example with the `which('lspsys')` anchor, with `'examples'` instead of `'doc'` after the toolbox folder. \
%[text] ## Tests (outside the documentation hierarchy)
%[text] Tests are **not** part of the documentation hierarchy above and do not live in 'toolbox/doc'. The tests are kept few and alike, so that they stay easy to understand:
%[text] - `tests` sits directly in the project root, as a sibling of 'toolbox', 'conventions' and 'sandbox'. It is deliberately **outside** 'toolbox', so it is not packaged with the toolbox.
%[text] - There is one class-based `matlab.unittest` test class per complete enclosure: `tests/ClosedBoxTest/ClosedBoxTest.m` for `comp.ClosedBox`, against the standard closed-box formulas (R. H. Small), and `tests/FeaEnclosureTest/FeaEnclosureTest.m` for `comp.FeaEnclosure`, against FEA simulation results. Both have the same three tests: the sound pressure level at 1 m, the electrical impedance and the excursion of the diaphragm. A test class is named after the class it tests, without its namespace, with the suffix `Test`.
%[text] - Each test class has its own folder in 'tests', named after the test class, with the test class and a 'helperfiles' subfolder for the reference data that only this test uses (for example the Ansys project of `FeaEnclosureTest`).
%[text] - A test class has no separate documentation page: the help of the classdef explains what each test checks, the reference and its source, the tolerance and why, and how to run it.
%[text] - `tests/common` holds what is not specific to one test: `tests/common/helperfiles` for reference data and helper functions that several tests use (for example the datasheet of the test driver and `createTestDriver`, which returns that driver), and `tests/common/doc` for working instructions and their tools, which follow the folder layout of 'toolbox/doc' (`tests/common/doc/<name>/<name>doc.m` plus a 'helperfiles' subfolder). `tests/common` holds no test classes.
%[text] - `buildfile.m` in the project root is kept as short as possible. `buildtool` runs the tests; `buildtool package` runs the tests and then packages 'toolbox' into 'release/LoudspeakerSystemToolbox.mltbx', which git ignores. `runtests("tests",IncludeSubfolders=true)` also runs the tests; without `IncludeSubfolders` it does not look in the test folders.
%[text] - Documentation pages in 'toolbox/doc' must **not** link to files in 'tests'. 'tests' is not packaged, so such a link would break in an installed toolbox. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline","rightPanelPercent":40}
%---
