%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab1-jiang');
parameters.figure.identifier =  'Scan_implant-2_';
tools = experiment_toolbox;
tools.scan(50, 50, 20, 1, 0);

%% scanz example
X = 10;
Y = 10;
Z = 10:0.5:60;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% density scan
Z0 = 25;
X_vol = -400:4:400;
Y_vol = -400:4:400;
Z = 2;
CountNum = 1;
tools.scan(50, 50, Z0, 0);
tools.scan_mirror(X, Y, Z, CountNum, Z0);