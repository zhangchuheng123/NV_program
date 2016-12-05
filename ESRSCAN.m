%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab5-lian');
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
Z0 = 26.3;
X = 1:0.5:20;
Y = 1:0.5:20;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% Center scan for NV
X0 = 9.5-11.0+23.9;
Y0 = 9.0-9.5+70.1;
Z = 5.7;
Delta = 3;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = Z + Z0;
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% scanz over NV
NV_x = 34.9;
NV_y = 32.8;
Z = Z0-5:0.1:Z0+10;
CountNum = 40;
tools.scan(NV_x, NV_y, Z, CountNum, 0);

%% ESR
NV_z = 36.0;
tools.scan(NV_x, NV_y, NV_z, 1, 0);

freq = 2.82:0.001:2.93;
pow = -18;
loop_num = 3;
each_repeat = 5;
tools.ESR(freq, pow, [loop_num, each_repeat]);