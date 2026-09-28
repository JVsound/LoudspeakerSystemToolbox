%[text] # Classdef conventions
%[text] **J.G. Vermond, JVsound**
%[text] This document holds five conventions for writing a class in the Loudspeaker System Toolbox. A class follows the layout of the template that MATLAB generates for File \> New \> Class. Property validation is not part of that template; it is added to it. Names, spaces and line length follow the Rules of the [MATLAB Coding Guidelines](https://github.com/mathworks/MATLAB-Coding-Guidelines) from MathWorks, version 1.0, which is the latest official version (checked against the `main` branch, commit 76fe090, 2026-07-22). The guidelines do not number their Rules, so a Rule is cited by its title in the guidelines. The example shows the layout and the property validation, and its properties are taken from the `lspsys` class.
%%
%[text] ## Example
%[text] ```matlabCodeExample
%[text] classdef Name
%[text]     %NAME Summary
%[text]     %   Description
%[text] 
%[text]     properties
%[text]         Frequency (1,:) double {mustBePositive} = logspace(log10(2e1),log10(2e4),1e3); % Frequencies in [Hz]
%[text]         SourceVoltage (1,1) double {mustBePositive} = 2.83; % Source voltage in [V]
%[text]         RadiationAngle (1,1) string {mustBeMember(RadiationAngle,"2pi")} = "2pi"; % Radiation angle
%[text]         Enclosure (1,1) comp.Enclosure = comp.ClosedBox; % Enclosure of the loudspeaker
%[text]     end
%[text] 
%[text]     properties (Dependent, Hidden)
%[text]         AngularFrequency % Angular frequency in [rad/s]
%[text]         NumFrequencies % Number of frequencies
%[text]     end
%[text] 
%[text]     methods
%[text]         function obj = Name(inputArg1,inputArg2)
%[text]             %NAME Summary
%[text]             %   Description
%[text]             obj.SourceVoltage = inputArg1 + inputArg2;
%[text]         end
%[text] 
%[text]         function val = get.AngularFrequency(obj)
%[text]             %ANGULARFREQUENCY Angular frequency in [rad/s]
%[text]             val = obj.Frequency*2*pi;
%[text]         end
%[text] 
%[text]         function val = get.NumFrequencies(obj)
%[text]             %NUMFREQUENCIES Number of frequencies
%[text]             val = numel(obj.Frequency);
%[text]         end
%[text] 
%[text]         function outputArg = method1(obj,inputArg)
%[text]             %METHOD1 Summary
%[text]             %   Description
%[text]             outputArg = obj.SourceVoltage + inputArg;
%[text]         end
%[text]     end
%[text] end
%[text] ```
%%
%[text] ## Layout of the template
%[text] - Indentation is 4 spaces per level.
%[text] - The H1 line and the help lines are comments directly below the `classdef` line and below the `function` line of a method. They are indented one level deeper than the `classdef` or `function` line above them; for a method that is level with its body.
%[text] - The name in the H1 line is written in capitals (`%NAME`, `%METHOD1`).
%[text] - The blocks appear in this order: `properties`, `properties (Dependent, Hidden)`, then `methods`. In `methods` the constructor comes first, then the `get.` methods.
%[text] - There is one blank line between the blocks and between the methods (Rules *Around property blocks*, *Around method blocks* and *Around methods*). \
%%
%[text] ## Property validation (added to the template)
%[text] - Validation is defined on the property line in the `properties` block. Methods do not get an `arguments` block, with one exception: a method that accepts optional Name-Value arguments (called as `obj.method(Name=Value)`) must declare them in an `arguments` block. No method in the toolbox uses this at the moment. The `arguments` block is the simplest way in MATLAB to parse, validate and give defaults to Name-Value arguments, instead of `varargin` with `inputParser`.
%[text] - In that `arguments` block, the Name-Value arguments are the fields of one structure with a name that says what they hold (for example `limits.Power` for the limits of a calculation); MATLAB passes them as the fields of that structure, not as separate variables. Each line gives the size, class, validation functions, default value and a comment at the end of the line, like a property line. The other inputs of the method are listed in the block without validation.
%[text] - Each property is one line: the name, the size, the class, the validation functions between braces, and the default value, in that order. Size, class, validation functions and default value are left out where they are not needed.
%[text] - A comment at the end of the line describes the property (the help line).
%[text] - `Dependent` properties have no validation: no size, class, validation functions or default value. They only get a comment at the end of the line with help text, and are computed in a `get.` method.
%[text] - Commas inside the size and inside the validation functions have no space after them (`(1,:)`, `mustBeMember(RadiationAngle,"2pi")`). \
%%
%[text] ## Naming (MathWorks rules)
%[text] Names follow the naming Rules of the MATLAB Coding Guidelines. The table gives the title of each Rule.
%[text:table]
%[text] | Element | Casing | Guideline |
%[text] | --- | --- | --- |
%[text] | Class in a namespace | UpperCamelCase (`comp.Driver`) | Class name casing |
%[text] | Class in the global namespace | like a function: lowercase or lowerCamelCase (`lspsys`, `result`) | Class name casing, Function name casing |
%[text] | Method | lowerCamelCase or lowercase; lowerCamelCase for multi-word names (`createResult`) | Method name casing |
%[text] | Property | UpperCamelCase (`SourceVoltage`) | Property name casing |
%[text] | Event | UpperCamelCase | Event name casing |
%[text] | Variable | lowerCamelCase; a leading capital is allowed for short mathematical symbols (`Te`, `Qd`) | Variable name casing |
%[text:table]
%[text] - Names of functions, classes, methods, properties and other elements of a programming interface are at most 32 characters long (Rule *Name length for functions and other programming interface elements*). Variable names are at most 32 characters long too (Rule *Variable name length*).
%[text] - In the example, `Name` stands for the name of the class: it is written like `Name` in a namespace and like a function (`name`) in the global namespace. The other names in the example follow the table. \
%%
%[text] ## Spaces (MathWorks rules)
%[text] Spaces follow the spacing rules of the MATLAB Coding Guidelines, with one exception: the rule for the space after a comma (*Spaces after commas, & semicolons*) is listed in the table but not followed.
%[text:table]{"columnWidths":[324,236,-1]}
%[text] | Operator | Spacing | Guideline |
%[text] | --- | --- | --- |
%[text] | Indentation | 4 spaces per level, no tabs | *Spaces vs. tabs*, *Indentation* |
%[text] | Inside parentheses, brackets and braces | no space after the opening or before the closing character (`f(x)`, `[1 2 3]`, `c{k}`) | *Spaces inside grouping operators* |
%[text] | After a comma or semicolon | MathWorks: one space, except at the end of a line (`f(a, b)`). **Not followed here for commas:** they are written without a space (`f(a,b)`, `(1,:)`), as in the MATLAB class template | *Spaces after commas, & semicolons* |
%[text] | End of a line | no trailing whitespace | *Spaces at the end of lines* |
%[text] | Around `=` in an assignment | one space on each side (`x = 3`); none in `Name=Value` | *Spaces around assignment operator* |
%[text] | Around relational operators (`<`, `<=`, `==`, `~=`, `>`, `>=`) | one space on each side (`if x <= 3`) | *Spaces around relational operators* |
%[text] | Around logical AND and OR operators | one space on each side (`a & b`, `a && b`) | *Spaces around logical operators* |
%[text] | Around the colon operator | no spaces, also not in the operands (`2:2:10`, `A(2:end-1)`) | *Spaces around colon operator* |
%[text] | Multiply, divide and power (`*`, `.*`, `/`, `./`, `^`, `.^`) | no spaces (`2*pi*f/c`, `x.^2`) | *Spaces around multiply, divide, & exponent operators* |
%[text] | Plus and minus on the right of an assignment | one space around the operators between the main terms (`z = a*b + c*d`, `z = (a+b) + exp(c+d)`) | *Spaces around plus and minus operators* |
%[text] | Plus and minus elsewhere: inside parentheses, in function arguments, in indices and in a comparison | no spaces (`exp(a+b)`, `A(k-1)`, `w = y > x+1`) | *Spaces around plus and minus operators* |
%[text] | Unary plus, minus and not | no space after the operator (`x = -1`, `y = ~flag`) | *Spaces after unary operators* |
%[text:table]
%[text] - The example above follows this table, for instance `obj.Frequency*2*pi`, `inputArg1 + inputArg2` and, for the commas, `logspace(log10(2e1),log10(2e4),1e3)`. \
%%
%[text] ## Line length (MathWorks rule)
%[text] Every line in a class file is at most 120 characters long (Rule *Line length*, checked by the Code Analyzer check `LLMNC`). The Rule covers code and comment lines alike, so it also covers the H1 line, the help lines and the comment at the end of a property line. There are no exceptions: a line that is too long is shortened or split.
%[text] - The limit counts the indentation: it is the total length of the line.
%[text] - Shorten the help text at the end of a property line instead of moving it to another line.
%[text] - Split long code with `...` after a comma, after a space or at a binary operator (Best Practice *Line breaks*) and indent the continuation line one level. \

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
