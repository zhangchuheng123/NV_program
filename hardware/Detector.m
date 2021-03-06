function detector = Detector
	detector.init = @init;
	detector.is_init = @is_init;
	detector.read = @read;
    detector.click = @click;
    detector.read_serial = @read_serial;
    detector.flush = @flush;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'Detector'))
        Detector = serial('com15','Timeout',1);
		Detector = serial(parameters.Detector.com_name);
	    Detector.Terminator = 'CR';
	    Detector.BaudRate = 2000000;
        Detector.InputBufferSize = 70000;
        Detector.OutputBufferSize = 70000;
	    fopen(Detector);
	    fprintf(Detector, '%d', 0);
	    fprintf(Detector, '%d', 1);
	    fread(Detector,6);
	    fprintf(Detector, '%d', 0);
	    Devices.Detector = Detector;
        fprintf('Detector: Initialization finished\n');
	end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'Detector'));
end

function click(round_num, time_ms)
    global Devices parameters;
    pause_time = parameters.Detector.click_pause_time;
    if (nargin == 0)
        round_num = 1;
        time_ms = 10;
    elseif (nargin == 1)
        time_ms = 10;
    end
    if (time_ms == 10)
        bit_num = 2;
    elseif (time_ms == 100)
        bit_num = 4;
    end
    for num = 1:round_num
        t_click = tic;
        while (toc(t_click) < pause_time)
        end
        fprintf(Devices.Detector,'%d', [bit_num, 0]);
    end
end

function result = read_serial(point_num, round_num, time_ms)
    global Devices;
    if (nargin == 0)
        point_num = 1;
        round_num = 1;
        time_ms = 10;
    elseif (nargin == 1)
        round_num = 1;
        time_ms = 10;
    elseif  (nargin == 2)
        time_ms = 10;
    end
        
    if (time_ms == 10)
        ratio = 0.1;
    elseif (time_ms == 100)
        ratio = 0.01;
    end

    total_bytes = point_num .* round_num .* 6;
    result = fread(Devices.Detector, total_bytes);
    scale_vec = 256 .^ (2:-1:0).';
    result = reshape(result, 3, []);
    result = sum(bsxfun(@times, result, scale_vec)).';
    result = reshape(result, 2, []);
    result = result(2, :);
    result = reshape(result, round_num, []);
    result = mean(result, 1);
    result = result .* ratio;
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
        fprintf(Devices.Detector,'%d', bit_num);
        data_reader = fread(Devices.Detector, 6);
        fprintf(Devices.Detector,'%d', 0);
        count = count + data_reader(4)*65536 + data_reader(5)*256 + data_reader(6);
    end
    count = count .* ratio ./ round_num;
end

function flush
    global Devices;
    if (Devices.Detector.BytesAvailable > 0)
        fread(Devices.Detector, Devices.Detector.BytesAvailable);
    end
end