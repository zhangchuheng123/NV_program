function tools = experiment_toolbox
    addpath('hardware');
    % Methods of toolbox
	tools.scan = @scan;
    tools.scan_mirror = @scan_mirror;
    tools.ESR = @ESR;
    tools.calibration = @calibration;
    tools.large_scan = @large_scan;
end

function large_scan(X, Y, XX, YY, Z_rel, CountNum, Z0)
    %   author:   Zhang Chuheng 
    %   email:    zhangchuheng123 (AT) gmail.com
    %   home:     zhangchuheng123.github.io
    %   github:   zhangchuheng123
    %
    %   scan using APT motor and mirror
    %   X, Y        mirror voltage
    %   XX, YY      APT scale
    %
    % Date:     
    %   Establish:          Feb. 12, 2017

    global parameters;

    if (nargin == 5)
        CountNum = 1;
        Z0 = 0;
    end
    if (nargin == 6)
        Z0 = 0;
    end

    % Check for initialization
    apt = APT();
    if apt.is_init() == false
        apt.init()
    end
    apt_origin_position = apt.POS();
    
    detector = Detector();
    if detector.is_init() == false
        detector.init();
    end

    piezo = Piezo();
    if piezo.is_init() == false
        piezo.init();
    end

    mirror = Mirror();
    if mirror.is_init() == false
        mirror.init()
    end

    data = zeros(numel(XX), numel(YY), numel(X), numel(Y), numel(Z_rel));
    total_count = numel(XX) * numel(YY);
    count = 0;

    if (total_count == 1)
        mirror.output(X, Y);
        fprintf('Move Mirror to position ... done\n');
        fprintf('Current APT position is (%.3f, %.3f)', apt_origin_position(1), apt_origin_position(2));
    end

    hwait=waitbar(0, 'Please wait...', 'Name', 'Large Scanning...');
    c = onCleanup(@()close(hwait));

    tic;
    
    for indx = 1:numel(XX)
        for indy = 1:numel(YY)
            apt.MOV(apt_origin_position(1) + XX(indx), apt_origin_position(2) + YY(indy));
            for ind3 = 1:numel(Z_rel)
                piezo.MVR(0, 0, Z_rel(ind3)), pause(scan_pause_time_long);
                for ind2 = 1:numel(Y)

                    if (mod(ind2, 2) == 1)
                        ind1_list = 1:numel(X);
                    else
                        ind1_list = numel(X):-1:1;
                    end

                    for ind1 = ind1_list
                        mirror.output(X(ind1), Y(ind2));

                        % read data
                        ancilla = detector.read(CountNum);
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
            str = ['-LargeScan', num2str(XX(indx)), '-', num2str(YY(indy))];
            set(fig_hdl, 'Name', str);
            if (parameters.figure.is_save == 1)
                auto_save(fig_hdl, X, Y, Z_rel+Z0, data, parameters.figure.identifier, str);
            end
        end
    end
end

