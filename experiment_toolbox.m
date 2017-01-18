function tools = experiment_toolbox
	tools.Initializer = @Initializer;
	tools.scan = @scan;
    tools.scan_mirror = @scan_mirror;
    tools.ESR = @ESR;
    tools.calibration = @calibration;
end

function Initializer(device_name)
	global Devices parameters;
	if (isempty(Devices))
		delete(instrfindall);
	end
	if ((strcmp(device_name, 'Piezo')) && (~isfield(Devices, 'Piezo')))
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
	elseif ( strcmp(device_name, 'Detector') && (~isfield(Devices, 'Detector')) )
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
	elseif ( strcmp(device_name, 'MW') && (~isfield(Devices, 'MW')) )
        MW = tcpip(parameters.MW.ip_name, parameters.MW.ip_port);
        fopen(MW);
        Devices.MW = MW;
        fprintf('MW: Initialization finished\n');
	elseif ( strcmp(device_name, 'AWG') && (~isfield(Devices, 'AWG')) )
        AWG = tcpip(parameters.AWG.ip_name, parameters.AWG.ip_port);
        fopen(AWG);
        Devices.AWG = AWG;
        fprintf('AWG: Initialization finished\n');
	elseif ( strcmp(device_name, 'MIR') && (~isfield(Devices, 'MIR')) )
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

function scan_mirror(X, Y, Z_rel, CountNum, Z0)
    %   author:   Zhang Chuheng 
    %   email:    zhangchuheng123 (AT) gmail.com
    %   home:     zhangchuheng123.github.io
    %   github:   zhangchuheng123
    % Date:     
    %   Establish:          Jan. 18, 2017

    global Devices parameters;

    if (nargin == 4)
        Z0 = 0;
    end

    % Check for initialization
    if ( (isempty(Devices)) || (~isfield(Devices, 'Detector')) )
        Initializer('Detector');       
    end
    if ( (isempty(Devices)) || (~isfield(Devices, 'Piezo')) )
        Initializer('Piezo');       
    end
    if ( (isempty(Devices)) || (~isfield(Devices, 'MIR')) )
        Initializer('MIR');      
    end

    scan_pause_time_long = parameters.scan.scan_pause_time_long;

    MIR_output(X(0), Y(0)), pause(0.2);
    Detector_read();

    data = zeros(numel(X), numel(Y), numel(Z_rel));
    total_count = numel(X) * numel(Y) * numel(Z_rel);
    count = 0;

    hwait=waitbar(0, 'Please wait...', 'Name', 'Mirror Scanning...');
    c = onCleanup(@()close(hwait));

    tic;
    
    for ind3 = 1:numel(Z_rel)
        Piezo_MVR(0, 0, Z_rel(ind3)), pause(scan_pause_time_long);
        for ind2 = 1:numel(Y)

            if (mod(ind2, 2) == 1)
                ind1_list = 1:numel(X);
            else
                ind1_list = numel(X):-1:1;
            end

            for ind1 = ind1_list
                MIR_output(X(ind1), Y(ind2));

                % read data
                ancilla = Detector_read(CountNum);
                data(ind1, ind2, ind3) = ancilla;

                % update processing bar
                count = count + 1;
                ratio = count ./ total_count;
                t = toc;
                remaining_time = fix(t ./ ratio .* (1 - ratio));
                str = sprintf('count at (%.1f, %.1f) = %.1f Now processing %.1f %% \n Time remaining %d s', ...
                    X(ind1), Y(ind2), ancilla, fix(ratio .* 1000)/10, remaining_time);
                waitbar(ratio, hwait, str);
            end
        end
    end

    fig_hdl = scan_plot(X, Y, Z_rel+Z0, data, Z0);

    if (parameters.figure.is_save == 1)
        auto_save(fig_hdl, X, Y, Z_rel+Z0, data, parameters.figure.identifier, '-MirrorScan');
    end
end

