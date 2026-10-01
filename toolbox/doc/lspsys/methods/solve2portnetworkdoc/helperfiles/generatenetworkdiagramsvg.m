function svgPath = generatenetworkdiagramsvg(svgPath, options)
    %GENERATENETWORKDIAGRAMSVG - Write the 2-port network diagram of the loudspeaker system as SVG
    %   GENERATENETWORKDIAGRAMSVG() writes networkdiagramfourport.svg next to
    %   this file.
    %
    %   GENERATENETWORKDIAGRAMSVG(svgPath) writes the diagram to svgPath.
    %
    %   GENERATENETWORKDIAGRAMSVG(...,Layout=L) also specifies which diagram
    %   is drawn. L is "fourport" (default), the equivalent circuit with the
    %   2-port T_a that holds 4-ports on a front, ambient pressure and rear
    %   conductor, "fourportdetail", the inside of T_a with the 4-ports T_a,e
    %   of the enclosure and T_a,rad of the radiation, "closedbox", the
    %   inside of T_a for comp.ClosedBox, "feaenclosure", the inside of T_a for
    %   comp.FeaEnclosure, or "definition", one generic 2-port
    %   network with its ports to define the transmission matrix. The diagram
    %   is written to networkdiagram<L>.svg by default.
    %
    %   svgPath = GENERATENETWORKDIAGRAMSVG(...) also returns the path of the
    %   written file.
    %
    %   The diagram shows the electrical, mechanical and acoustical 2-port
    %   networks of solve2PortNetwork, for documentation only. The element
    %   icons are the SVG files next to this file, copied from the Simscape
    %   Foundation library (matlabroot\toolbox\physmod\simscape\library\m\
    %   +foundation\+electrical). Every icon is drawn at the same percentage
    %   (iconPercent) of the size that its Simscape SVG file declares, so the
    %   icons keep the proportions of Simscape in every diagram; wires lead
    %   from the icons to the conductors. The labels are the symbols of symbols.m,
    %   typeset with the MathJax that ships with MATLAB, the same as the
    %   equations in a live script, which runs in headless Chrome. The PNG
    %   shown in solve2portnetworkdoc.m is rendered from the SVG with a
    %   browser, for example headless Chrome.

    arguments
        svgPath (1,1) string = ""
        options.Layout (1,1) string {mustBeMember(options.Layout, ...
            ["fourport","fourportdetail","closedbox","feaenclosure","definition"])} = "fourport"
    end

    layout = options.Layout;
    if svgPath == ""
        svgPath = fullfile(fileparts(mfilename("fullpath")), "networkdiagram" + layout + ".svg");
    end

    ink = "#1f4e9c";
    iconFolder = fileparts(mfilename("fullpath"));

    % Size of every icon as a fraction of the size its Simscape SVG file declares; at this value a resistor is
    % 70 px long
    iconPercent = 0.2083;
    readlibraryicon = @(name) readicon(fullfile(iconFolder, name), ink, iconPercent);
    resistor = readlibraryicon("resistor.svg");
    inductor = readlibraryicon("inductor.svg");
    capacitor = readlibraryicon("capacitor.svg");
    gyrator = readlibraryicon("gyrator.svg");
    transformer = readlibraryicon("ideal_transformer.svg");
    source = readlibraryicon("ac_voltage.svg");
    reference = readlibraryicon("reference.svg");
    openCircuit = readlibraryicon("open_circuit.svg");

    % Rails (top, bottom) and label heights
    top = 100;
    bottom = 240;
    middle = (top + bottom) / 2 + 8;
    above = top - 14;

    parts = strings(0, 1);
    labels = cell(0, 4);
    wire = @(points) sprintf('<polyline points="%s" fill="none" stroke="%s" stroke-width="1.5"/>', ...
        strjoin(compose("%g,%g", points(:, 1), points(:, 2)), " "), ink);
    arrow = @(x, y) sprintf('<path d="M%g,%g L%g,%g L%g,%g z" fill="%s"/>', x - 5, y - 5, x + 5, y, ...
        x - 5, y + 5, ink);
    arrowLeft = @(x, y) sprintf('<path d="M%g,%g L%g,%g L%g,%g z" fill="%s"/>', x + 5, y - 5, x - 5, y, ...
        x + 5, y + 5, ink);

    if layout == "definition"
        % One generic 2-port network: flow x and effort y at port 1 (left) and port 2 (right)
        labels(end+1, :) = {"\mathbf{T}", 182, 68, "start"};
        parts(end+1) = twoport(170, 350, 0, "", ink);
        labels(end+1, :) = {"\begin{matrix}A & B \\ C & D\end{matrix}", 260, middle - 8, "middle"};
        for y = [top bottom]
            parts(end+1) = wire([60 y; 225 y]); %#ok<AGROW>
            parts(end+1) = wire([295 y; 460 y]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, 60, y, 180, [5.4 22.5]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, 460, y, 0, [5.4 22.5]); %#ok<AGROW>
        end
        labels(end+1, :) = {"y_1", 110, middle, "middle"};
        labels(end+1, :) = {"x_1", 110, above, "middle"};
        parts(end+1) = arrow(110, top);
        labels(end+1, :) = {"y_2", 410, middle, "middle"};
        labels(end+1, :) = {"x_2", 410, above, "middle"};
        parts(end+1) = arrow(410, top);
        parts(end+1) = captiontext(110, 280, "port 1");
        parts(end+1) = captiontext(410, 280, "port 2");
        writesvg(svgPath, parts, labels, 520, 310);
        return
    end

    if layout == "feaenclosure"
        % The inside of T_a for comp.FeaEnclosure: in the enclosure 4-port T_a,e, the load Z_a,r of the rear of
        % the diaphragm between the rear conductor and the reference; in the radiation 4-port T_a,rad, the load
        % Z_a,f of the front between the front conductor and the reference. Both loads come from the FEA model and
        % are drawn as boxes. The layout is the layout of "closedbox", with the rear load mirrored to the front load.
        reference3 = (top + bottom) / 2;
        below = bottom + 28;
        canvasWidth = 870;
        mirror = @(x) canvasWidth - x;
        dot = @(x, y) sprintf('<circle cx="%g" cy="%g" r="3.5" fill="%s"/>', x, y, ink);
        parts(end+1) = frame(240, 400);
        labels(end+1, :) = {"\mathbf{T}_{a,e}", 252, 68, "start"};
        parts(end+1) = frame(470, 630);
        labels(end+1, :) = {"\mathbf{T}_{a,rad}", 482, 68, "start"};
        for y = [top bottom]
            parts(end+1) = placeicon(openCircuit, 60, y, 180, [5.4 22.5]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, mirror(60), y, 0, [5.4 22.5]); %#ok<AGROW>
            parts(end+1) = wire([60 y; mirror(60) y]); %#ok<AGROW>
        end
        parts(end+1) = wire([200 reference3; mirror(200) reference3]);
        parts(end+1) = placeicon(reference, 200, reference3, 180, [16 1417]);
        parts(end+1) = placeicon(reference, mirror(200), reference3, 0, [16 1417]);

        % Rear load Z_a,r in T_a,e and front load Z_a,f in T_a,rad, both to the reference
        parts(end+1) = impedancebox(mirror(530), reference3, bottom, ink);
        parts(end+1) = dot(mirror(530), reference3);
        parts(end+1) = dot(mirror(530), bottom);
        labels(end+1, :) = {"Z_{a,r}", mirror(530) + 20, (reference3 + bottom) / 2 + 8, "start"};
        parts(end+1) = impedancebox(530, top, reference3, ink);
        parts(end+1) = dot(530, top);
        parts(end+1) = dot(530, reference3);
        labels(end+1, :) = {"Z_{a,f}", 550, (top + reference3) / 2 + 8, "start"};
        labels(end+1, :) = {"U_d", 100, above, "middle"};
        parts(end+1) = arrow(100, top);
        labels(end+1, :) = {"U_d", 100, below, "middle"};
        parts(end+1) = arrowLeft(100, bottom);
        labels(end+1, :) = {"p_1", 100, middle, "middle"};
        labels(end+1, :) = {"U_f", 435, above, "middle"};
        parts(end+1) = arrow(435, top);
        labels(end+1, :) = {"U_r", 435, below, "middle"};
        parts(end+1) = arrowLeft(435, bottom);
        labels(end+1, :) = {"p_f", 435, top + 26, "middle"};
        labels(end+1, :) = {"p_r", 435, bottom - 18, "middle"};
        labels(end+1, :) = {"U_2", mirror(100), above, "middle"};
        parts(end+1) = arrow(mirror(100), top);
        labels(end+1, :) = {"U_2", mirror(100), below, "middle"};
        parts(end+1) = arrowLeft(mirror(100), bottom);
        labels(end+1, :) = {"p_2", mirror(100), middle, "middle"};
        parts(end+1) = sprintf(['<rect x="135" y="8" width="%g" height="294" rx="4" fill="none" ' ...
            'stroke="#8a96a8" stroke-width="1.5" stroke-dasharray="8 5"/>'], mirror(135) - 135);
        labels(end+1, :) = {"\mathbf{T}_a", 145, 32, "start"};
        writesvg(svgPath, parts, labels, canvasWidth, 320);
        return
    end

    if layout == "closedbox"
        % The inside of T_a for comp.ClosedBox: in the enclosure 4-port T_a,e, the compliance of the box between
        % the rear conductor and the reference; in the radiation 4-port T_a,rad, the radiation impedance of the
        % diaphragm between the front conductor and the reference, drawn as a box as in Beranek. The layout is
        % the mirror symmetric layout of "fourportdetail".
        reference3 = (top + bottom) / 2;
        below = bottom + 28;
        canvasWidth = 870;
        mirror = @(x) canvasWidth - x;
        dot = @(x, y) sprintf('<circle cx="%g" cy="%g" r="3.5" fill="%s"/>', x, y, ink);
        parts(end+1) = frame(240, 400);
        labels(end+1, :) = {"\mathbf{T}_{a,e}", 252, 68, "start"};
        parts(end+1) = frame(470, 630);
        labels(end+1, :) = {"\mathbf{T}_{a,rad}", 482, 68, "start"};
        for y = [top bottom]
            parts(end+1) = placeicon(openCircuit, 60, y, 180, [5.4 22.5]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, mirror(60), y, 0, [5.4 22.5]); %#ok<AGROW>
        end
        parts(end+1) = wire([60 top; mirror(60) top]);
        parts(end+1) = wire([200 reference3; mirror(200) reference3]);
        parts(end+1) = placeicon(reference, 200, reference3, 180, [16 1417]);
        parts(end+1) = placeicon(reference, mirror(200), reference3, 0, [16 1417]);

        % Rear conductor: the acoustic mass Ma of the air load in series, then the compliance Ca to the reference
        parts(end+1) = wire([60 bottom; 252 bottom]);
        parts(end+1) = placeicon(inductor, 252, bottom, 0, [5.4 90]);
        labels(end+1, :) = {"M_a", 283, below, "middle"};
        parts(end+1) = wire([314 bottom; mirror(60) bottom]);
        capacitorLength = 162;
        parts(end+1) = wire([350 reference3; 350 (reference3 + bottom - capacitorLength*capacitor.Scale)/2]);
        parts(end+1) = placeicon(capacitor, 350, (reference3 + bottom - capacitorLength*capacitor.Scale)/2, 90, [9 90]);
        parts(end+1) = wire([350 (reference3 + bottom + capacitorLength*capacitor.Scale)/2; 350 bottom]);
        parts(end+1) = dot(350, reference3);
        parts(end+1) = dot(350, bottom);
        labels(end+1, :) = {"C_a", 366, (reference3 + bottom) / 2 + 8, "start"};
        parts(end+1) = impedancebox(530, top, reference3, ink);
        parts(end+1) = dot(530, top);
        parts(end+1) = dot(530, reference3);
        labels(end+1, :) = {"Z_{rad}", 550, (top + reference3) / 2 + 8, "start"};
        labels(end+1, :) = {"U_d", 100, above, "middle"};
        parts(end+1) = arrow(100, top);
        labels(end+1, :) = {"U_d", 100, below, "middle"};
        parts(end+1) = arrowLeft(100, bottom);
        labels(end+1, :) = {"p_1", 100, middle, "middle"};
        labels(end+1, :) = {"U_f", 435, above, "middle"};
        parts(end+1) = arrow(435, top);
        labels(end+1, :) = {"U_r", 435, below, "middle"};
        parts(end+1) = arrowLeft(435, bottom);
        labels(end+1, :) = {"p_f", 435, top + 26, "middle"};
        labels(end+1, :) = {"p_r", 435, bottom - 18, "middle"};
        labels(end+1, :) = {"U_2", mirror(100), above, "middle"};
        parts(end+1) = arrow(mirror(100), top);
        labels(end+1, :) = {"U_2", mirror(100), below, "middle"};
        parts(end+1) = arrowLeft(mirror(100), bottom);
        labels(end+1, :) = {"p_2", mirror(100), middle, "middle"};
        parts(end+1) = sprintf(['<rect x="135" y="8" width="%g" height="294" rx="4" fill="none" ' ...
            'stroke="#8a96a8" stroke-width="1.5" stroke-dasharray="8 5"/>'], mirror(135) - 135);
        labels(end+1, :) = {"\mathbf{T}_a", 145, 32, "start"};
        writesvg(svgPath, parts, labels, canvasWidth, 320);
        return
    end

    if layout == "fourportdetail"
        % The inside of the 2-port T_a: the 4-port T_a,e of the enclosure and the 4-port T_a,rad of the radiation
        % on the front, reference and rear conductor. Port 1 (left) and port 2 (right) are the front and rear
        % conductor; the 4-ports lead all flow to the reference, so port 2 stays open. The drawing is mirror
        % symmetric around the middle of the canvas.
        reference3 = (top + bottom) / 2;
        below = bottom + 28;
        canvasWidth = 870;
        mirror = @(x) canvasWidth - x;
        spec = struct("blockLefts", [240 470], "names", ["\mathbf{T}_{a,e}" "\mathbf{T}_{a,rad}"], ...
            "captions", ["enclosure" "radiation"], "gapX", 435, "frontFlows", "U_f", ...
            "rearFlows", "U_r", "frontPressures", "p_f", "rearPressures", "p_r");
        draw = struct("wire", wire, "arrow", arrow, "arrowLeft", arrowLeft, "ink", ink, ...
            "top", top, "reference", reference3, "bottom", bottom);
        [parts, labels] = drawfourports(parts, labels, spec, draw);
        for y = [top bottom]
            parts(end+1) = wire([60 y; 285 y]); %#ok<AGROW>
            parts(end+1) = wire([mirror(285) y; mirror(60) y]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, 60, y, 180, [5.4 22.5]); %#ok<AGROW>
            parts(end+1) = placeicon(openCircuit, mirror(60), y, 0, [5.4 22.5]); %#ok<AGROW>
        end
        parts(end+1) = wire([200 reference3; 285 reference3]);
        parts(end+1) = placeicon(reference, 200, reference3, 180, [16 1417]);
        parts(end+1) = wire([mirror(285) reference3; mirror(200) reference3]);
        parts(end+1) = placeicon(reference, mirror(200), reference3, 0, [16 1417]);
        labels(end+1, :) = {"U_d", 100, above, "middle"};
        parts(end+1) = arrow(100, top);
        labels(end+1, :) = {"U_d", 100, below, "middle"};
        parts(end+1) = arrowLeft(100, bottom);
        labels(end+1, :) = {"p_1", 100, middle, "middle"};
        labels(end+1, :) = {"U_2", mirror(100), above, "middle"};
        parts(end+1) = arrow(mirror(100), top);
        labels(end+1, :) = {"U_2", mirror(100), below, "middle"};
        parts(end+1) = arrowLeft(mirror(100), bottom);
        labels(end+1, :) = {"p_2", mirror(100), middle, "middle"};
        parts(end+1) = sprintf(['<rect x="135" y="8" width="%g" height="294" rx="4" fill="none" ' ...
            'stroke="#8a96a8" stroke-width="1.5" stroke-dasharray="8 5"/>'], mirror(135) - 135);
        labels(end+1, :) = {"\mathbf{T}_a", 145, 32, "start"};
        writesvg(svgPath, parts, labels, canvasWidth, 320);
        return
    end

    % Electrical side: source and T_e, port 1 (e_g, i_g) and port 2
    sourceTop = (top + bottom - 243*source.Scale) / 2;
    parts(end+1) = wire([60 top; 60 sourceTop]);
    parts(end+1) = placeicon(source, 60, sourceTop, 90, [0 81]);
    parts(end+1) = wire([60 sourceTop + 243*source.Scale; 60 bottom]);
    labels(end+1, :) = {"e_g", 20, middle, "end"};
    labels(end+1, :) = {"i_g", 100, above, "middle"};
    parts(end+1) = arrow(100, top);
    parts(end+1) = frame(140, 360);
    labels(end+1, :) = {"\mathbf{T}_e", 152, 68, "start"};
    parts(end+1) = placeicon(resistor, 160, top, 0, [5.4 90]);
    labels(end+1, :) = {"R_e", 195, 145, "middle"};
    parts(end+1) = placeicon(inductor, 255, top, 0, [5.4 90]);
    labels(end+1, :) = {"L_e", 286, 145, "middle"};
    parts(end+1) = wire([60 top; 160 top]);
    parts(end+1) = wire([230 top; 255 top]);
    parts(end+1) = wire([317 top; 445 top]);
    parts(end+1) = wire([60 bottom; 445 bottom]);
    labels(end+1, :) = {"e_2", 395, middle, "middle"};
    labels(end+1, :) = {"i_2", 395, above, "middle"};
    parts(end+1) = arrow(395, top);

    % Electromechanical coupling T_bl, mechanical port 1
    parts(end+1) = frame(430, 650);
    labels(end+1, :) = {"\mathbf{T}_{bl}", 442, 68, "start"};
    parts(end+1) = placecoupler(gyrator, 445, 634, top, bottom, wire);
    labels(end+1, :) = {"Bl", 540, 275, "middle"};
    labels(end+1, :) = {"f_1", 685, middle, "middle"};
    labels(end+1, :) = {"u_1", 685, above, "middle"};
    parts(end+1) = arrow(685, top);

    % Mechanical side T_m, mechanical port 2
    parts(end+1) = frame(720, 1020);
    labels(end+1, :) = {"\mathbf{T}_m", 732, 68, "start"};
    parts(end+1) = placeicon(inductor, 740, top, 0, [5.4 90]);
    labels(end+1, :) = {"M_{ms}", 771, 145, "middle"};
    parts(end+1) = placeicon(resistor, 825, top, 0, [5.4 90]);
    labels(end+1, :) = {"R_{ms}", 860, 145, "middle"};
    parts(end+1) = placeicon(capacitor, 920, top, 0, [9 90]);
    labels(end+1, :) = {"C_{ms}", 944, 145, "middle"};
    parts(end+1) = wire([634 top; 740 top]);
    parts(end+1) = wire([802 top; 825 top]);
    parts(end+1) = wire([895 top; 920 top]);
    parts(end+1) = wire([968 top; 1105 top]);
    parts(end+1) = wire([634 bottom; 1105 bottom]);
    labels(end+1, :) = {"f_2", 1055, middle, "middle"};
    labels(end+1, :) = {"u_2", 1055, above, "middle"};
    parts(end+1) = arrow(1055, top);

    % Mechanoacoustical coupling T_sd, acoustical port 1 (p_1)
    parts(end+1) = frame(1090, 1310);
    labels(end+1, :) = {"\mathbf{T}_{sd}", 1102, 68, "start"};
    parts(end+1) = placecoupler(transformer, 1105, 1294, top, bottom, wire);
    labels(end+1, :) = {"S_d", 1200, 275, "middle"};
    labels(end+1, :) = {"p_1", 1340, middle, "middle"};

    % Acoustical side as the 2-port T_a. Port 1 is the front (top) and rear (bottom) conductor, between
    % which T_sd floats, so p_1 = p_f1 - p_r1. Inside T_a, the 4-ports (layout "fourportdetail") lie on the
    % front, the ambient pressure (reference) and the rear conductor; they lead all flow to the reference.
    % Port 2 is the front and rear output, and stays open.
    reference3 = (top + bottom) / 2;
    below = bottom + 28;
    parts(end+1) = frame(1370, 1610);
    labels(end+1, :) = {"\mathbf{T}_a", 1382, 68, "start"};
    parts(end+1) = sprintf(['<rect x="1455" y="85" width="70" height="170" rx="3" fill="#ffffff" ' ...
        'stroke="%s" stroke-width="1.5"/>'], ink);
    parts(end+1) = captiontext(1490, 174, "4-ports");
    parts(end+1) = wire([1294 top; 1455 top]);
    parts(end+1) = wire([1294 bottom; 1455 bottom]);
    parts(end+1) = wire([1430 reference3; 1455 reference3]);
    parts(end+1) = placeicon(reference, 1430, reference3, 180, [16 1417]);
    parts(end+1) = wire([1525 reference3; 1550 reference3]);
    parts(end+1) = placeicon(reference, 1550, reference3, 0, [16 1417]);
    for y = [top bottom]
        parts(end+1) = wire([1525 y; 1680 y]); %#ok<AGROW>
        parts(end+1) = placeicon(openCircuit, 1680, y, 0, [5.4 22.5]); %#ok<AGROW>
    end
    labels(end+1, :) = {"U_d", 1340, above, "middle"};
    parts(end+1) = arrow(1340, top);
    labels(end+1, :) = {"U_d", 1340, below, "middle"};
    parts(end+1) = arrowLeft(1340, bottom);
    labels(end+1, :) = {"U_2", 1645, above, "middle"};
    parts(end+1) = arrow(1645, top);
    labels(end+1, :) = {"U_2", 1645, below, "middle"};
    parts(end+1) = arrowLeft(1645, bottom);
    labels(end+1, :) = {"p_2", 1645, middle, "middle"};
    canvasWidth = 1740;
    canvasHeight = 320;

    writesvg(svgPath, parts, labels, canvasWidth, canvasHeight);
