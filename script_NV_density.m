%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang');
parameters.figure.identifier =  'Scan_implant-1A_';
tools = experiment_toolbox;
tools.scan(50, 50, 20, 1, 0);

%% scanz example
X = 10;
Y = 10;
Z = 0:0.5:50;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% density scan
Z0 = 19;
X_vol = -400:2:400;
Y_vol = -400:2:400;
Z = [2, 5, 10, 20];
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror(X_vol, Y_vol, Z, CountNum, Z0);