function scan(X, Y, Z, CountNum, Z0)
	% 	author:   Zhang Chuheng 
	%   email:    zhangchuheng123 (AT) gmail.com
	%   home:     zhangchuheng123.github.io
	%   github:   zhangchuheng123
	% Date:     
	%   Establish:          Sep. 15, 2016
	%   Modify:             Oct. 23, 2016       modify ip address of detector in lab1
	%   Modify:             Oct. 24, 2016       correct the file name mistake / 
	%											caption relative depth rather than z cooridinate
	%   Modify:             Oct. 26, 2016       show z as well as depth
	%   Modify:             Oct. 26, 2016       optimize figure(jpg) output
	%   Modify:             Oct. 29, 2016       add cleanup script
	%   Modify:             Nov. 09, 2016       introduce long scan pause time
	%   Modify:             Nov. 10, 2016       save to different folder 
	%   Establish v2.0      Nov. 17, 2016       use it as a function
	% 	Establish v3.0		Dec. 03, 2016 		as a function of the toolbox
	% Description:
	%   This is a all-in-one package for scanning fluorescent shining in diamond.
	%   Initialization of hardware devices - piezo and detector - is included.

    global Devices parameters;

    % Check for initialization
	if ( (isempty(Devices)) || (~isfield(Devices, 'Piezo')) || (~isfield(Devices, 'Detector')) )
		Initializer('Piezo');
		Initializer('Detector');		
	end

    scan_pause_time = parameters.scan.scan_pause_time;
    scan_pause_time_long = parameters.scan.scan_pause_time_long;

    Piezo_MOV(X(1), Y(1), Z(1)), pause(1);
    Detector_read();

    data = zeros(numel(X), numel(Y), numel(Z));
    total_count = numel(X) * numel(Y) * numel(Z);
    count = 0;
    
    if (total_count == 1)
    	Piezo_MOV(X(1), Y(1), Z(1));
        fprintf('Move piezo to position ... done\n');
        return;
    end

    hwait=waitbar(0, 'Please wait...', 'Name', 'Scanning...');
    c = onCleanup(@()close(hwait));
    
    tic;
    
    for ind3 = 1:numel(Z)
        for ind2 = 1:numel(Y)

        	Piezo_MOV(X(1), Y(ind2), Z(ind3));
            pause(scan_pause_time_long);

            for ind1 = 1:numel(X)
                % move piezo to new position
                if (ind1 ~= 1)
                    step_x = X(2) - X(1);
                    Piezo_MVR(step_x, 0, 0);
                    pause(scan_pause_time);
                end 
                % read data
                ancilla = Detector_read(CountNum);
                data(ind1, ind2, ind3) = ancilla;

                % update processing bar
                count = count + 1;
                ratio = count ./ total_count;
                t = toc;
                remaining_time = fix(t ./ ratio .* (1 - ratio));
                str = sprintf('count at (%.1f, %.1f, %.1f) = %.1f Now processing %.1f %% \n Time remaining %d s', ...
                    X(ind1), Y(ind2),  Z(ind3), ancilla, fix(ratio .* 1000)/10, remaining_time);
                waitbar(ratio, hwait, str);
            end
        end
    end

    fig_hdl = scan_plot(X, Y, Z, data, Z0);

    if (parameters.figure.is_save == 1)
        auto_save(fig_hdl, X, Y, Z, data, parameters.figure.identifier, '-Scan');
    end
end 