end

function [parts, labels] = drawfourports(parts, labels, spec, draw)
    % Draw a cascade of 4-ports on the front, reference and rear conductor, with the labels at the gaps

    % Flows point right on the front conductor and left on the rear conductor. The pressures, relative to the
    frontPressureY = draw.top + 26;
    rearPressureY = draw.bottom - 18;
    above = draw.top - 14;
    below = draw.bottom + 28;
    blockCenters = spec.blockLefts + 80;
    for k = 1:numel(spec.blockLefts)
        parts(end+1) = twoport(spec.blockLefts(k), spec.blockLefts(k) + 160, 0, spec.captions(k), ...
            draw.ink); %#ok<AGROW>
        labels(end+1, :) = {spec.names(k), spec.blockLefts(k) + 12, 68, "start"}; %#ok<AGROW>
        if k < numel(spec.blockLefts)
            for y = [draw.top draw.reference draw.bottom]
                parts(end+1) = draw.wire([blockCenters(k) + 35 y; blockCenters(k+1) - 35 y]); %#ok<AGROW>
            end
        end
    end
    for k = 1:numel(spec.gapX)
        x = spec.gapX(k);
        labels(end+1, :) = {spec.frontFlows(k), x, above, "middle"}; %#ok<AGROW>
        parts(end+1) = draw.arrow(x, draw.top); %#ok<AGROW>
        labels(end+1, :) = {spec.rearFlows(k), x, below, "middle"}; %#ok<AGROW>
        parts(end+1) = draw.arrowLeft(x, draw.bottom); %#ok<AGROW>
        if spec.frontPressures(k) ~= ""
            labels(end+1, :) = {spec.frontPressures(k), x, frontPressureY, "middle"}; %#ok<AGROW>
        end
        if spec.rearPressures(k) ~= ""
            labels(end+1, :) = {spec.rearPressures(k), x, rearPressureY, "middle"}; %#ok<AGROW>
        end
    end
