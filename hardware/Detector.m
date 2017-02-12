function detector = Detector
	detector.init = @init;
	detector.is_init = @is_init;
	detector.read = @read;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'Detector'))
		Detector = serial(parameters.Detector.com_name);
	    Detector.Terminator = 'CR';
	    Detector.BaudRate = 2000000;
	    fopen(Detector);
	    fprintf(Detector, '%d', [0]);
	    fprintf(Detector, '%d', [1]);
	    fread(Detector,6);
	    fprintf(Detector, '%d', [0]);
	    Devices.Detector = Detector;
        fprintf('Detector: Initialization finished\n');
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'Detector'));
end

function count = read(round_num, time_ms)
    global Devices;
    if (nargin == 0)
        round_num = 1;
        time_ms = 10;
    elseif (nargin == 1)
        time_ms = 10;
    end
    if (time_ms == 10)
        bit_num = 2;
        ratio = 0.1;
    elseif (time_ms == 100)
        bit_num = 4;
        ratio = 0.01;
    end
    count = 0;
    for num = 1:round_num
        fprintf(Devices.Detector,'%d', [bit_num]);
        data_reader = fread(Devices.Detector, 6);
        fprintf(Devices.Detector,'%d', [0]);
        count = count + data_reader(4)*65536 + data_reader(5)*256 + data_reader(6);
    end
    count = count .* ratio ./ round_num;
end