function mir = MIR
	mir.init = @init;
	mir.is_init = @is_init;
	mir.output = @output;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if ( strcmp(device_name, 'MIR') && (~isfield(Devices, 'MIR')) )
        MIR = serial('com10');
        % MIR.Terminator = 'CR';
        MIR.BaudRate = 2000000;
        MIR.StopBits = 2;
        fopen(MIR);
        Devices.MIR = MIR;
        % MIR_output(0, 0);
        % MIR_output(-300, 340);
        fprintf('MIR: Initialization finished\n');
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'MIR'));
end

function output(X, Y)
    %% move mir to the position (x,y)
    global Devices;

    byte_length = 2^8;

    ctrl_B = 1*(2^12);  
    ctrl_A = 8*(2^12);

    volt_A = 2440 + Y; % y
    volt_B = 1650 + X; % x

    cmd_A = ctrl_A + volt_A;         
    cmd_A = floor(cmd_A/byte_length) + byte_length * mod(cmd_A, byte_length);

    cmd_B = ctrl_B + volt_B;            
    cmd_B = floor(cmd_B/2^8) + 2^8*mod(cmd_B,2^8);

    fwrite(Devices.MIR, cmd_B, 'uint16');
    fwrite(Devices.MIR, cmd_A, 'uint16');        
end