function geometry = generateSearsHaackGeometry(Dmax, L, Nx)
%GENERATESEARSHAACKGEOMETRY Generates Sears-Haack body geometry.
%
% Inputs:
%   Dmax = maximum body diameter [m]
%   L    = body length [m]
%   Nx   = number of axial points
%
% Output:
%   geometry structure containing radius, area, volume, wetted area,
%   derivatives, and reference dimensions.

arguments
    Dmax (1,1) double {mustBePositive}
    L    (1,1) double {mustBePositive}
    Nx   (1,1) double {mustBeInteger, mustBeGreaterThan(Nx,10)}
end

Rmax = Dmax / 2;

% Avoid exact endpoints because dr/dx is singular at x/L = 0 and 1.
xi = linspace(1e-8, 1 - 1e-8, Nx);

% Dimensional axial coordinate
x = xi .* L;

% Sears-Haack radius distribution
radius = 2*sqrt(2) .* Rmax .* ...
    (xi .* (1 - xi)).^(3/4);

% Cross-sectional area
crossSectionArea = pi .* radius.^2;

% Derivative with respect to nondimensional coordinate xi
dr_dxi = ...
    (3 .* Rmax .* (1 - 2.*xi)) ./ ...
    (sqrt(2) .* (xi .* (1 - xi)).^(1/4));

% Convert to derivative with respect to dimensional coordinate x
dr_dx = dr_dxi ./ L;

% Differential wetted area
dSwet_dx = ...
    2*pi .* radius .* sqrt(1 + dr_dx.^2);

% Numerically integrated wetted area
wettedArea = trapz(x, dSwet_dx);

% Maximum frontal reference area
referenceArea = pi .* Rmax.^2;

% Sears-Haack body volume
volume = (3*pi^2/16) .* Rmax.^2 .* L;

% Store outputs
geometry.Dmax             = Dmax;
geometry.Rmax             = Rmax;
geometry.L                = L;
geometry.finenessRatio    = L / Dmax;
geometry.volume           = volume;
geometry.referenceArea    = referenceArea;
geometry.wettedArea       = wettedArea;

geometry.xi               = xi;
geometry.x                = x;
geometry.radius           = radius;
geometry.crossSectionArea = crossSectionArea;
geometry.dr_dxi           = dr_dxi;
geometry.dr_dx            = dr_dx;
geometry.dSwet_dx         = dSwet_dx;

end