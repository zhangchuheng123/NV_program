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
Z = 10:0.5:25;
CountNum = 10;
tools.scan(X, Y, Z, CountNum, 0);

%% large scan
% APT unit: mm
Z0 = 16;
X_vol = -200:2:200;
Y_vol = -200:2:200;
APT_X = -0.3:0.3:0.3;
APT_Y = -0.3:0.3:0.3;
Z_rel = [4, 6];
Z = Z_rel + Z0;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.large_scan(X_vol, Y_vol, APT_X, APT_Y, Z, CountNum, Z0);

%% density scan
Z0 = 24;
X_vol = -100:2:100;
Y_vol = -100:2:100;
Z_rel = 50;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror_fast(X_vol, Y_vol, Z, CountNum, Z0);

%% density scan
Z0 = 47;
X = 40:0.3:60;
Y = 40:0.3:60;
Z_rel = 30;
Z = Z0 + Z_rel;
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% center scan
X0 = 40;
Y0 = 43.3;
delta = 5;
X_vol = X0-delta:1:X0+delta;
Y_vol = Y0-delta:1:Y0+delta;
CountNum = 10;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror_fast(X_vol, Y_vol, Z, CountNum, Z0);

%% center scan
X0 = 45.7;
Y0 = 41.8;
delta = 1;
X = X0-delta:0.1:X0+delta;
Y = Y0-delta:0.1:Y0+delta;
CountNum  = 5;
tools.scan(X, Y, Z, CountNum, Z0);

%%
X0 = 45.7;
Y0 = 41.6;
Z = 77;
Z = Z-10:0.2:Z+10;
CountNum = 10;
tools.scan(X0, Y0, Z, CountNum, Z0);