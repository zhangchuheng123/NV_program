%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang', true);
parameters.figure.identifier =  'NV_mid_';
tools = experiment_toolbox;
tools.scan(50, 50, 20, 1, 0);
tools.large_scan(0, 0, 0, 0, 0)

%% scanz example
X = 50;
Y = 50;
Z = 1:0.5:50;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% large scan
Z0 = 18.5;
X_vol = -100:2:100;
Y_vol = -100:2:100;
APT_X = -0.01:0.01:0.01;
APT_Y = -0.01:0.01:0.01;
Z_rel = 10;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.large_scan(X_vol, Y_vol, APT_X, APT_Y, Z_rel, CountNum, Z0);

%% density scan
Z0 = 17;
X_vol = -100:2:100;
Y_vol = -100:2:100;
Z = [1];
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);