end

function writesvg(svgPath, parts, labels, canvasWidth, canvasHeight)
    % Typeset the labels, add them to the parts and write the SVG file
    texSvg = typesettex(string(labels(:, 1)));
    for k = 1:size(labels, 1)
        parts(end+1) = placetex(texSvg(k), labels{k, 2}, labels{k, 3}, labels{k, 4}); %#ok<AGROW>
    end

    header = sprintf(['<?xml version="1.0" encoding="UTF-8"?>\n' ...
        '<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="%d" ' ...
        'height="%d" viewBox="0 0 %d %d" role="img">\n' ...
        '<title>Loudspeaker System Toolbox 2-port network diagram</title>\n' ...
        '<rect width="100%%" height="100%%" fill="#ffffff"/>\n'], ...
        canvasWidth, canvasHeight, canvasWidth, canvasHeight);
    document = string(header) + strjoin(parts, newline) + newline + "</svg>" + newline;

    fileId = fopen(svgPath, "w", "n", "UTF-8");
    fwrite(fileId, char(document), "char");
    fclose(fileId);
    xmlread(svgPath);
end

function svg = impedancebox(x, yTop, yBottom, ink)
    % Draw an impedance as a box between two conductors, as in Beranek, with leads to both conductors
    boxHeight = 40;
    boxTop = (yTop + yBottom - boxHeight) / 2;
    svg = string(sprintf(['<polyline points="%g,%g %g,%g" fill="none" stroke="%s" stroke-width="1.5"/>\n' ...
        '<rect x="%g" y="%g" width="18" height="%g" fill="#ffffff" stroke="%s" stroke-width="1.5"/>\n' ...
        '<polyline points="%g,%g %g,%g" fill="none" stroke="%s" stroke-width="1.5"/>'], x, yTop, x, boxTop, ink, ...
        x - 9, boxTop, boxHeight, ink, x, boxTop + boxHeight, x, yBottom, ink));
