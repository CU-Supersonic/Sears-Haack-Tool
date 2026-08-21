function drag = calculateWaveDrag( ...
    Mach, dynamicPressure, geometry, settings)
%CALCULATEWAVEDRAG Calculates Sears-Haack wave drag.
%
% The classical Sears-Haack wave-drag coefficient is referenced to the
% maximum frontal area.
%
% A quintic smoothstep is used to approximate transonic drag rise.
% This blending model should eventually be replaced with CFD or
% experimental data.

Mach            = Mach(:).';
dynamicPressure = dynamicPressure(:).';

Rmax = geometry.Rmax;
L    = geometry.L;
Sref = geometry.referenceArea;

%% Classical Sears-Haack wave-drag coefficient

CDfull = (9 .* (pi^2) * (Rmax^2)) ./ (2*(L^2));

%% Calculate transonic blending factor

blendFactor = zeros(size(Mach));

for i = 1:length(Mach)

    if Mach(i) <= settings.MachDragRise

        blendFactor(i) = 0;

    elseif Mach(i) < settings.MachFullWave

        eta = ...
            (Mach(i) - settings.MachDragRise) / ...
            (settings.MachFullWave - settings.MachDragRise);

        % Quintic smoothstep
        blendFactor(i) = ...
            6*eta^5 - 15*eta^4 + 10*eta^3;

    else

        blendFactor(i) = 1;

    end
end

CD = CDfull .* blendFactor;

force = dynamicPressure .* Sref .* CD;

%% Output structure

drag.name        = "Wave";
drag.CDfull      = CDfull;
drag.blendFactor = blendFactor;
drag.CD          = CD;
drag.force       = force;

end