function fig_hdl = scan_plot(X, Y, Z, data, Z0)
    XYZ = {X, Y, Z};
    if (nargin == 4)
        Z0 = 0;
    end
    dim = [numel(X), numel(Y), numel(Z)];
    total_dim = numel(find(dim ~= 1));
    dim_caption = ['x', 'y', 'z'];

    % Line scan
    if (total_dim == 1)
        % non-degenerated dimension
        dim_id1 = find(dim ~= 1);
        % degenerated dimension
        dim_id2 = find(dim == 1);
        fig_hdl = figure;
        plot(XYZ{dim_id1}, squeeze(data));
        ylim([0, max(data(:))]);
        xlabel(dim_caption(dim_id1));
        ylabel('Intensity(count)');
        title(['Line scan along ', dim_caption(dim_id1), ' axis @', ...
            '(', dim_caption(dim_id2(1)),  ', ', dim_caption(dim_id2(2)),') = ', ...
            '(', num2str(XYZ{dim_id2(1)}), ', ', num2str(XYZ{dim_id2(2)}),') ( kilo counts/sec )']);
    end

    % Surface scan
    if (total_dim == 2)
        % non-degenerated dimension
        dim_id1 = find(dim ~= 1);
        % degenerated dimension
        dim_id2 = find(dim == 1);
        fig_hdl = figure; 
        imagesc(XYZ{dim_id1(1)}, XYZ{dim_id1(2)}, transpose(squeeze(data)));
        xlabel(dim_caption(dim_id1(1)));
        ylabel(dim_caption(dim_id1(2)));
        title(['Surface scan of ', dim_caption(dim_id1(1)), '-', dim_caption(dim_id1(2)), ' @', ...
            dim_caption(dim_id2), ' = ', num2str(XYZ{dim_id2}), '( kilo counts/sec )']);
        colorbar;
    end

    % Volume scan
    if (total_dim == 3)
        num_z = numel(Z);
        plot_numset_1 = [1,1,1,2,2,2,2,2,3,2,3,3,3,3,3,4,4,4,4,4];
        plot_numset_2 = [1,2,3,2,3,3,4,4,3,5,4,4,5,5,5,4,5,5,5,5];
        if (num_z < 20)
            plot_num1 = plot_numset_1(num_z);
            plot_num2 = plot_numset_2(num_z);
        else
            plot_num1 = ceil(sqrt(num_z));
            plot_num2 = plot_num1;
        end
        fig_hdl = figure;
        for ind = 1:num_z
            subplot(plot_num1, plot_num2, ind), 
            imagesc(X, Y, transpose(data(:,:,ind)));
            xlabel(dim_caption(1));
            ylabel(dim_caption(2));
            title(['depth = ',num2str(Z(ind)-Z0),' z =',num2str(Z(ind))]);
            colorbar;
        end
        suptitle('Volume scan ( kilo counts/sec )');
    end
end

function auto_save(fig_hdl, X, Y, Z, data, identifier, folder_name)
    % save figure described by fig_hdl and (XYZ & data)

    XYZ = {X, Y, Z};
    
    % maximize the window of the figure
    set(fig_hdl,'outerposition',get(0,'screensize'));
    fig_hdl.PaperPositionMode = 'auto';
    
    %% auto save for data and figure
    if (nargin == 6)
        str_date = datestr(now,'yyyymmdd');
    else
        str_date = [datestr(now,'yyyymmdd'), folder_name];
    end
    figure_dir = ['fig/fig', str_date];
    data_dir = ['data/data', str_date];

    % establish working dir if not exist
    if (~exist(figure_dir, 'dir'))
        mkdir(figure_dir);
    end
    if (~exist(data_dir, 'dir'))
        mkdir(data_dir);
    end

    str = datestr(now,'yyyymmddHHMMss');
    print(fig_hdl, fullfile(figure_dir, [identifier, str]), '-djpeg','-r0');
    saveas(fig_hdl, fullfile(figure_dir, [identifier, str]), 'fig');

    str_mat = [identifier, str, '.mat'];
    save(fullfile(data_dir, str_mat), 'data', 'XYZ');
end

function ESR(freq, pow, loop)
    global Devices parameters;
    if ( (isempty(Devices)) || (~isfield(Devices, 'Piezo')) || (~isfield(Devices, 'Detector')) )
		Initializer('Piezo');
		Initializer('Detector');		
    end
	if ( (isempty(Devices)) || (~isfield(Devices, 'MW')) )
		Initializer('MW');	
	end
    MW_power(pow);
    MW_turnon;
    ESR_data = zeros(1,numel(freq));
    
    hwait=waitbar(0, 'Please wait...', 'Name', 'ESR...');
    c = onCleanup(@()close(hwait));
    total_count = loop(1) * numel(freq);
    count = 0;
    tic;
    
    for n = 1:loop(1)
        for k = 1:numel(freq)
            MW_frequency(freq(k)), pause(0.03);
            ESR_data(k) = ESR_data(k) + Detector_read(loop(2), 100);
            
            if (parameters.esr.calibration_in_esr == 1)
                if (mod(count, parameters.esr.calibration_interval) == 0)
                    calibration(5);
                end
            end
            % update processing bar
            count = count + 1;
            ratio = count ./ total_count;
            t = toc;
            remaining_time = fix(t ./ ratio .* (1 - ratio));
            str = sprintf('(count at freq = %.3f GHz) = %.1f Now processing %.1f %% \n Time remaining %d s', ...
                freq(k), ESR_data(k), fix(ratio .* 1000)/10, remaining_time);
            waitbar(ratio, hwait, str);
        end
    end
    ESR_data = ESR_data ./ loop(1);
    fig_hdl = ESR_plot(freq, pow, ESR_data);
    if (parameters.figure.is_save == 1)
        X = freq;
        auto_save(fig_hdl, X, 1, 1, ESR_data, parameters.figure.identifier, '-ESR');
    end
    MW_turnoff;
