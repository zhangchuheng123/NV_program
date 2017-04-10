%% setup and move it to a position
global parameters;
parameters = default_parameter_constructor('lab5-lian', false);
parameters.figure.identifier =  'NV_111-1_';
tools = experiment_toolbox;
tools.scan_piezo(10, 10, 20, 1, 0);

%% Step1: scanz example
Z = 10:0.5:40;
CountNum = 20;
tools.scan_piezo(20, 20, Z, CountNum);

%% Step2: sample big marker
Z0 = 27.5;
CountNum = 5;
tools.scan_piezo(1:0.5:20, 1:0.5:20, Z0, CountNum);

%% sample area
cross_x = 9.5;
cross_y = 9;

X = 5:0.5:98;
Y = 5:0.5:98;
Z = [0, 6];
Z = Z + Z0; 
CountNum = 1;
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%% Center scan for NV
X0 = 44;
Y0 = 35;
Z = 6;
Delta = 2;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = Z + Z0;
CountNum = 10;
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%% scanz over NV
NV_x = 44.3;
NV_y = 35.1;
NV_z = 34;
Z = Z0-5:0.1:NV_z+5;
CountNum = 40;
tools.scan_piezo(NV_x, NV_y, Z, CountNum, 0);

%% Scan for small marker
first_x=cross_x+20;
first_y=cross_y+20;
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

Delta = 4;
X0=first_x;
Y0=first_y;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
tools.scan_piezo(X, Y, Z, CountNum, Z0);
tools.scan_piezo(X+30, Y, Z, CountNum, Z0);
tools.scan_piezo(X, Y+30, Z, CountNum, Z0);
tools.scan_piezo(X+30, Y+30, Z, CountNum, Z0);

%% NVCooridinate

% marker coordingate 
% sequence: (0,0) (0,30) (30,0) (30,30)
F(:,1)=[28.0,30.1]';
F(:,2)=[58.0,31.7]';
F(:,3)=[26.3,60.1]';
F(:,4)=[56.2,61.1]';
% NV position
NVposition=[NV_x,NV_y]';
script_NV_coordinate(F, NVposition);