end

function svg = captiontext(x, y, caption)
    % Write a caption in the sans-serif font of the block captions
    svg = string(sprintf(['<text x="%g" y="%g" text-anchor="middle" font-family="''Segoe UI'', Arial, ' ...
        'sans-serif" font-size="13" fill="#44546a">%s</text>'], x, y, caption));
end

function icon = readicon(file, ink, percent)
    % Read the shapes of a Simscape icon, restyle them with the diagram ink, and return them with the scale in
    % px per icon unit at the given percentage of the size that the file declares (width, in px or in inches,
    % over the width of its viewBox)
    text = fileread(file);
    header = regexp(text, '<svg\>[^>]*>', "match", "once");
    widthText = regexp(header, '\swidth="([\d.]+)(in)?"', "tokens", "once");
    declaredWidth = str2double(widthText{1});
    if widthText{2} == "in"
        declaredWidth = 96*declaredWidth;
    end
    viewBoxText = regexp(header, 'viewBox="([^"]*)"', "tokens", "once");
    viewBox = sscanf(viewBoxText{1}, "%f");
    styles = regexp(text, '\.(s[A-Z])\s*\{([^}]*)\}', "tokens");
    filledClasses = strings(0, 1);
    for k = 1:numel(styles)
        if contains(styles{k}{2}, "fill: #000000")
            filledClasses(end+1) = styles{k}{1}; %#ok<AGROW>
        end
    end
    shapes = regexp(text, '<(polyline|path|rect|ellipse)\>[^>]*/>', "match");
    for k = 1:numel(shapes)
        shapeClass = regexp(shapes{k}, 'class="([^"]*)"', "tokens", "once");
        isFilled = ~isempty(shapeClass) && any(shapeClass{1} == filledClasses);
        shape = regexprep(shapes{k}, '\s+(class|id|d:options|style)="[^"]*"', '');
        shape = regexprep(shape, '\s+', ' ');
        if isFilled
            fill = ink;
        elseif startsWith(shape, "<ellipse")
            fill = "#ffffff";
        else
            fill = "none";
        end
        style = sprintf(' fill="%s" stroke="%s" stroke-width="@STROKEWIDTH@"', fill, ink);
        shapes{k} = regexprep(shape, '^<(\w+)', ['<$1' char(style)]);
    end
    icon = struct("Shapes", strjoin(string(shapes), newline), "Scale", percent*declaredWidth/viewBox(3));