end

function fig_hdl = ESR_plot(freq, pow, data)
    fig_hdl = figure;
    plot(freq, data);
    xlabel('frequency(GHz)');
    ylabel('fluorescent(kilo count/s)');
    title(sprintf('ESR Scan power = %.1f dBm', pow));
end

function calibration(count, position)
    global Devices parameters;

    if (nargin == 2)
       Piezo_MOV(position(1), position(2), position(3));
    end
    
    stepsize = parameters.calibration.step_size;
    half_decay_iter_number = parameters.calibration.half_decay_iter_number;

    % Check for initialization
    if ( (isempty(Devices)) || (~isfield(Devices, 'Piezo')) || (~isfield(Devices, 'Detector')) )
        Initializer('Piezo');
        Initializer('Detector');        
    end
    
    iter_number = 0;

    if (count == inf)
        count = double(intmax('int32'));
    end

    for i = 1:count
        current_stepsize = stepsize .* rand() .* exp(-(iter_number / half_decay_iter_number));
        iter_number = iter_number + 1;
        calibration_once(current_stepsize);
    end
end

function calibration_once(current_stepsize)
    global parameters;
    
    pause_time = parameters.calibration.pause_time;
    data = zeros(3,3,3);
    % original point
    data(2,2,2) = Detector_read(1, 100);
    % display current count
    fprintf('Calibration center counts = %.2f k\n', data(2,2,2));
    % get the other six points
    for direction = 1:3
        Piezo_MVR_1D(direction, current_stepsize), pause(pause_time);
        data(2 + (direction == 1),2 + (direction == 2),2 + (direction == 3)) = Detector_read(1, 100);
        Piezo_MVR_1D(direction, - 2*current_stepsize), pause(pause_time);
        data(2 - (direction == 1),2 - (direction == 2),2 - (direction == 3)) = Detector_read(1, 100);
        Piezo_MVR_1D(direction, current_stepsize), pause(pause_time);
    end
    % find which point gets the maximum counts, and move to that point
    index = find(data == max(data(:)), 1, 'first');
    [ind1, ind2, ind3] = ind2sub([3,3,3], index);
    ind = [ind1, ind2, ind3];
    direction = find(ind ~= 2, 1, 'first'); 
    if (~ isempty(direction))
        pm_sign = ind(direction) - 2;
        Piezo_MVR_1D(direction, pm_sign .* current_stepsize), pause(pause_time);
    end
end

