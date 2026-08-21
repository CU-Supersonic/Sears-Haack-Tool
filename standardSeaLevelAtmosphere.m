function atmosphere = standardSeaLevelAtmosphere()
%STANDARDSEALEVELATMOSPHERE Returns ISA standard sea-level properties.
%
% Output:
%   atmosphere.temperature       [K]
%   atmosphere.pressure          [Pa]
%   atmosphere.density           [kg/m^3]
%   atmosphere.dynamicViscosity  [Pa*s]
%   atmosphere.kinematicViscosity[m^2/s]
%   atmosphere.gamma             [-]
%   atmosphere.gasConstant       [J/(kg*K)]
%   atmosphere.speedOfSound      [m/s]

atmosphere.temperature      = 288.15;
atmosphere.pressure         = 101325;
atmosphere.density          = 1.225;
atmosphere.dynamicViscosity = 1.7894e-5;
atmosphere.gamma            = 1.400;
atmosphere.gasConstant      = 287.05;
atmosphere.gravity          = 9.80665;

atmosphere.kinematicViscosity = ...
    atmosphere.dynamicViscosity / atmosphere.density;

atmosphere.speedOfSound = sqrt( ...
    atmosphere.gamma * ...
    atmosphere.gasConstant * ...
    atmosphere.temperature);

end