%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab5-lian');
parameters.figure.identifier =  'Scan_natural-3_';
tools = experiment_toolbox;

freq = 2.82:0.001:2.93;
pow = -18;
loop_num = 3;
each_repeat = 5;
tools.ESR(freq, pow, [loop_num, each_repeat]);