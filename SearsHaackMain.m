%% SearsHaackMain.m
% Estimates the drag of a Sears-Haack body over a specified Mach range.
%
% Drag components:
%   1. Skin-friction drag
%   2. Wave drag
%
% All drag coefficients are referenced to maximum frontal area.

clear;
clc;
close all;


%% ========================================================================
% Select Mode
%% ========================================================================

%% ========================================================================
% SELECT ANALYSIS MODE AND REQUEST USER INPUTS
% ========================================================================

fprintf('\nSears-Haack Drag Analysis\n');
fprintf('1 - Mach sweep at constant body length\n');
fprintf('2 - Length sweep at constant Mach number\n\n');

modeSelection = input('Select analysis mode (1 or 2): ');

while ~ismember(modeSelection, [1, 2])
    fprintf('Invalid selection. Enter 1 for Mach sweep or 2 for length sweep.\n');
    modeSelection = input('Select analysis mode (1 or 2): ');
end

% Request diameter in inches and convert it to meters
diameterInches = input('Enter maximum body diameter [in]: ');

while ~isscalar(diameterInches) || ...
        ~isfinite(diameterInches) || ...
        diameterInches <= 0

    fprintf('Diameter must be a positive number.\n');
    diameterInches = input('Enter maximum body diameter [in]: ');
end

inputs.geometry.Dmax = diameterInches * 0.0254;
inputs.geometry.Nx   = 2500;

switch modeSelection

    case 1
        inputs.sweep.mode = "mach";

        fprintf('\nChoose how to define the constant body geometry:\n');
        fprintf('1 - Enter body length [m]\n');
        fprintf('2 - Enter slenderness ratio, L/D\n\n');

        geometryInputSelection = input('Select geometry input type (1 or 2): ');

        while ~ismember(geometryInputSelection, [1, 2])
            fprintf(['Invalid selection. Enter 1 for body length or ', ...
                '2 for slenderness ratio.\n']);
            geometryInputSelection = input( ...
                'Select geometry input type (1 or 2): ');
        end

        switch geometryInputSelection

            case 1
                inputs.geometry.L = input('Enter constant body length [m]: ');

                while ~isscalar(inputs.geometry.L) || ...
                        ~isfinite(inputs.geometry.L) || ...
                        inputs.geometry.L <= 0
                    fprintf('Body length must be a positive number.\n');
                    inputs.geometry.L = input( ...
                        'Enter constant body length [m]: ');
                end

            case 2
                inputs.geometry.slendernessRatio = input( ...
                    'Enter constant slenderness ratio, L/D: ');

                while ~isscalar(inputs.geometry.slendernessRatio) || ...
                        ~isfinite(inputs.geometry.slendernessRatio) || ...
                        inputs.geometry.slendernessRatio <= 0
                    fprintf(['Slenderness ratio must be a positive ', ...
                        'number.\n']);
                    inputs.geometry.slendernessRatio = input( ...
                        'Enter constant slenderness ratio, L/D: ');
                end

                % L/D = slenderness ratio, therefore L = (L/D)*D.
                inputs.geometry.L = ...
                    inputs.geometry.slendernessRatio * inputs.geometry.Dmax;

                fprintf('Calculated body length: %.4f m\n', ...
                    inputs.geometry.L);

        end


    case 2
        inputs.sweep.mode = "length";

        inputs.flight.ConstantMach = input( ...
            'Enter constant Mach number: ');

        while ~isscalar(inputs.flight.ConstantMach) || ...
                ~isfinite(inputs.flight.ConstantMach) || ...
                inputs.flight.ConstantMach <= 0

            fprintf('Mach number must be a positive number.\n');

            inputs.flight.ConstantMach = input( ...
                'Enter constant Mach number: ');
        end

end

% Flight range
inputs.flight.MachMin  = 0.60;
inputs.flight.MachMax  = 1.10;
inputs.flight.MachStep = 0.0025;

% Surface and boundary-layer inputs
inputs.skinFriction.surfaceRoughness = 5.0e-6;  % Roughness [m]
inputs.skinFriction.model            = "turbulent";
inputs.skinFriction.transitionX      = 0.0;     % Transition x/L

% Wave-drag model inputs
inputs.waveDrag.MachDragRise = 0.60;
inputs.waveDrag.MachFullWave = 1.0;

% Output settings
inputs.output.writeCSV = true;
inputs.output.csvName  = "Sears_Haack_Drag_Results.csv";

%% ========================================================================
% STANDARD ATMOSPHERE
% ========================================================================

atmosphere = standardSeaLevelAtmosphere();


