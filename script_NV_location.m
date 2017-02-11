%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang');
parameters.figure.identifier =  'Scan_natural-3_';
tools = experiment_toolbox;
tools.scan(10, 10, 20, 1, 0);

%% scanz example
X = 10;
Y = 10;
Z = 20:0.5:40;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% sample big marker
Z0 = 29.5;
X = 1:0.5:20;
Y = 1:0.5:20;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% sample area
cross_x = 9;
cross_y = 9;

X = 20:0.5:90;
Y = 10:0.5:70;
Z = [6, 8];
Z = Z + Z0; 
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% Center scan for NV
X0 = 9.5-9.0+62.0;
Y0 = 9.0-9.0+23.7;
Z = 7.7;
Delta = 3;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = Z + Z0;
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% scanz over NV
NV_x = 62.1;
NV_y = 24.7;
Z = Z0-5:0.1:Z0+10;
CountNum = 40;
tools.scan(NV_x, NV_y, Z, CountNum, 0);

%% Scan for small marker
first_x = cross_x + 18.5;
first_y = cross_y + 23.5;

if ((NV_x < first_x + 30) && (NV_y < first_y + 30))
    X0 = first_x;
    Y0 = first_y;
elseif ((NV_x < first_x + 60) && (NV_y < first_y + 30))
    X0 = first_x+30;
    Y0 = first_y;
elseif ((NV_x < first_x + 30) && (NV_y < first_y + 60))
    X0 = first_x;
    Y0 = first_y+30;
else
    X0 = first_x+30;
    Y0 = first_y+30;
end
Delta = 3;

X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);
tools.scan(X+30, Y, Z, CountNum, Z0);
tools.scan(X, Y+30, Z, CountNum, Z0);
tools.scan(X+30, Y+30, Z, CountNum, Z0);

%% NVCooridinate

% marker coordingate 
% sequence: (0,0) (0,30) (30,0) (30,30)
F(:,1)=[58.2 31.5]';
F(:,2)=[87.9 31.1]';
F(:,3)=[58.5 61.4]';
F(:,4)=[88.3 60.9]';
% NV position
NVposition=[62.0, 23.7]';

tools.NVCooridinate(F, NVposition);