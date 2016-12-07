%% move it to a position
global parameters;
parameters = default_parameter_constructor('lab5-lian');
parameters.figure.identifier =  'Scan_natural-3_';
tools = experiment_toolbox;
tools.scan(10, 10, 20, 1, 0);

%% 