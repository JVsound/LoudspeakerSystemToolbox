function svgPath = generateclassdiagramsvg(svgPath, options)
    %GENERATECLASSDIAGRAMSVG - Write the Loudspeaker System Toolbox class diagram as SVG
    %   GENERATECLASSDIAGRAMSVG() writes classdiagram.svg next to this file.
    %
    %   GENERATECLASSDIAGRAMSVG(svgPath) writes the diagram to svgPath.
    %
    %   GENERATECLASSDIAGRAMSVG(...,Collapsed=TF) also specifies whether the
    %   classes are drawn collapsed, showing only their names, as in the
    %   Class Diagram Viewer. TF must be true or false (default). A collapsed
    %   diagram is written to classdiagramcollapsed.svg by default.
    %
    %   svgPath = GENERATECLASSDIAGRAMSVG(...) also returns the path of the
    %   written file.
    %
    %   The class members are listed by hand in this file: update them when a
    %   class changes. The PNG shown in overview.m is rendered from the SVG
    %   with a browser, for example headless Chrome.

    arguments
        svgPath (1,1) string = ""
        options.Collapsed (1,1) logical = false
    end

    collapsed = options.Collapsed;
    if svgPath == ""
        fileName = "classdiagram.svg";
        if collapsed
            fileName = "classdiagramcollapsed.svg";
        end
        svgPath = fullfile(fileparts(mfilename("fullpath")), fileName);
    end

    fonts = struct("sans", "'Segoe UI', Arial, Helvetica, sans-serif", ...
        "mono", "Consolas, 'Courier New', monospace");
    plain = @(text) {text, 'n'};
    static = @(text) {text, 's'};
    abstract = @(text) {text, 'a'};

    lspsysBox = struct("x", 470, "y", 40, "w", 360, "name", "lspsys", "stereo", "", ...
        "italic", false, "dashed", false, "sections", {{ ...
        {"Properties", {plain("Frequency: double"), plain("SourceVoltage: double"), ...
            plain("RadiationAngle: string"), plain("Enclosure: comp.Enclosure")}}, ...
        {"Dependent", {plain("AngularFrequency"), plain("WaveNumber"), plain("Wavelength"), ...
            plain("NumFrequencies")}}, ...
        {"Constant", {plain("SpeedOfSound = 343"), plain("AirDensity = 1.225"), ...
            plain("ReferencePressure = 20e-6")}}, ...
        {"Methods", {plain("solve2PortNetwork()"), plain("createResult()"), static("f2k(f)"), ...
            static("f2Lambda(f)")}}}});
    resultBox = struct("x", 40, "y", 40, "w", 330, "name", "result", "stereo", "", ...
        "italic", false, "dashed", false, "sections", {{ ...
        {"Properties", {plain("Frequency: double"), plain("SourceVoltage: double"), ...
            plain("SourceCurrent: double"), plain("DiaphragmVolumeVelocity: double"), ...
            plain("RadiatedVolumeVelocity: double"), plain("RadiationAngle: string"), ...
            plain("MicTransfer: double"), plain("Driver: comp.Driver"), plain("MicRadius: double"), ...
            plain("ExcursionLimit, PowerLimit")}}, ...
        {"Dependent", {plain("ElectricalImpedance: double"), plain("Pressure: double"), ...
            plain("SoundPressureLevel: double"), ...
            plain("DiaphragmExcursion: double"), plain("DiaphragmPeakExcursion: double")}}, ...
        {"Methods", {plain("splMax()"), plain("splPowerLimited()"), plain("splExcursionLimited()"), ...
            plain("splMaxPeakVoltage()")}}}});
    driverBox = struct("x", 900, "y", 40, "w", 380, "name", "comp.Driver", "stereo", "", ...
        "italic", false, "dashed", false, "sections", {{ ...
        {"Properties", {plain("Re, Le, Qes, Qms, Fs, Sd, Vas: double"), plain("Znom, Zmin: double"), ...
            plain("Pnom, Pcont, Paes1984, Paes2012: double"), plain("Xmax, Xvar, Xlim, Xmech: double"), ...
            plain("ExcursionLimit, PowerLimit: string")}}, ...
        {"Dependent", {plain("Bl, Cms, Mmd, Mms, Mmi, Rms, Qts: double"), plain("DiaphragmRadius: double")}}, ...
        {"Methods", {plain("zeb(f)"), plain("zm(f)"), plain("te(f)"), plain("tbl()"), ...
            plain("tm(f)"), plain("tsd()")}}}});
    enclosureBox = struct("x", 470, "y", 440, "w", 360, "name", "comp.Enclosure", "stereo", "abstract", ...
        "italic", true, "dashed", false, "sections", {{ ...
        {"Properties", {plain("Driver: comp.Driver")}}, ...
        {"Methods", {abstract("tae, tarad (f,ra)"), ...
            plain("zaFront, zaRear (f,ra)"), ...
            plain("micTransfer(f,ra)"), ...
            static("zarad(...)"), ...
            static("struve(...)")}}}});

    enclosureBox.y = lspsysBox.y + classboxheight(lspsysBox) + 62;
    subclassY = enclosureBox.y + classboxheight(enclosureBox) + 92;
    closedBoxBox = struct("x", 190, "y", subclassY, "w", 285, "name", "comp.ClosedBox", "stereo", "", ...
        "italic", false, "dashed", false, "sections", {{ ...
        {"Properties", {plain("RearVolume: double")}}, ...
        {"Methods", {plain("tae, tarad")}}}});
    feaEnclosureBox = struct("x", 803, "y", subclassY, "w", 330, "name", "comp.FeaEnclosure", "stereo", "", ...
        "italic", false, "dashed", false, "sections", {{ ...
        {"Properties", {plain("DiaphragmVelocity: double"), plain("PressureFrontFileName: string"), ...
            plain("PressureRearFileName: string"), plain("PressureFarFieldFileName: string")}}, ...
        {"Dependent", {plain("VolumeVelocity"), plain("Frequency")}}, ...
        {"Methods", {plain("tae, tarad, micTransfer"), ...
            static("importAnsysPressureResults(filename)")}}}});

    boxes = {lspsysBox, resultBox, driverBox, enclosureBox, closedBoxBox, feaEnclosureBox};

    if collapsed
        % x, y and width per box, in the order of the boxes above
        collapsedLayout = [400 40 240; 40 40 240; 760 40 240; 400 190 240; ...
            250 340 240; 550 340 240];
        for k = 1:numel(boxes)
            boxes{k}.x = collapsedLayout(k, 1);
            boxes{k}.y = collapsedLayout(k, 2);
            boxes{k}.w = collapsedLayout(k, 3);
            boxes{k}.sections = {};
        end
        subclassY = 340;
        driverArrowOffset = 31;
        resultArrowOffset = 23;
        canvasWidth = 1040;
    else
        driverArrowOffset = 80;
        resultArrowOffset = 60;
        canvasWidth = 1320;
    end

    boxSvg = strings(numel(boxes), 1);
    boxHeight = zeros(numel(boxes), 1);
    for k = 1:numel(boxes)
        [boxSvg(k), boxHeight(k)] = drawclassbox(boxes{k}, fonts, k);
    end
    lspsysBox = boxes{1};
    resultBox = boxes{2};
    driverBox = boxes{3};
    enclosureBox = boxes{4};
    lspsysBottom = lspsysBox.y + boxHeight(1);
    driverBottom = driverBox.y + boxHeight(3);
    enclosureBottom = enclosureBox.y + boxHeight(4);
    lspsysCenterX = lspsysBox.x + lspsysBox.w / 2;
    driverCenterX = driverBox.x + driverBox.w / 2;
    resultRight = resultBox.x + resultBox.w;
    driverArrowY = enclosureBox.y + driverArrowOffset;
    resultArrowY = lspsysBox.y + resultArrowOffset;
    subclassCenters = cellfun(@(box) box.x + box.w / 2, boxes(5:6));

    ink = "#2b3646";
    sans = fonts.sans;
    connectors = strings(0, 1);
    connectors(end+1) = sprintf(['<path d="M%d,%d L%d,%d" fill="none" stroke="%s" stroke-width="1.6" ' ...
        'marker-end="url(#assoc)"/>'], lspsysCenterX, lspsysBottom, lspsysCenterX, enclosureBox.y, ink);
    connectors(end+1) = sprintf(['<text x="%d" y="%d" font-family="%s" font-size="13" font-style="italic" ' ...
        'fill="%s">Enclosure</text>'], lspsysCenterX + 12, round((lspsysBottom + enclosureBox.y) / 2) + 4, ...
        sans, ink);
    connectors(end+1) = sprintf(['<path d="M%d,%d L%d,%d L%d,%d" fill="none" stroke="%s" ' ...
        'stroke-width="1.6" marker-end="url(#assoc)"/>'], enclosureBox.x + enclosureBox.w, driverArrowY, ...
        driverCenterX, driverArrowY, driverCenterX, driverBottom, ink);
    connectors(end+1) = sprintf(['<text x="%d" y="%d" font-family="%s" font-size="13" font-style="italic" ' ...
        'fill="%s">Driver</text>'], driverCenterX + 10, driverBottom + 22, sans, ink);
    connectors(end+1) = sprintf(['<path d="M%d,%d L%d,%d" fill="none" stroke="%s" stroke-width="1.6" ' ...
        'stroke-dasharray="6 4" marker-end="url(#assoc)"/>'], lspsysBox.x, resultArrowY, resultRight, ...
        resultArrowY, ink);
    connectors(end+1) = sprintf(['<text x="%d" y="%d" text-anchor="middle" font-family="%s" font-size="13" ' ...
        'fill="%s">&#171;creates&#187;</text>'], (lspsysBox.x + resultRight) / 2, resultArrowY - 10, sans, ink);
    busY = subclassY - 40;
    connectors(end+1) = sprintf(['<path d="M%d,%d L%d,%d" fill="none" stroke="%s" stroke-width="1.6" ' ...
        'marker-end="url(#inherit)"/>'], lspsysCenterX, busY, lspsysCenterX, enclosureBottom, ink);
    connectors(end+1) = sprintf('<path d="M%d,%d L%d,%d" fill="none" stroke="%s" stroke-width="1.6"/>', ...
        min(subclassCenters), busY, max(subclassCenters), busY, ink);
    for centerX = subclassCenters
        connectors(end+1) = sprintf('<path d="M%d,%d L%d,%d" fill="none" stroke="%s" stroke-width="1.6"/>', ...
            centerX, busY, centerX, subclassY, ink);
    end

    legendY = subclassY + max(boxHeight(5:6)) + 50;
    legend = strings(0, 1);
    if collapsed
        italicX = 40;
        arrowX = 40;
        arrowY = legendY + 36;
        extraHeight = 20;
    else
        italicX = 40;
        arrowX = 350;
        arrowY = legendY + 15;
        extraHeight = 0;
    end
    legend(end+1) = sprintf(['<text x="%d" y="%d" font-family="%s" font-size="13" font-style="italic" ' ...
        'fill="%s">italic: abstract</text>'], italicX, legendY + 15, sans, ink);
    if ~collapsed
        legend(end+1) = sprintf(['<text x="190" y="%d" font-family="%s" font-size="13" ' ...
            'text-decoration="underline" fill="%s">underline: static</text>'], legendY + 15, sans, ink);
    end
    legend(end+1) = sprintf(['<text x="%d" y="%d" font-family="%s" font-size="13" fill="%s">' ...
        'arrow: association &#183; hollow triangle: inheritance &#183; dashed arrow: creates</text>'], ...
        arrowX, arrowY, sans, ink);

    canvasHeight = legendY + 50 + extraHeight;
    header = sprintf(['<?xml version="1.0" encoding="UTF-8"?>\n' ...
        '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d" viewBox="0 0 %d %d" role="img">\n' ...
        '<title>Loudspeaker System Toolbox class diagram</title>\n<defs>\n' ...
        '<marker id="assoc" viewBox="0 0 12 12" refX="11" refY="6" markerWidth="12" markerHeight="12" ' ...
        'orient="auto" markerUnits="userSpaceOnUse"><path d="M1,1 L11,6 L1,11" fill="none" ' ...
        'stroke="#2b3646" stroke-width="1.6"/></marker>\n' ...
        '<marker id="inherit" viewBox="0 0 16 16" refX="15" refY="8" markerWidth="16" markerHeight="16" ' ...
        'orient="auto" markerUnits="userSpaceOnUse"><path d="M1,1 L15,8 L1,15 z" fill="#ffffff" ' ...
        'stroke="#2b3646" stroke-width="1.6"/></marker>\n</defs>\n' ...
        '<rect width="100%%" height="100%%" fill="#ffffff"/>\n'], ...
        canvasWidth, canvasHeight, canvasWidth, canvasHeight);
    document = string(header) + strjoin([connectors(:); boxSvg(:); legend(:)], newline) ...
        + newline + "</svg>" + newline;

    fileId = fopen(svgPath, "w", "n", "UTF-8");
    fwrite(fileId, char(document), "char");
    fclose(fileId);
    xmlread(svgPath);
