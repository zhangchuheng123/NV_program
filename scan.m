% author:   Zhang Chuheng 
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

% Description:
%   This is a all-in-one package for scanning fluorescent shining in diamond.
%   Initialization of hardware devices - piezo and detector - is included.

function scan

    global Piezo Detector isInitialize;

    % check for initialzation
    if ( (~exist('isInitialize','var')) || (isempty(isInitialize)) || (isInitialize ~= 1) )
        initialization_for_scan;
    end

    % for debug
    % dbstop if error;

    %% >>>>>>>>>>>>>>>>>>>>>>>>> Parameter Area >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    % These are the parameters to modify, OTHER CODES ARE NOT SUGGESTED TO MODIFY.

    % scope of the scan, it can be 1-D, 2-D or 3-D
    % scanz example
%     X = 50;
%     Y = 50;
%     Z = 1:0.5:40;
%     CountNum = 20;

    % sample scan example
    Z0 = 11;
    X = 40:0.5:80;
    Y = 40:0.5:80;
    Z = [5, 7, 9, 30];
    Z = Z + Z0;
    CountNum = 1;

%     X = 42-4:0.2:42+4;
%     Y = 64-4:0.2:64+4;
%     Z = 42;

    % how to calculate pause time : piezo velocity 1000um/s, fixed time for movement: 50~100ms
    scan_pause_time = 0.06;
    scan_pause_time_long = 0.2;

    % automatically save data and figure : Yes -> 1 | No -> 0
    isSave = 1;
    % use identifier as the begining of saved figure name
    identifier = 'Scan_sample5_side1';

    % >>>>>>>>>>>>>>>>>>>>>>> End of Parameter Area >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

    %% Program begins

    inert_detector = Detector;
    % initialization of detector and piezo
    % move piezo to initial point, notice that this is a REDUNDANCY operation! 
    s = ['MOV 1 ',num2str(X(1)),' 2 ',num2str(Y(1)),' 3 ',num2str(Z(1))];
    fprintf(Piezo,'%s\n', s);
    % pause 2 secs for stablization
    pause(2);
    % 2:10ms 4:100ms
    fprintf(Detector,'%d', [2]);
    fread(Detector, 6);
    fprintf(Detector,'%d', [0]);

    data = zeros(numel(X), numel(Y), numel(Z));
    total_count = numel(X) .* numel(Y) .* numel(Z);
    count = 0;

    hwait=waitbar(0, 'Please wait...', 'Name', 'Scanning...');
    c = onCleanup(@()close(hwait));
    tic;

    s = ['MOV 1 ',num2str(X(1)),' 2 ',num2str(Y(1)),' 3 ',num2str(Z(1))];
    fprintf(Piezo, '%s\n', s);
    % pause 1 secs for stablization
    pause(1);

    for ind3 = 1:numel(Z)
        for ind2 = 1:numel(Y)

            s = ['MOV 1 ',num2str(X(1)),' 2 ',num2str(Y(ind2)),' 3 ',num2str(Z(ind3))];
            fprintf(Piezo, '%s\n', s);
            pause(scan_pause_time_long);

            for ind1 = 1:numel(X)
                % move piezo to new position
                if (ind1 ~= 1)
                    step_x = X(2) - X(1);
                    s = ['MVR 1 ',num2str(step_x)];
                    fprintf(Piezo, '%s\n', s);
                    % pause time is for piezo to response, generally, piezo 
                    % needs at least 50ms to respone on each move, and the 
                    % transposition velocity is about 10000um/s
                    pause(scan_pause_time);
                end 

                ancilla = 0;
                for k = 1:CountNum
                    fprintf(Detector,'%d', [2]);
                    data_reader = fread(inert_detector, 6);
                    fprintf(Detector,'%d', [0]);
                    % notice the format of data
                    ancilla = ancilla + data_reader(4)*65536 + data_reader(5)*256 + data_reader(6);
                end
                % now it's counts/10ms, transfer to kilo_counts/s
                ancilla = ancilla / CountNum / 10;
                
                % for debugging
                % disp(ancilla);

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
    close(hwait);
    
    %% Draw the figure 

    XYZ = {X, Y, Z};
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

    % put the piezo back
    s = ['MOV 1 ',num2str(X(1)),' 2 ',num2str(Y(1)),' 3 ',num2str(Z(1))];
    fprintf(Piezo,'%s\n', s);

    %% auto save for data and figure
    if (isSave == 1)
        str_date = datestr(now,'yyyymmdd');
        
        % maximize the window of the figure
        set(fig_hdl,'outerposition',get(0,'screensize'));
        fig_hdl.PaperPositionMode = 'auto';
        
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
end 