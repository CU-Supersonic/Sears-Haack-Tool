function printSearsHaackSummary( ...
    atmosphere, geometry, skinFriction, waveDrag)
%PRINTSEARSHAACKSUMMARY Prints geometry and model information.

fprintf('\n');
fprintf('============================================================\n');
fprintf('SEARS-HAACK BODY DRAG MODEL\n');
fprintf('============================================================\n');

fprintf('Maximum diameter:       %10.4f m\n', ...
    geometry.Dmax);

fprintf('Maximum diameter:       %10.3f in\n', ...
    geometry.Dmax / 0.0254);

fprintf('Body length:            %10.3f in\n', ...
    geometry.L / 0.0254);

fprintf('Fineness ratio L/D:     %10.3f\n', ...
    geometry.finenessRatio);

fprintf('Maximum frontal area:   %10.6f m^2\n', ...
    geometry.referenceArea);

fprintf('Wetted area:            %10.6f m^2\n', ...
    geometry.wettedArea);

fprintf('Body volume:            %10.6f m^3\n', ...
    geometry.volume);

fprintf('Speed of sound:         %10.3f m/s\n', ...
    atmosphere.speedOfSound);

fprintf('Air density:            %10.4f kg/m^3\n', ...
    atmosphere.density);

fprintf('Dynamic viscosity:      %10.4e Pa*s\n', ...
    atmosphere.dynamicViscosity);

fprintf('Full Sears-Haack CDwave:%11.6f\n', ...
    waveDrag.CDfull);

fprintf('Minimum Reynolds no.:   %10.4e\n', ...
    min(skinFriction.ReynoldsNumber));

fprintf('Maximum Reynolds no.:   %10.4e\n', ...
    max(skinFriction.ReynoldsNumber));

fprintf('============================================================\n');
fprintf('\n');

end