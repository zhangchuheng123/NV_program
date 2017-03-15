%% setup and move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang', false);
parameters.figure.identifier =  'NV_mid1_';
tools = experiment_toolbox;
tools.scan_piezo(50, 50, 20, 1, 0);
tools.scan_large(0, 0, 0, 0, 0);

%% Step1: scanz example
X = 10:40:90;
Y = 10:40:90;
Z = 1:0.5:90;
CountNum = 20;
tools.scan_mirror(0, 0, 0, CountNum);
tools.scan_piezo(50, 50, Z, CountNum);
% tools.scan_surface(X, Y, Z, CountNum);

%% Step2A: sample surface area: Mirror
Z0 = 30.5;
X_vol = -200:3:200;
Y_vol = -200:3:200;
Z_rel = 0;
% Z_rel = 0;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_piezo(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);

%% Step2B: sample surface area: Piezo
Z0 = 32; 
X = 1:1:90;
Y = 1:1:90;
%Z_rel = [0, 5];
Z_rel = 0;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_mirror(0, 0, Z0, CountNum, Z0);
tools.scan_piezo(X, Y, Z, CountNum, Z0);
%% Step2.5: sample surface+5 area: Piezo
Z0 = 34.5;
X = 10D:0.3:90;
Y = 10:0.3:50;
%Z_rel = [0, 5];
Z_rel = 5;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_mirror(0, 0, Z0, CountNum, Z0);
tools.scan_piezo(X, Y, Z, CountNum, Z0);
%% Step2.2: scanz example marker
X = 67;
Y = 42;
Z = 1:0.5:90;
CountNum = 20;
tools.scan_mirror(0, 0, 0, CountNum);
tools.scan_piezo(X, Y, Z, CountNum);
% tools.scan_surface(X, Y, Z, CountNum);
%% Step3: sample big marker£º Piezo
Z0 = 30;
X0 = 80.5;
Y0 = 19.5;
span = 10;
X = X0-span:0.3:X0+span;
Y = Y0-span:0.3:Y0+span;
%Z_rel = -3:3:3;
Z_rel = 0;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_mirror(0, 0, Z0, CountNum, Z0);
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%% Step4: determine surface by a bright point on the marker
X0 = 83.4;
Y0 = 23.0;
Z = 26:0.1:35;
CountNum = 20;
tools.scan_piezo(X0, Y0, Z, CountNum);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
X0 = 25.9;
Y0 = 44.5;
Z = 5;
Z0 = 32;
Delta = 1;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = Z + Z0;
CountNum = 10;
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%% scanz over NV
NV_x = 38;
NV_y = 23.4;
Z = 31.5:0.1:50;
CountNum = 40;
tools.scan_piezo(NV_x, NV_y, Z, CountNum, 0);

%% Scan for small marker
%first_x = cross_x + 18.5;
%first_y = cross_y + 23.5;
first_x=47.2;
first_y=58.6;
%{
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
 
%}
Delta = 3;
X0=first_x;
Y0=first_y;
Z0=32.5;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
tools.scan_piezo(X, Y, Z, CountNum, Z0);
tools.scan_piezo(X-30, Y, Z, CountNum, Z0);
tools.scan_piezo(X, Y+30, Z, CountNum, Z0);
tools.scan_piezo(X-30, Y+30, Z, CountNum, Z0);

%% NVCooridinate

% marker coordingate 
% sequence: (0,0) (0,30) (30,0) (30,30)
F(:,1)=[25.8,70.2]';
F(:,2)=[55.8,69.4]';
F(:,3)=[24.9,40.3]';
F(:,4)=[54.6,39.4]';
% NV position
NVposition=[54.9,55.2]';
script_NV_coordinate(F, NVposition);