end

function height = classboxheight(box)
    rowHeight = 22;
    sectionHeight = 24;
    headerHeight = 46;
    if box.stereo ~= ""
        headerHeight = 62;
    end
    height = headerHeight;
    for k = 1:numel(box.sections)
        height = height + sectionHeight + rowHeight * numel(box.sections{k}{2});
    end
    if ~isempty(box.sections)
        height = height + 8;
    end
end

function [svg, height] = drawclassbox(box, fonts, id)
    rowHeight = 22;
    sectionHeight = 24;
    headerHeight = 46;
    if box.stereo ~= ""
        headerHeight = 62;
    end
    height = classboxheight(box);

    x = box.x;
    y = box.y;
    w = box.w;
    stroke = "#4a5a70";
    dash = "";
    if box.dashed
        stroke = "#7a8797";
        dash = ' stroke-dasharray="8 5"';
    end

    parts = strings(0, 1);
    parts(end+1) = sprintf('<clipPath id="clip%d"><rect x="%d" y="%d" width="%d" height="%d" rx="6"/></clipPath>', ...
        id, x, y, w, height);
    parts(end+1) = sprintf('<rect x="%d" y="%d" width="%d" height="%d" rx="6" fill="#ffffff"/>', x, y, w, height);
    parts(end+1) = sprintf('<g clip-path="url(#clip%d)">', id);
    parts(end+1) = sprintf('<rect x="%d" y="%d" width="%d" height="%d" fill="#e6eefb"/>', x, y, w, headerHeight);
    parts(end+1) = sprintf('<rect x="%d" y="%d" width="%d" height="5" fill="#1f4e9c"/>', x, y, w);

    rowY = y + headerHeight;
    for k = 1:numel(box.sections)
        parts(end+1) = sprintf('<rect x="%d" y="%d" width="%d" height="%d" fill="#eef1f5"/>', ...
            x, rowY, w, sectionHeight);
        parts(end+1) = sprintf(['<text x="%d" y="%d" font-family="%s" font-size="12.5" font-weight="bold" ' ...
            'fill="#44546a">%s</text>'], x + 14, rowY + 16, fonts.sans, escapexml(box.sections{k}{1}));
        rowY = rowY + sectionHeight;
        rows = box.sections{k}{2};
        for r = 1:numel(rows)
            text = rows{r}{1};
            style = rows{r}{2};
            attributes = "";
            fill = "#1b2430";
            if style == 's'
                attributes = ' text-decoration="underline"';
            elseif style == 'a'
                attributes = ' font-style="italic"';
            elseif style == 'd'
                attributes = ' font-style="italic"';
                fill = "#6b7785";
            end
            parts(end+1) = sprintf('<text x="%d" y="%d" font-family="%s" font-size="14" fill="%s"%s>%s</text>', ...
                x + 14, rowY + 16, fonts.mono, fill, attributes, escapexml(text));
            rowY = rowY + rowHeight;
        end
    end
    parts(end+1) = "</g>";

    if box.stereo ~= ""
        parts(end+1) = sprintf(['<text x="%d" y="%d" text-anchor="middle" font-family="%s" font-size="12.5" ' ...
            'fill="#44546a">&#171;%s&#187;</text>'], x + w / 2, y + 23, fonts.sans, box.stereo);
        nameY = y + 46;
    else
        nameY = y + 32;
    end
    nameStyle = "";
    if box.italic
        nameStyle = ' font-style="italic"';
    end
    parts(end+1) = sprintf(['<text x="%d" y="%d" text-anchor="middle" font-family="%s" font-size="18" ' ...
        'font-weight="bold"%s fill="#14233b">%s</text>'], x + w / 2, nameY, fonts.sans, nameStyle, ...
        escapexml(box.name));
    parts(end+1) = sprintf(['<rect x="%d" y="%d" width="%d" height="%d" rx="6" fill="none" stroke="%s" ' ...
        'stroke-width="1.6"%s/>'], x, y, w, height, stroke, dash);
    svg = strjoin(parts, newline);
end

function text = escapexml(text)
    text = string(text);
    text = replace(text, "&", "&amp;");
    text = replace(text, "<", "&lt;");
    text = replace(text, ">", "&gt;");
end
