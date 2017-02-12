function apt = APT
	apt.init = @init;
	apt.is_init = @is_init;
    apt.MOV = @MOV;
    apt.MVR = @MVR;
    apt.HOME = @HOME;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'APT'))
        if parameters.APT.is_show
            fpos = [20, 20, 820, 820];
            f1 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI');
        else 
            f1 = figure('Menu','None', 'Name','APT GUI', 'Visible', 'off');
        end
        Devices.APT.motorx = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 0 800 400], f1);
        APT_initial(Devices.APT.motorx, parameters.APT.SNx);
        Devices.APT.motory = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 400 800 400], f1);
        APT_initial(Devices.APT.motory, parameters.APT.SNy);

        if parameters.APT.is_coord_when_init
            HOME();
        end
	end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'AWG'));
end

function APT_initial(h, SN)
    global parameters;
    h.StartCtrl;
    set(h,'HWSerialNum', SN);
    h.Identify;
    h.EnableHWChannel(0);
    if parameters.APT.is_home_when_init
        % channel number = 0 
        % true: wait until it is finished
        h.MoveHome(0, true);
    end
end

function MOV(x, y)
    global Devices;
    move_abs(Devices.APT.motorx, x);
    move_abs(Devices.APT.motory, y);
end

function HOME
    global parameters;
    MOV(parameters.APT.coord_init.x, parameters.APT.coord_init.y);
end

function move_abs(h, pos)
    h.SetAbsMovePos(0, pos);
    h.MoveAbsolute(0, true);
end

function MVR(x, y)
    global Devices
    if (x ~= 0)
        move_rel(Devices.APT.motorx, x);
    end
    if (y ~= 0)
        move_rel(Devices.APT.motory, y);
    end
end

function move_rel(h, dis)
    h.SetRelMoveDist(0, dis);
    h.MoveRelative(0, true);
end