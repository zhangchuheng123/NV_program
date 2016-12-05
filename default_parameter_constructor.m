function parameters = default_parameter_constructor(stage_name)
	parameters.stage = stage_name;
	if (strcmp(parameters.stage, 'lab5-lian'))
		parameters.Piezo.ip_name = '192.168.54.3';
		parameters.Piezo.ip_port = 50000;
		parameters.Detector.com_name = 'com3';
		parameters.AWG.ip_name = '192.168.54.5';
		parameters.AWG.ip_port = 4000;
		parameters.MW.ip_name = '192.168.54.4';
		parameters.MW.ip_port = 5025;
	end

	% waiting time between each sample point
	% how to calculate pause time : piezo velocity 1000um/s, fixed time for movement: 50~100ms
	parameters.scan.scan_pause_time = 0.06;
	% waiting time between two lines 
	parameters.scan.scan_pause_time_long = 0.2;

	% file name prefix
	parameters.figure.identifier = 'default_identifier_';
	% automatically save data and figure : Yes -> 1 | No -> 0
	parameters.figure.is_save = 1; 
end