function result = LaserDelay_IQ_main(delay_time, IQ_phase, ...
    MWFreq, MWPower, AWGVpp1, AWGVpp2, AWGVpp3, loop_repeat, Count)

    % all the time units are counted in ns
    % delay_time : ~1000ns 

    % !!!!!! unfinished

    global parameters;

    Sample_rate = parameters.AWG.sample_rate;
    loop_standard = parameters.laser_delay.loop_standard; % 5
    laser_init_time = parameters.laser_delay.laser_init_time;
    detection_duration_time = parameters.laser_delay.detection_duration_time;
    total_length_time = parameters.laser_delay.total_length_time;
    
    CalibrationTotal = 0;
    CaliTotal = 0;

    % Initialization devices
    AWG_set_freq_MHz(1, Sample_rate);
    AWG_set_amp_voltage(1, AWGVpp1);
    AWG_set_amp_voltage(2, AWGVpp2);
    AWG_set_amp_voltage(3, AWGVpp3);

    MW_channel(1);
    MW_frequency(MWFreq, 'M'); 
    MW_power(MWPower);

    Data_raw = [];
    Data_ratio = [];
    ancilla_1 = [];
    count_repeat = loop_repeat / loop_standard;
    pausetime = loop_standard * Length * 0.05 + 1.5;
    ancilla_2 = [];
    cali_flag = 0;

    % Read 100ms
    data = Detector_read(1, 100);

    Threshold_fix = Count/10;

    for delay_time_item = delay_time

        Zero_waveform = zeros(1,3);
        Zero_waveform(1,2) = Total;

        sig_start_time = total_length_time - 3000;
        ref_start_time = total_length_time - 1000;

        Laser_waveform = [0, laser_init_time, 1;
                          laser_init_time, sig_start_time - delay_time_item, 0;
                          sig_start_time - delay_time_item, total_length_time, 1];

        Sig_waveform = [0, sig_start_time, 0;
                        sig_start_time, sig_start_time + detection_duration_time, 1;
                        sig_start_time + detection_duration_time, total_length_time, 0];

        Ref_waveform = [0, ref_start_time, 0;
                        ref_start_time, ref_start_time + detection_duration_time, 1;
                        ref_start_time + detection_duration_time, total_length_time, 0];

        A_analog = Zero_waveform;
        A_Digi1 = Laser_waveform;   % Channel 1 Digital 1 -> AOM -> Laser
        A_Digi2 = Zero_waveform;

        B_analog = Zero_waveform;
        B_Digi1 = Sig_waveform;     % Channel 2 Digital 1\2 -> FPGA -> Detector
        B_Digi2 = Ref_waveform;

        C_analog = Zero_waveform;
        C_Digi1 = Zero_waveform;
        C_Digi2 = Zero_waveform;
        
        A1 = wave_generator(A_analog, Length);
        A2 = wave_generator(A_Digi1, Length);
        A3 = wave_generator(A_Digi2, Length);
        AWG_wave_ch1 = reshape([A1,A2,A3]',[],3);
        
        B1 = wave_generator(B_analog, Length);
        B2 = wave_generator(B_Digi1, Length);
        B3 = wave_generator(B_Digi2, Length);
        AWG_wave_ch2 = reshape([B1,B2,B3]',[],3);
        
        C1 = wave_generator(C_analog, Length);;
        C2 = wave_generator(C_Digi1, Length);
        C3 = wave_generator(C_Digi1, Length);
        AWG_wave_ch3 = reshape([C1,C2,C3]',[],3);
        
        local_path = ['E:\', parameters.AWG.path];
        if (~exist(local_path))
            mkdir(local_path);
        end
        csvwrite([local_path, 'AWG_wave_ch1'], AWG_wave_ch1);
        csvwrite([local_path, 'AWG_wave_ch2'], AWG_wave_ch2);
        csvwrite([local_path, 'AWG_wave_ch3'], AWG_wave_ch3);
        AWG_string('MMEMORY:IMPORT "AWG_wave_ch1","Z:\AWG\LaserDelay_IQ\AWG_wave_ch1.txt",TXT');
        AWG_string('MMEMORY:IMPORT "AWG_wave_ch1","Z:\AWG\LaserDelay_IQ\AWG_wave_ch2.txt",TXT');
        AWG_string('MMEMORY:IMPORT "AWG_wave_ch1","Z:\AWG\LaserDelay_IQ\AWG_wave_ch3.txt",TXT');
        
        AWG_run;
        
    end

    Data_Save_LaserDelay_IQ;
    saveas(gcf,Save_fig);
    result = 0;

end

function A = wave_generator(Waveform, Length)
% Input:
% Sample_rate       kHz
% Length            how many seconds (?)

% Waveform format:
% 3     [start_point, end_point, Digital_value]
% 5     [start_point, end_point, Freq, Phase, Amplitude]
% 6     [start_point, end_point, Freq, Phase, Amplitude, Delay]
% 8     [start_point, end_point, Freq1, Phase1, Amplitude1, Freq2, Phase2, Amplitude2]
% 9     [start_point, end_point, Freq1, Phase1, Amplitude1, Freq2, Phase2, Amplitude2, Delay]

    global parameters;
    Sample_rate = parameters.AWG.sample_rate;
    Total = Length*Sample_rate;
    A = [];
    [dimx,dimy] = size(Waveform); 
    if ((dimy == 5) || (dimy == 6))
        for i = 1:dimx
            B = round(Waveform(i,1)):round(Waveform(i,2)-1);
            C = Waveform(i,5)*sin(2 * pi * Waveform(i,3) / Sample_rate * B + Waveform(i,4));
            if (dimy == 6)
                Delay = zeros(1,round(Waveform(i,6)));
            elseif (dimy == 5)
                if (i < dimx)
                    Delay = zeros(1,round(Waveform(i+1,1)-Waveform(i,2)));
                elseif (i == dimx)
                    Delay = zeros(1,round(Total-Waveform(i,2)));
                end
            end
            A = [A, C, Delay];
        end
        
    elseif ((dimy == 9) || (dimy == 8))
        for i = 1:dimx
            B = round(Waveform(i,1)):round((Waveform(i,2)-1));
            C = Waveform(i,5)*sin(2 * pi * Waveform(i,3) / Sample_rate * B + Waveform(i,4)) +  Waveform(i,8)*sin(2 * pi * Waveform(i,6) / Sample_rate * B + Waveform(i,7));
            if (dimy == 9)
                Delay = zeros(1,round(Waveform(i,9)));
            elseif (dimy == 8)
                if (i < dimx)
                     Delay = zeros(1,round(Waveform(i+1,1)-Waveform(i,2)));
                elseif (i == dimx)
                    Delay = zeros(1,round(Total-Waveform(i,2)));
                end
            end
            A = [A, C, Delay];
        end
        
    elseif (dimy == 3) 
        for i = 1:dimx
            C = Waveform(i,3) * ones(1,round(Waveform(i,2)) - round(Waveform(i,1)));
            A = [A, C];
        end
    end
end

function MW_power(pow)
    global Devices;
    s = [':POW ', num2str(pow), 'DBM'];
    fprintf(Devices.MW,'%s\n',s);
    pause(0.1);
end

function MW_turnon
    global Devices;
    fprintf(Devices.MW,'%s\n',':OUTP ON');
    pause(0.1);
end

function MW_channel(channel)
    global Devices;
    fprintf(Devices.MW,'%s %s\n', ':OUTP', num2str(channel));
    pause(0.1);
end

function MW_turnoff
    global Devices;
    fprintf(Devices.MW,'%s\n',':OUTP OFF');
    pause(0.1);
end

function MW_frequency(freq, amount)
    global Devices;
    if (nargin == 1)
        amount = 'G';
    end
    s = [':FREQ ', num2str(freq), amount, 'Hz'];
    fprintf(Devices.MW,'%s\n',s);
end

function MIR_output(X, Y)
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
    fwrite(Divices.MIR, cmd_A, 'uint16');        
end


function Piezo_MOV(X, Y, Z)
    global Devices;
    s = ['MOV 1 ',num2str(X),' 2 ',num2str(Y),' 3 ',num2str(Z)];
    fprintf(Devices.Piezo,'%s\n', s);
end

function Piezo_MVR(X, Y, Z)
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

function Piezo_MVR_1D(direction, stepsize)
    global Devices;
    s = ['MVR ', num2str(direction) ,' ', num2str(stepsize)];
    fprintf(Devices.Piezo, '%s\n', s);
end

function count = Detector_read(round_num, time_ms)
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

function AWG_set_freq_MHz(channel, freq_MHz)
    global Devices;
    s = ['SOURCE',num2str(channel),':FREQUENCY ',num2str(freq_MHz), 'MHZ'];
    fprintf(Devices.AWG, '%s\n', s);
end

function AWG_set_amp_voltage(channel, Vpp)
    global Devices;
    s = ['SOURCE',num2str(channel),':VOLTAGE:AMPLITUDE ',num2str(freq_MHz), 'MHZ'];
    fprintf(Devices.AWG, '%s\n', s);
end

function AWG_waveform_delete_all
    global Devices;
    fprintf(Devices.AWG, '%s\n', 'WLIST:WAVEFORM:DELETE ALL');
end

function AWG_string(str)
    global Devices;
    fprintf(Devices.AWG, '%s\n', str);
end

function AWG_run
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