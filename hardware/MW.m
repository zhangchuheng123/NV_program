function mw = MW
	mw.init = @init;
	mw.is_init = @is_init;
	mw.power = @power;
	mw.turnon = @turnon;
	mw.turnoff = @turnoff;
	mw.frequency = @frequency;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'MW'))
        MW = tcpip(parameters.MW.ip_name, parameters.MW.ip_port);
        fopen(MW);
        Devices.MW = MW;
        fprintf('MW: Initialization finished\n');
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'MW'));
end

function power(pow)
    global Devices;
    s = [':POW ', num2str(pow), 'DBM'];
    fprintf(Devices.MW,'%s\n',s);
    pause(0.1);
end

function turnon
    global Devices;
    fprintf(Devices.MW,'%s\n',':OUTP ON');
    pause(0.1);
end

function channel(channel)
    global Devices;
    fprintf(Devices.MW,'%s %s\n', ':OUTP', num2str(channel));
    pause(0.1);
end

function turnoff
    global Devices;
    fprintf(Devices.MW,'%s\n',':OUTP OFF');
    pause(0.1);
end

function frequency(freq, amount)
    global Devices;
    if (nargin == 1)
        amount = 'G';
    end
    s = [':FREQ ', num2str(freq), amount, 'Hz'];
    fprintf(Devices.MW,'%s\n',s);
end