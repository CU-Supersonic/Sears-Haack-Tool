function drag = calculateSkinFrictionDrag( ...
    Mach, velocity, atmosphere, geometry, settings)
%CALCULATESKINFRICTIONDRAG Calculates body skin-friction drag.
%
% Inputs:
%   Mach       = Mach-number array
%   velocity   = velocity array [m/s]
%   atmosphere = atmospheric-property structure
%   geometry   = body-geometry structure
%   settings   = skin-friction settings
%
% settings.model:
%   "laminar"
%   "turbulent"
%   "mixed"
%
% Outputs:
%   drag.Cf
%   drag.CD
%   drag.force
%   drag.ReynoldsNumber

    Mach     = Mach(:).';
    velocity = velocity(:).';

    rho = atmosphere.density;
    mu  = atmosphere.dynamicViscosity;

    L     = geometry.L;
    Swet  = geometry.wettedArea;
    Sref  = geometry.referenceArea;

    ReynoldsNumber = rho .* velocity .* L ./ mu;

    Cf = zeros(size(Mach));

    switch lower(settings.model)

        case "laminar"

            Cf = calculateLaminarCf( ...
                ReynoldsNumber, Mach);

        case "turbulent"

            Cf = calculateTurbulentCf( ...
                ReynoldsNumber, Mach);

        case "mixed"

            Cf = calculateMixedCf( ...
                ReynoldsNumber, ...
                Mach, ...
                settings.transitionX);

        otherwise

            error(['Unknown boundary-layer model. ', ...
                'Use "laminar", "turbulent", or "mixed".']);

    end

    %% Surface-roughness correction

    if settings.surfaceRoughness > 0 && ...
            lower(settings.model) ~= "laminar"

        relativeRoughness = settings.surfaceRoughness / L;

        % Approximate fully rough turbulent skin-friction coefficient
        CfRough = 0.032 .* relativeRoughness.^0.2;

        Cf = max(Cf, CfRough);
    end

    %% Convert to frontal-area drag coefficient

    CD = Cf .* Swet ./ Sref;

    dynamicPressure = 0.5 .* rho .* velocity.^2;

    force = dynamicPressure .* Sref .* CD;

    %% Output structure

    drag.name           = "Skin friction";
    drag.ReynoldsNumber = ReynoldsNumber;
    drag.Cf             = Cf;
    drag.CD             = CD;
    drag.force          = force;

end


function Cf = calculateLaminarCf(ReynoldsNumber, Mach)
% Average laminar flat-plate skin-friction correlation.

    CfIncompressible = 1.328 ./ sqrt(ReynoldsNumber);

    % Simple compressibility correction
    Cf = CfIncompressible ./ sqrt(1 + 0.2 .* Mach.^2);

end


function Cf = calculateTurbulentCf(ReynoldsNumber, Mach)
% Average turbulent compressible flat-plate correlation.

    Cf = 0.455 ./ ...
        ((log10(ReynoldsNumber)).^2.58 .* ...
        (1 + 0.144 .* Mach.^2).^0.65);

end


function Cf = calculateMixedCf( ...
    ReynoldsNumber, Mach, transitionFraction)
% Approximate mixed laminar/turbulent average skin friction.
%
% transitionFraction is the transition location x_transition/L.

    transitionFraction = min(max(transitionFraction, 0), 1);

    ReTransition = ReynoldsNumber .* transitionFraction;

    CfTurbulent = calculateTurbulentCf(ReynoldsNumber, Mach);

    if transitionFraction <= 0
        Cf = CfTurbulent;
        return;
    end

    if transitionFraction >= 1
        Cf = calculateLaminarCf(ReynoldsNumber, Mach);
        return;
    end

    % Laminar contribution over forward portion
    CfLaminarForward = ...
        1.328 ./ sqrt(max(ReTransition, 1));

    % Approximate area-weighted combination
    Cf = ...
        transitionFraction .* CfLaminarForward + ...
        (1 - transitionFraction) .* CfTurbulent;

end