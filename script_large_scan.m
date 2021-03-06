%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang', false);
parameters.figure.identifier =  'NV_mid1_';
tools = experiment_toolbox;
tools.scan_piezo(50, 50, 20, 1, 0);
tools.scan_large(0, 0, 0, 0, 0);

%% scanz example
%X = 10:40:90;

%Y = 10:40:90;
X = 10;
Y = 10;
Z = 1:0.5:90;
CountNum = 20;
%tools.scan_mirror(0, 0, 0, CountNum);
tools.scan_piezo(50, 50, Z, CountNum);
% tools.scan_piezo(X, Y, Z, CountNum);

%% large scan
% APT unit: mm
Z0 = 22.5;
X_vol = -200:4:200;
Y_vol = -200:4:200;
APT_X = -0.3:0.3:0.3;
APT_Y = -0.3:0.3:0.3;
Z_rel = 6;
Z = Z_rel + Z0;
CountNum = 1;
tools.scan_piezo(50, 50, Z0, 0);
tools.scan_large(X_vol, Y_vol, APT_X, APT_Y, Z, CountNum, Z0);

%% density scan mirror
Z0 = 22.5;
X_vol = -200:4:200;
Y_vol = -200:4:200;
Z_rel = 0;
% Z_rel = 0;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_piezo(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);

%% density scan
Z0 = 20;
X = 20:0.3:80;
Y = 20:0.3:80;
% Z_rel = [6, 8, 10, 15, 20, 25, 30];
% Z_rel = 5;
Z_rel = [4, 6, 8, 10];
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan_mirror(0, 0, 0, 1);
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%% center scan
Z = 40.5;
X0 = -52;
Y0 = -134;
delta = 5;
X_vol = X0-delta:1:X0+delta;
Y_vol = Y0-delta:1:Y0+delta;
CountNum = 20;
% tools.scan_piezo(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);

%% center scan
X0 = 31.4;
Y0 = 69.2;
delta = 1;
X = X0-delta:0.1:X0+delta;
Y = Y0-delta:0.1:Y0+delta;
Z_rel = 8;
Z = Z0 + Z_rel;
CountNum  = 20;
tools.scan_piezo(X, Y, Z, CountNum, Z0);

%%
mir.output(-46, 134);
X0 = 50;
Y0 = 50;
Z = 35.5;
Z = Z-10:0.2:Z+10;
CountNum = 20;
tools.scan_piezo(X0, Y0, Z, CountNum, Z0);