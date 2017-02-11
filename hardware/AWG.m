function awg = AWG
	awg.init = @init;
	awg.is_init = @is_init;
	awg.set_freq_MHz = @set_freq_MHz;
	awg.set_amp_voltage = @set_amp_voltage;
	awg.waveform_delete_all = @waveform_delete_all;
	awg.string = @string;
	awg.run = @run;
end

function init
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if ( strcmp(device_name, 'AWG') && (~isfield(Devices, 'AWG')) )
        AWG = tcpip(parameters.AWG.ip_name, parameters.AWG.ip_port);
        fopen(AWG);
        Devices.AWG = AWG;
        fprintf('AWG: Initialization finished\n');
    end
end

function re = is_init
	global Devices
	re = (~isempty(Devices)) && (isfield(Devices, 'AWG'));
end

function set_freq_MHz(channel, freq_MHz)
    global Devices;
    s = ['SOURCE',num2str(channel),':FREQUENCY ',num2str(freq_MHz), 'MHZ'];
    fprintf(Devices.AWG, '%s\n', s);
end

function set_amp_voltage(channel, Vpp)
    global Devices;
    s = ['SOURCE',num2str(channel),':VOLTAGE:AMPLITUDE ',num2str(Vpp), 'MHZ'];
    fprintf(Devices.AWG, '%s\n', s);
end

function waveform_delete_all
    global Devices;
    fprintf(Devices.AWG, '%s\n', 'WLIST:WAVEFORM:DELETE ALL');
end

function string(str)
    global Devices;
    fprintf(Devices.AWG, '%s\n', str);
end

function run
    ancilla_2lowerbound = 0;
    ancilla_2upperbound = 1.05;
    inconsistencytol = 30; %%check the maximal inconsistency tolorence relative to sqrt(), default value 3-4;
    loop_standard = parameters.laser_delay.loop_standard;
    
    AWGloop = parameters.AWG.loop_time;

    AWG_string('AWGControl:RMODE SEQUENCE');

    s = ['SEQUENCE:LENGTH ', num2str(loop_standard)];
    fprintf(AWG, '%s\n', s);
    for i = 1:loop_standard
        s1 = ['SEQUENCE:ELEMENT', num2str(i), ':WAVEFORM1', ' "AWG_wave_ch1"'];
        fprintf(AWG, '%s\n', s1);
        s2 = ['SEQUENCE:ELEMENT', num2str(i), ':WAVEFORM2', ' "AWG_wave_ch2"'];
        fprintf(AWG, '%s\n', s2);
        s4 = ['SEQUENCE:ELEMENT', num2str(i), ':LOOP:COUNT ', num2str(AWGloop)];
        fprintf(AWG, '%s\n', s4);
    end
    fprintf(AWG, '%s\n', 'OUTPUT1:STATE ON');
    fprintf(AWG, '%s\n', 'OUTPUT2:STATE ON');

    fprintf(['Threshold_fix:',num2str(Threshold_fix)]);
    Cali_back;

    while (count_loop < count_repeat)
        count_loop = count_loop + 1;
        ContCaliNum = 0;
        
        disp(['   now is measurement', num2str(j), ' count_loop', num2str(count_loop)]);
        disp(['   now the total calibration is ', num2str(CalibrationTotal)]);
        if ( (j > 1) || (count_loop > 1))
            Cali_back;
        end
        
        fprintf(AWG, '%s\n', 'AWGCONTROL:RUN');
        pause(pausetime);
        fprintf(Detector, '%d', [1]);
        Data_temp = fread(Detector, 6);
        ancilla_1(count_loop) = Data_temp(1)*65536 + Data_temp(2)*256 + Data_temp(3);
        ancilla_2(count_loop) = Data_temp(4)*65536 + Data_temp(5)*256 + Data_temp(6);
        fprintf(Detector, '%d', [0]);
        if ( ancilla_2(count_loop) == 0 )
            % j = j - 1;
            Detect_bug = 1;
            fprintf('Detect_bug in AWG_run!\n');
            break;
        else
            Threshold = loop_standard*Detect_duration*10^-9*Count*AWGloop;
            if ( (j == 1) && (count_loop == 1))
                if ( ( ancilla_2(count_loop) > (ancilla_2lowerbound*loop_standard*Detect_duration*10^-9*Count*AWGloop)) && ( ancilla_2(count_loop) < (ancilla_2upperbound*loop_standard*Detect_duration*10^-9*Count*AWGloop)))
                    Threshold = loop_standard*Detect_duration*10^-9*Count*AWGloop;
                else
                    if ( ancilla_2(count_loop) < (ancilla_2lowerbound*loop_standard*Detect_duration*10^-9*Count*AWGloop))
                        disp('ancilla_2 lowerbound reached while start the loop' )
                    else
                        disp('ancilla_2 upperbound reached while start the loop' )
                    end
                    disp(['   now is calibration']);
                    Cali_back;
                    count_loop = count_loop - 1;
                end
                
            else if ((ancilla_2(count_loop) < ancilla_2lowerbound*Threshold) || (ancilla_2(count_loop) > ancilla_2upperbound*Threshold) || (ancilla_1(count_loop) < 0.5*Threshold) || (ancilla_1(count_loop) > 1.3*Threshold))
                    
                    if (ancilla_2(count_loop) < ancilla_2lowerbound*Threshold)
                        disp('ancilla_2 lowerbound reached while in the loop')
                        fprintf([num2str(ancilla_2(count_loop)),'<',num2str(ancilla_2lowerbound*Threshold)]);
                    end
                    if (ancilla_2(count_loop) > ancilla_2upperbound*Threshold)
                        disp('ancilla_2 upperbound reached while in the loop')
                    end
                    disp(['   now is calibration']);
                    count_loop = count_loop-1;
                    CalibrationTotal = CalibrationTotal + 1;
                    Cali_back;
                end
            end
        end
    end
    %% check the data consistency
    if ( (max(abs(ancilla_2-mean(ancilla_2))) > inconsistencytol*mean(sqrt(ancilla_2)) ...
            ||  max(abs(ancilla_1-mean(ancilla_1))) > inconsistencytol*mean(sqrt(ancilla_1)) )...
            && Detect_bug~=1 )
        %j = j - 1;
        Detect_bug = 1;
        fprintf('data inconsistent!  %d\n',Cnt_det_bug+1);
        if max(abs(ancilla_2-mean(ancilla_2))) > inconsistencytol*mean(sqrt(ancilla_2))
            fprintf(['ancilla_2',num2str(ancilla_2)]);
        else
            fprintf(['ancilla_1',num2str(ancilla_1)]);
        end
    end
    %%
    ancilla_1_total = sum(ancilla_1);
    ancilla_2_total = sum(ancilla_2);
end