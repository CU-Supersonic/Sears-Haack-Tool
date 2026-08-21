function createSearsHaackPlots(geometry, results)
%CREATESEARSHAACKPLOTS Creates body geometry and drag plots.
%
% Inputs:
%   geometry - Sears-Haack geometry structure
%   results  - Drag results structure

    fprintf('\nCreating Sears-Haack plots...\n');

    data = results.table;

    %% ====================================================================
    % SEARS-HAACK BODY GEOMETRY
    % =====================================================================

    figure( ...
        'Name', 'Sears-Haack Geometry', ...
        'NumberTitle', 'off', ...
        'Visible', 'on');

    plot(geometry.x, geometry.radius, ...
        'LineWidth', 2);

    hold on;

    plot(geometry.x, -geometry.radius, ...
        'LineWidth', 2);

    hold off;

    grid on;
    box on;
    axis equal;

    xlabel('Axial Position, x [m]');
    ylabel('Body Radius, r [m]');
    title('Sears-Haack Body Geometry');

    %% ====================================================================
    % DRAG FORCE VERSUS MACH NUMBER
    % =====================================================================

    figure( ...
        'Name', 'Drag Force versus Mach Number', ...
        'NumberTitle', 'off', ...
        'Visible', 'on');

    plot(data.Mach, data.DragFriction_N, ...
        'LineWidth', 2);

    hold on;

    plot(data.Mach, data.DragWave_N, ...
        'LineWidth', 2);

    plot(data.Mach, data.DragTotal_N, ...
        'LineWidth', 2.5);

    hold off;

    grid on;
    box on;

    xlabel('Mach Number');
    ylabel('Drag Force [N]');
    title('Sears-Haack Drag Force');

    legend( ...
        'Skin-Friction Drag', ...
        'Wave Drag', ...
        'Total Drag', ...
        'Location', 'best');

    %% ====================================================================
    % DRAG COEFFICIENT VERSUS MACH NUMBER
    % =====================================================================

    figure( ...
        'Name', 'Drag Coefficient versus Mach Number', ...
        'NumberTitle', 'off', ...
        'Visible', 'on');

    plot(data.Mach, data.CD_Friction, ...
        'LineWidth', 2);

    hold on;

    plot(data.Mach, data.CD_Wave, ...
        'LineWidth', 2);

    plot(data.Mach, data.CD_Total, ...
        'LineWidth', 2.5);

    hold off;

    grid on;
    box on;

    xlabel('Mach Number');
    ylabel('Drag Coefficient, C_D');
    title('Sears-Haack Drag Coefficient');

    legend( ...
        'Skin-Friction Drag', ...
        'Wave Drag', ...
        'Total Drag', ...
        'Location', 'best');

    %% ====================================================================
    % WAVE-DRAG BLENDING FACTOR
    % =====================================================================

    figure( ...
        'Name', 'Wave-Drag Blending Factor', ...
        'NumberTitle', 'off', ...
        'Visible', 'on');

    plot(data.Mach, results.waveBlend, ...
        'LineWidth', 2);

    grid on;
    box on;

    xlabel('Mach Number');
    ylabel('Wave-Drag Blend Factor');
    title('Wave-Drag Blending Factor');

    ylim([-0.05, 1.05]);

    drawnow;

    fprintf('Plot generation complete.\n');
end