switch lower(inputs.sweep.mode)

    case "mach"


        Mach = inputs.flight.MachMin: ...
            inputs.flight.MachStep: ...
            inputs.flight.MachMax;

        velocity = Mach .* atmosphere.speedOfSound;

        dynamicPressure = 0.5 .* atmosphere.density .* velocity.^2;
        
        %% ========================================================================
        % GENERATE BODY GEOMETRY
        % ========================================================================
        
        geometry = generateSearsHaackGeometry( ...
            inputs.geometry.Dmax, ...
            inputs.geometry.L, ...
            inputs.geometry.Nx);
        
        %% ========================================================================
        % CALCULATE INDIVIDUAL DRAG COMPONENTS
        % ========================================================================
        
        skinFriction = calculateSkinFrictionDrag( ...
            Mach, ...
            velocity, ...
            atmosphere, ...
            geometry, ...
            inputs.skinFriction);
        
        waveDrag = calculateWaveDrag( ...
            Mach, ...
            dynamicPressure, ...
            geometry, ...
            inputs.waveDrag);
        
        
        %% ========================================================================
        % ASSEMBLE TOTAL DRAG
        % ========================================================================
        
        results = assembleDragResults( ...
            Mach, ...
            velocity, ...
            dynamicPressure, ...
            skinFriction, ...
            waveDrag);
        
        %% ========================================================================
        % DISPLAY RESULTS
        % ========================================================================
        
        printSearsHaackSummary( ...
            atmosphere, ...
            geometry, ...
            skinFriction, ...
            waveDrag);
        
        disp(results.table(1:10:end, :));
        
        %% ========================================================================
        % CREATE PLOTS
        % ========================================================================
        
        createSearsHaackPlots(geometry, results);
        
        %% ========================================================================
        % WRITE RESULTS TO CSV
        % ========================================================================
    exportSearsHaackTXT(geometry, "SearsHaackProfile.txt");

if inputs.output.writeCSV
    writetable(results.table, inputs.output.csvName);

    fprintf('\nResults written to:\n%s\n', inputs.output.csvName);
    fprintf('Blending factor not yet properly scaled');

