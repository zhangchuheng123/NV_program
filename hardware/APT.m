function apt = APT
	apt.init = @init;
	apt.is_init = @is_init;
    apt.MOV = @MOV;
    apt.POS = @POS;
    apt.MVR = @MVR;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if (~isfield(Devices, 'APT'))
        if parameters.APT.is_show
            fpos = [0, 0, 400, 400];
            f1 = figure('Position', fpos, 'Menu','None', 'Name','APT GUI');
        else 
            f1 = figure('Menu','None', 'Name','APT GUI', 'Visible', 'off');
        end
        Devices.APT.motorx = actxcontrol('MGMOTOR.MGMotorCtrl.1',[0 0 200 400], f1);
        APT_initial(Devices.APT.motorx, parameters.APT.SNx);
        Devices.APT.motory = actxcontrol('MGMOTOR.MGMotorCtrl.1',[200 0 400 400], f1);
        APT_initial(Devices.APT.motory, parameters.APT.SNy);

        if parameters.APT.is_coord_when_init
            MOV(parameters.APT.coord_init.x, parameters.APT.coord_init.y);
        end
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'AWG'));
end

function APT_initial(handle, SN)
    global parameters;
    handle.StartCtrl;
    set(handle,'HWSerialNum', SN);
    handle.Identify;
    handle.EnableHWChannel(0);
    if parameters.APT.is_home_when_init
        % channel number = 0 
        % true: wait until it is finished
        handle.MoveHome(0, true);
    end
end

function MOV(x, y)
    global Devices
    move_abs(Devices.APT.motorx, x);
    move_abs(Devices.APT.motory, y);
end

function move_abs(handle, pos)
    handle.SetAbsMovePos(0, pos);
    handle.MoveAbsolute(0, true);
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

function move_rel(handle, dis)
    handle.SetRelMoveDist(0, dis);
    handle.MoveRelative(0, true);
end


function pos = POS
    global Devices;
    pos = [get_pos(Devices.APT.motorx), get_pos(Devices.APT.motory)];
end

function pos = get_pos(handle)
    pos = handle.GetPosition(0);
end