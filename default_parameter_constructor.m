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

	% step size for calibration
	parameters.calibration.step_size = 0.1;
	% step size decay
	parameters.calibration.half_decay_iter_number = inf;
	% pause time of each MVR
	parameters.calibration.pause_time = 0.1;
    
    % whether do calibration between ESR or not
    parameters.esr.calibration_in_esr = 1;
    % number of round of calibration
    parameters.esr.calibration_interval = 10;

    % AWG sample rate -> 1GHz = 1000kHz
    parameters.AWG.sample_rate = 1000;
    % whether there's bug in AWG
    parameters.AWG.is_detect_bug = 0;
    % path of AWG temp file
    parameters.AWG.path = 'AWG\ZhangChuheng\LaserDelay_IQ';
    % AWG loop time
    parameters.AWG.loop_time = 50000; % 50000ns = 50us

    parameters.laser_delay.length = 12; % 12000ns = 12us
    parameters.laser_delay.total_length_time = parameters.laser_delay.length * parameters.AWG.sample_rate; 
    parameters.laser_delay.loop_standard = 5;
    parameters.laser_delay.laser_init_time = 2000; % 2000ns = 2us
    parameters.laser_delay.detection_duration_time = 300; % 300ns

end