end

function svg = placecoupler(icon, left, right, top, bottom, wire)
    % Place a gyrator or transformer icon between the rails, its left terminals at x = left, with leads from its
    % four terminals (icon units x = 5.4 and 378, y = 141.3 and 416.7) to the rails, which continue to x = right
    halfHeight = (416.7 - 141.3) / 2 * icon.Scale;
    upper = (top + bottom) / 2 - halfHeight;
    lower = (top + bottom) / 2 + halfHeight;
    iconRight = left + (378 - 5.4) * icon.Scale;
    svg = strjoin([string(placeicon(icon, left, upper, 0, [5.4 141.3])), ...
        string(wire([left top; left upper])), string(wire([left lower; left bottom])), ...
        string(wire([iconRight upper; iconRight top; right top])), ...
        string(wire([iconRight lower; iconRight bottom; right bottom]))], newline);
end

function svg = placeicon(icon, x, y, angle, anchor)
    % Place an icon at its own scale with its anchor point (in icon units) at x, y; its lines are 1.5 wide after
    % scaling, like the wires
    shapes = replace(icon.Shapes, "@STROKEWIDTH@", sprintf("%g", 1.5/icon.Scale));
    svg = sprintf('<g transform="translate(%g,%g) rotate(%g) scale(%g) translate(%g,%g)">\n%s\n</g>', ...
        x, y, angle, icon.Scale, -anchor(1), -anchor(2), shapes);