function scan_mirror(X, Y, Z_rel, CountNum, Z0)
    %   author:   Zhang Chuheng 
    %   email:    zhangchuheng123 (AT) gmail.com
    %   home:     zhangchuheng123.github.io
    %   github:   zhangchuheng123
    % Date:     
    %   Establish:          Jan. 18, 2017
    %   Modify:             Feb. 11, 2017

    global parameters;

    if (nargin == 4)
        Z0 = 0;
    end

    % Check for initialization
    detector = Detector();
    if detector.is_init() == false
        detector.init();
    end

    piezo = Piezo();
    if piezo.is_init() == false
        piezo.init();
    end

    mirror = Mirror();
    if mirror.is_init() == false
        mirror.init()
    end

    scan_pause_time_long = parameters.scan.scan_pause_time_long;

    mirror.output(X(1), Y(1)), pause(0.2);
    detector.read();
    if (CountNum == 0)
        return;
    end

    data = zeros(numel(X), numel(Y), numel(Z_rel));
    total_count = numel(X) * numel(Y) * numel(Z_rel);
    count = 0;
    
    if (total_count == 1)
        fprintf('Move Mirror to position ... done');
        return;
    end

    hwait=waitbar(0, 'Please wait...', 'Name', 'Mirror Scanning...');
    c = onCleanup(@()close(hwait));

    tic;
    
    for ind3 = 1:numel(Z_rel)
        piezo.MOV(0, 0, Z0+Z_rel(ind3)), pause(scan_pause_time_long);
        for ind2 = 1:numel(Y)

            if (mod(ind2, 2) == 1)
                ind1_list = 1:numel(X);
            else
                ind1_list = numel(X):-1:1;
            end

            for ind1 = ind1_list
                mirror.output(X(ind1), Y(ind2));

                % read data
                ancilla = detector.read(CountNum);
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
    %   Modify:             Feb. 11, 2017       use hardware package
	% Description:
	%   This is a all-in-one package for scanning fluorescent shining in diamond.
	%   Initialization of hardware devices - piezo and detector - is included.

    global parameters;

    detector = Detector();
    piezo = Piezo();

    % Check for initialization
	if detector.is_init() == false
        detector.init();       
    end
    if piezo.is_init() == false
        piezo.init();       
    end

    scan_pause_time = parameters.scan.scan_pause_time;
    scan_pause_time_long = parameters.scan.scan_pause_time_long;

    piezo.MOV(X(1), Y(1), Z(1)), pause(1);
    detector.read();

    data = zeros(numel(X), numel(Y), numel(Z));
    total_count = numel(X) * numel(Y) * numel(Z);
    count = 0;
    
    if (total_count == 1)
    	piezo.MOV(X(1), Y(1), Z(1));
        fprintf('Move piezo to position ... done\n');
        return;
    end

    hwait=waitbar(0, 'Please wait...', 'Name', 'Scanning...');
    c = onCleanup(@()close(hwait));
    
    tic;
    
    for ind3 = 1:numel(Z)
        for ind2 = 1:numel(Y)

        	piezo.MOV(X(1), Y(ind2), Z(ind3));
            pause(scan_pause_time_long);

            for ind1 = 1:numel(X)
                % move piezo to new position
                if (ind1 ~= 1)
                    step_x = X(2) - X(1);
                    piezo.MVR(step_x, 0, 0);
                    pause(scan_pause_time);
                end 
                % read data
                ancilla = detector.read(CountNum);
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
    piezo = Piezo();
    if piezo.is_init() == false
        piezo.init()
    end

    detector = Detector();
    if detector.is_init() == false
        detector.init()
    end

    mw = MW();
    if mw.is_init() == false
        mw.init()
    end

    mw.power(pow);
    mw.turnon;
    ESR_data = zeros(1,numel(freq));
    
    hwait=waitbar(0, 'Please wait...', 'Name', 'ESR...');
    c = onCleanup(@()close(hwait));
    total_count = loop(1) * numel(freq);
    count = 0;
    tic;
    
    for n = 1:loop(1)
        for k = 1:numel(freq)
            mw.frequency(freq(k)), pause(0.03);
            ESR_data(k) = ESR_data(k) + detector.read(loop(2), 100);
            
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
    mw.turnoff;
end

function fig_hdl = ESR_plot(freq, pow, data)
    fig_hdl = figure;
    plot(freq, data);
    xlabel('frequency(GHz)');
    ylabel('fluorescent(kilo count/s)');
    title(sprintf('ESR Scan power = %.1f dBm', pow));
end

function calibration(count, position)
    global parameters;

    piezo = Piezo();
    if piezo.is_init() == false
        piezo.init()
    end

    detector = Detector();
    if detector.is_init == false
        detector.init()
    end

    if (nargin == 2)
       piezo.MOV(position(1), position(2), position(3));
    end
    
    stepsize = parameters.calibration.step_size;
    half_decay_iter_number = parameters.calibration.half_decay_iter_number;
    
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

    piezo = Piezo();
    if piezo.is_init() == false
        piezo.init()
    end

    detector = Detector();
    if detector.is_init() == false
        detector.init()
    end
    
    pause_time = parameters.calibration.pause_time;
    data = zeros(3,3,3);
    % original point
    data(2,2,2) = Detector_read(1, 100);
    % display current count
    fprintf('Calibration center counts = %.2f k\n', data(2,2,2));
    % get the other six points
    for direction = 1:3
        piezo.MVR_1D(direction, current_stepsize), pause(pause_time);
        data(2 + (direction == 1),2 + (direction == 2),2 + (direction == 3)) = detector.read(1, 100);
        piezo.MVR_1D(direction, - 2*current_stepsize), pause(pause_time);
        data(2 - (direction == 1),2 - (direction == 2),2 - (direction == 3)) = detector.read(1, 100);
        piezo.MVR_1D(direction, current_stepsize), pause(pause_time);
    end
    % find which point gets the maximum counts, and move to that point
    index = find(data == max(data(:)), 1, 'first');
    [ind1, ind2, ind3] = ind2sub([3,3,3], index);
    ind = [ind1, ind2, ind3];
    direction = find(ind ~= 2, 1, 'first'); 
    if (~ isempty(direction))
        pm_sign = ind(direction) - 2;
        piezo.MVR_1D(direction, pm_sign .* current_stepsize), pause(pause_time);
    end
end

%%%%%%%%%%%%%%%%  UNFINISHED %%%%%%%%%%%%%%

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