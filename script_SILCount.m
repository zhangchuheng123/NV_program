%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab5-lian');
parameters.figure.identifier =  'Scan_natural-3_';
tools = experiment_toolbox;
tools.scan(50, 50, 30, 1, 0);

%% scanz example
X = 10;
Y = 10;
Z = 23:0.1:26;
CountNum = 40;
tools.scan(X, Y, Z, CountNum, 0);

%% sample SIL
Z0 = 24.2;
Rsil = 8.136;
ratio = 0.40;

Delta = 10;
center_x = 50;
center_y = 50;
X = center_x-Delta:0.5:center_x+Delta;
Y = center_y-Delta:0.5:center_y+Delta;
Z = Rsil + Rsil * ratio * 1.7;
fprintf('calculated z = %.2f \n', Z);
Z = fix(Z * 10) / 10;
Z = Z + Z0; 
% Z = [Z, Z+2, Z+4];
CountNum = 1;
tools.scan(X, Y, Z, CountNum, Z0);

%% calibration
NV_x = 49;
NV_y = 51.5;
tools.calibration(inf, [NV_x, NV_y, Z]);

%% ESR
freq = 2.82:0.001:2.93;
pow = -18;
loop_num = 3;
each_repeat = 5;
tools.ESR(freq, pow, [loop_num, each_repeat]);