end

function texSvg = typesettex(texList)
    % Typeset TeX strings to SVG with the MathJax of MATLAB, run in headless Chrome
    chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe";
    mathJax = fullfile(matlabroot, "derived", "ui", "mathjax", "tex-mml-svg.js");
    fileUrl = @(file) "file:///" + replace(replace(file, "\", "/"), " ", "%20");
    html = "<!DOCTYPE html><html><head><script>window.texInput = " + jsonencode(texList) + ";" + ...
        "window.MathJax = {svg: {fontCache: 'none'}, startup: {typeset: false, ready: () => {" + ...
        "MathJax.startup.defaultReady(); MathJax.startup.promise.then(() => {" + ...
        "const out = window.texInput.map(t => MathJax.tex2svg(t, {display: false})" + ...
        ".querySelector('svg').outerHTML);" + ...
        "document.getElementById('out').textContent = JSON.stringify(out);});}}};</script>" + ...
        "<script src=""" + fileUrl(mathJax) + """></script></head>" + ...
        "<body><pre id=""out""></pre></body></html>";
    htmlFile = string(tempname) + ".html";
    fileId = fopen(htmlFile, "w", "n", "UTF-8");
    fwrite(fileId, char(html), "char");
    fclose(fileId);
    cleanup = onCleanup(@() delete(htmlFile));

    command = """" + chrome + """ --headless=new --disable-gpu --virtual-time-budget=10000 --dump-dom """ + ...
        fileUrl(htmlFile) + """";
    [status, output] = system(command);
    json = regexp(output, '<pre id="out">(.*?)</pre>', "tokens", "once");
    if status ~= 0 || isempty(json) || json{1} == ""
        error("generatenetworkdiagramsvg:typesetFailed", "Typesetting the labels with MathJax failed.");
    end
    json = replace(json{1}, ["&lt;", "&gt;", "&quot;", "&amp;"], ["<", ">", """", "&"]);
    texSvg = string(jsondecode(json));
end

function svg = placetex(texSvg, x, y, anchor)
    % Place a typeset label with its baseline at y; one TeX em is the font size
    fontSize = 22;
    viewBox = sscanf(regexp(texSvg, 'viewBox="([^"]*)"', "tokens", "once"), "%f");
    width = viewBox(3) / 1000 * fontSize;
    height = viewBox(4) / 1000 * fontSize;
    left = x;
    if anchor == "middle"
        left = x - width / 2;
    elseif anchor == "end"
        left = x - width;
    end
    topEdge = y + viewBox(2) / 1000 * fontSize;
    openingTag = regexp(texSvg, '^<svg[^>]*>', "match", "once");
    newTag = regexprep(openingTag, '\s(width|height|style)="[^"]*"', '');
    newTag = replace(newTag, "<svg", sprintf('<svg x="%g" y="%g" width="%g" height="%g" color="#14233b"', ...
        left, topEdge, width, height));
    svg = newTag + extractAfter(texSvg, strlength(openingTag));
end

function svg = frame(left, right, dy)
    % Draw the frame of one 2-port network
    if nargin < 3
        dy = 0;
    end
    svg = string(sprintf(['<rect x="%g" y="%g" width="%g" height="250" rx="4" fill="none" stroke="#8a96a8" ' ...
        'stroke-width="1.5"/>'], left, 40 + dy, right - left));
end

function svg = twoport(left, right, dy, caption, ink)
    % Draw a network that is not detailed yet, as a block in its frame; the caption may be empty
    center = (left + right) / 2;
    svg = frame(left, right, dy) + newline + sprintf(['<rect x="%g" y="%g" width="70" height="170" rx="3" ' ...
        'fill="#ffffff" stroke="%s" stroke-width="1.5"/>'], center - 35, 85 + dy, ink);
    words = split(caption);
    words = words(words ~= "");
    for k = 1:numel(words)
        svg = svg + newline + sprintf(['<text x="%g" y="%g" text-anchor="middle" font-family="''Segoe UI'', ' ...
            'Arial, sans-serif" font-size="13" fill="#44546a">%s</text>'], center, 165 + dy + 18 * (k - 1), ...
            words(k));
    end
end