end
    case "length"

        Length = 1 : 0.1 : 5;

        Mach = inputs.flight.ConstantMach;
        
        velocity = Mach * atmosphere.speedOfSound;
        dynamicPressure = 0.5 * atmosphere.density * velocity^2;
        
        TotalDrag = zeros(size(Length));
        SkinDrag  = zeros(size(Length));
        WaveDrag  = zeros(size(Length));
        CDtotal   = zeros(size(Length));
        Slenderness = Length ./ inputs.geometry.Dmax;

        for i = 1:length(Length)

            geometry = generateSearsHaackGeometry( ...
                inputs.geometry.Dmax, ...
                Length(i), ...
                inputs.geometry.Nx);

            skinFriction = calculateSkinFrictionDrag( ...
                Mach, ...
                velocity, ...
                atmosphere, ...
                geometry, ...
                inputs.skinFriction);

            waveDrag = calculateWaveDrag( ...
                Mach, ...
                dynamicPressure, ...
                geometry, ...
                inputs.waveDrag);

            results = assembleDragResults( ...
                Mach, ...
                velocity, ...
                dynamicPressure, ...
                skinFriction, ...
                waveDrag);

            SkinDrag(i) = results.force.skinFriction;
            WaveDrag(i) = results.force.wave;
            TotalDrag(i)= results.force.total;

            CDtotal(i)=results.CD.total;

        end

        % Find minimum total drag
        [minDrag, idxMin] = min(TotalDrag);

        bestSlenderness = Slenderness(idxMin);
        bestLength      = Length(idxMin);

        figure
        plot(Slenderness, SkinDrag,'LineWidth',2)
        hold on
        plot(Slenderness, WaveDrag,'LineWidth',2)
        plot(Slenderness, TotalDrag,'LineWidth',3)

        grid on
        box on

        xlabel('Slenderness Ratio (Leng/Dia)')
        ylabel('Drag Force (N)')
        title(sprintf('Mach %.2f',Mach))

        legend( ...
            'Skin Friction', ...
            'Wave Drag', ...
            'Total Drag', ...
            'Location','best')
        
        % Plot optimum point
        plot(bestSlenderness, minDrag, ...
            'ro', ...
            'MarkerSize',10, ...
            'LineWidth',2, ...
            'MarkerFaceColor','r');

        % Label it
        text(bestSlenderness, minDrag, ...
            sprintf('  Minimum\n  L/D = %.1f\n  L = %.2f m\n  Drag = %.1f N', ...
            bestSlenderness, ...
            bestLength, ...
            minDrag), ...
            'FontSize',10, ...
            'VerticalAlignment','bottom');


        %Length plot
        %% ========================================================================
        % TOTAL DRAG VERSUS BODY LENGTH
        % ========================================================================

        % Find the lowest calculated total-drag point
        [minTotalDrag, minIndex] = min(TotalDrag);

        bestLength = Length(minIndex);
        bestSlenderness = Slenderness(minIndex);

        figure( ...
            'Name', 'Total Drag versus Body Length', ...
            'NumberTitle', 'off', ...
            'Visible', 'on');

        % Plot total drag
        plot(Length, TotalDrag, ...
            'LineWidth', 2.5, ...
            'DisplayName', 'Total Drag');

        hold on;

        % Mark the minimum-drag point
        plot(bestLength, minTotalDrag, ...
            'o', ...
            'MarkerSize', 10, ...
            'LineWidth', 2, ...
            'MarkerFaceColor', 'auto', ...
            'DisplayName', 'Minimum Drag');

        % Add a dashed vertical line at the optimum length
        xline(bestLength, '--', ...
            sprintf('L = %.2f m', bestLength), ...
            'LineWidth', 1.5, ...
            'LabelVerticalAlignment', 'bottom');

        % Add a text callout
        text(bestLength, minTotalDrag, ...
            sprintf(['  Minimum Total Drag\n', ...
            '  Length = %.2f m\n', ...
            '  L/D = %.2f\n', ...
            '  Drag = %.2f N'], ...
            bestLength, ...
            bestSlenderness, ...
            minTotalDrag), ...
            'FontSize', 10, ...
            'FontWeight', 'bold', ...
            'VerticalAlignment', 'bottom', ...
            'HorizontalAlignment', 'left');

        hold off;

        grid on;

        % Primary axis (bottom)
        ax1 = gca;

        xlabel(ax1,'Body Length [m]')
        ylabel(ax1,'Drag Force [N]')
        grid(ax1,'on')
        box(ax1,'on')

        ax2 = axes( ...
            'Position', ax1.Position, ...
            'Color', 'none', ...
            'XAxisLocation', 'top', ...
            'YAxisLocation', 'right', ...
            'YTick', [], ...
            'Box', 'off');

        % Match limits
        ax2.XLim = ax1.XLim;

        % Put ticks at the same locations
        ax2.XTick = ax1.XTick;

        % Convert each tick from length to fineness ratio
        finenessTicks = ax2.XTick ./ inputs.geometry.Dmax;

        ax2.XTickLabel = compose('%.1f', finenessTicks);

        xlabel(ax2,'Fineness Ratio (L/D)')

        title(sprintf( ...
            'Total Drag versus Body Length at Mach %.2f', ...
            Mach));

        legend('Location', 'best');


        %% ========================================================================
        % COMPARE SEARS-HAACK GEOMETRIES
        % ========================================================================

        initialLength = min(Length);
        maximumLength = max(Length);
        geometryPlotStep = 1.0;

        geometryPlotLengths = ...
            initialLength : geometryPlotStep : maximumLength;

        % Add final length if it is not already included
        if abs(geometryPlotLengths(end) - maximumLength) > 1e-10
            geometryPlotLengths(end + 1) = maximumLength;
        end

        figure( ...
            'Name', 'Sears-Haack Geometry Comparison', ...
            'NumberTitle', 'off');

        hold on;

        legendEntries = strings(size(geometryPlotLengths));

        % Vertical distance between body centerlines
        verticalSpacing = 1.5 * inputs.geometry.Dmax;

        for i = 1:length(geometryPlotLengths)

            currentLength = geometryPlotLengths(i);

            currentGeometry = generateSearsHaackGeometry( ...
                inputs.geometry.Dmax, ...
                currentLength, ...
                inputs.geometry.Nx);

            % Give each body its own vertical centerline
            centerline = (i - 1) * verticalSpacing;

            % Plot upper surface
            upperLine = plot( ...
                currentGeometry.x, ...
                currentGeometry.radius + centerline, ...
                'LineWidth', 2);

            % Plot lower surface using the upper surface color
            plot( ...
                currentGeometry.x, ...
                -currentGeometry.radius + centerline, ...
                'LineWidth', 2, ...
                'Color', upperLine.Color, ...
                'HandleVisibility', 'off');

            legendEntries(i) = sprintf( ...
                'L = %.1f m, L/D = %.2f', ...
                currentLength, ...
                currentLength / inputs.geometry.Dmax);

        end

        hold off;

        grid on;
        box on;

        xlabel('Axial Position, x [m]');
        ylabel('Vertical Position [m]');

        title(sprintf( ...
            'Sears-Haack Geometry Comparison, D = %.3f m', ...
            inputs.geometry.Dmax));

        legend(legendEntries, 'Location', 'best');

        % Same physical scale on the x- and y-axes
        axis equal;
        axis tight;



end
