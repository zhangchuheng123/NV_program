function apt = APT
	apt.init = @init;
	apt.is_init = @is_init;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'APT'))
        if parameters.APT.is_show
            fpos = [0, 0, 100, 100];
            f1 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI');
            f2 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI');
        else 
            f1 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI', 'Visible', 'off');
            f2 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI', 'Visible', 'off');
        Devices.APT.motor1 = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f1);
        APT_initial(Devices.APT.motor1, parameters.APT.SN1);
        Devices.APT.motor2 = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f2);
        APT_initial(Devices.APT.motor2, parameters.APT.SN2);
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'AWG'));
end

function APT_initial(handle, SN)
    handle.StartCtrl;
    set(handle,'HWSerialNum', SN);
    handle.Identify;
    handle.EnableHWChannel(0);
    % channel number = 0 
    % wait until it is finished
    handle.MoveHome(0, true);
end

function MOV(handle, dis)
    handle.SetAbsMovePos(0, dis);
    handle.MoveAbsolute(0, true);
end