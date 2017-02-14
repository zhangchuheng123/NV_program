%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang', false);
parameters.figure.identifier =  'NV_mid_';
tools = experiment_toolbox;
tools.scan(50, 50, 20, 1, 0);
tools.large_scan(0, 0, 0, 0, 0);

%% scanz example
X = 50;
Y = 50;
Z = 1:0.5:50;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% large scan
% APT unit: mm
Z0 = 17;
X_vol = -400:2:400;
Y_vol = -400:2:400;
APT_X = -0.05:0.1:0.05;
APT_Y = -0.05:0.1:0.05;
Z_rel = [2, 10];
Z = Z_rel + Z0;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.large_scan(X_vol, Y_vol, APT_X, APT_Y, Z, CountNum, Z0);

%% density scan
Z0 = 17;
X_vol = -400:2:400;
Y_vol = -400:2:400;
Z_rel = 10;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);

%% density scan
Z0 = 16.5;
X = 40:0.3:60;
Y = 40:0.3:60;
Z_rel = 30;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% center scan
Z0 = 17;
X0 = -236;
Y0 = -220;
delta = 50;
X_vol = X0-delta:2:X0+delta;
Y_vol = Y0-delta:2:Y0+delta;
Z_rel = 10;
Z = Z_rel + Z0;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);

%% center scan
X0 = 54.2;
Y0 = 46.9;
Z0 = 16.5;
delta = 1;
X = X0-delta:0.1:X0+delta;
Y = Y0-delta:0.1:Y0+delta;
Z_rel = 30;
Z = Z0 + Z_rel;
CountNum  = 10;
tools.scan(X, Y, Z, CountNum, Z0);

%%
Z = Z_rel+Z0-10:0.2:Z_rel+Z0+10;
CountNum = 10;
tools.scan(X0, Y0, Z, CountNum, Z0);