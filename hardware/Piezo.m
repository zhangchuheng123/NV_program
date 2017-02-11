function peizo = Peizo
	peizo.init = @init;
	peizo.is_init = @is_init;
	peizo.MOV = @MOV;
	peizo.MVR = @MVR;
	peizo.MVR_1D = @MVR_1D;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'Piezo'))
		Piezo = tcpip(parameters.Piezo.ip_name, parameters.Piezo.ip_port);
		fopen(Piezo);
	    fprintf(Piezo,'%s\n','ONL 1 1 2 1 3 1');
	    pause(0.1);
	    fprintf(Piezo,'%s\n','SVO 1 1 2 1 3 1');
	    pause(0.1);
	    fprintf(Piezo,'%s\n','VCO 1 1 2 1 3 1');  
	    pause(0.1);
	    fprintf(Piezo,'%s\n','DCO 1 1 2 1 3 1');
	    pause(0.1);
	    fprintf(Piezo,'%s\n','VEL 1 1000 2 1000 3 1000');
	    pause(0.1);
	    Devices.Piezo = Piezo;
        fprintf('Piezo: Initialization finished\n');
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'Piezo'));
end

function MOV(X, Y, Z)
    global Devices;
    s = ['MOV 1 ',num2str(X),' 2 ',num2str(Y),' 3 ',num2str(Z)];
    fprintf(Devices.Piezo,'%s\n', s);
end

function MVR(X, Y, Z)
    global Devices;
    s = 'MVR ';
    if (X ~= 0)
        s = [s, '1 ', num2str(X)];
    end
    if (Y ~= 0)
        s = [s, '2 ', num2str(Y)];
    end
    if (Z ~= 0)
        s = [s, '3 ', num2str(Z)];
    end
    if ~strcmp(s, 'MVR ')
        fprintf(Devices.Piezo,'%s\n', s);
    end
end

function MVR_1D(direction, stepsize)
    global Devices;
    s = ['MVR ', num2str(direction) ,' ', num2str(stepsize)];
    fprintf(Devices.Piezo, '%s\n', s);
end