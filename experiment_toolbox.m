function tools = experiment_toolbox
	tools.NVCoordinate = @NVCoordinate;
	tools.Initializer = @Initializer;
	tools.scan = @scan;
end

function NVCoordinate(F, NVposition)
	% the position of four markers
	% in matlab view            in UV
	%  F1+----------+F2         F4+----------+F2
	%    |          |             |          |
	%    |          |             |          |
	%    |          |   --->      |          |
	%    |          |             |          |
	%  F3+----------+F4         F3+----------+F1
	%
	% in UV order
	%  F3+----------+F4
	%    |          |
	%    |          |     ^ y
	%    |          |     |
	%    |          |     |
	%  F1+----------+F2   :---> x

	% Program area
	% standard marker relative position
	S=[0 30 0 30; 0 0 30 30];

	F = [F(:,3), F(:,1), F(:,4), F(:,2)];
	S = [S(:,3), S(:,1), S(:,4), S(:,2)];

	fprintf('\nFour markers (XY in UV order): (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) \n', ...
	    F(1,1), F(2,1), F(1,2), F(2,2), F(1,3), F(2,3), F(1,4), F(2,4));
	Fa=F(:,2)-F(:,1);
	Fb=F(:,3)-F(:,1);
	Sa=S(:,2)-S(:,1);
	Sb=S(:,3)-S(:,1);

	Fab=[Fa Fb];
	Fx=F(:,4)-F(:,1);
	AB=Fab\Fx;
	Sd=AB(1)*Sa+AB(2)*Sb;
	deltaxy=Sd-(S(:,4)-S(:,1));
	fprintf('deltaxy (XY) = (%.3f, %.3f) \n', deltaxy(1), deltaxy(2));

	tm=Fab\(NVposition-F(:,1));
	NVture=tm(1)*Sa+tm(2)*Sb;
	fprintf('NVture (in UV direction) = (%.3f, %.3f) \n', -NVture(2), NVture(1));
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
        fprintf('Piezo: Initialization finished');
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
        fprintf('Detector: Initialization finished');
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
	Piezo = Devices.Piezo;
	Detector = Devices.Detector;

    scan_pause_time = parameters.scan.scan_pause_time;
    scan_pause_time_long = parameters.scan.scan_pause_time_long;
    isSave = parameters.figure.is_save;
    identifier = parameters.figure.identifier;

    Piezo_MOV(X(1), Y(1), Z(1)), pause(1);
    Detector_read();

    data = zeros(numel(X), numel(Y), numel(Z));
    total_count = numel(X) .* numel(Y) .* numel(Z);
    count = 0;
    
    if (total_count == 1)
    	Piezo_MOV(X(1), Y(1), Z(1));
        sprintf('Move piezo to position ... done');
        return;
    end

    hwait=waitbar(0, 'Please wait...', 'Name', 'Scanning...');
    c = onCleanup(@()close(hwait));
    
    tic;
    
    for ind3 = 1:numel(Z)
        for ind2 = 1:numel(Y)

        	Piezo_MOV(X(1), Y(ind2), Z(ind3)), pause(scan_pause_time_long);

            for ind1 = 1:numel(X)
                % move piezo to new position
                if (ind1 ~= 1)
                    step_x = X(2) - X(1);
                    Piezo_MVR(step_x, 0, 0),  pause(scan_pause_time);
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

function Piezo_MOV(X, Y, Z)
	global Devices;
	s = ['MOV 1 ',num2str(X),' 2 ',num2str(Y),' 3 ',num2str(Z)];
	fprintf(Devices.Piezo,'%s\n', s);
end

function Piezo_MVR(X, Y, Z)
	global Devices;
	s = 'MVR ';
	if (X ~= 0)
		s = s + ['1 ',str2num(X)];
	end
	if (Y ~= 0)
		s = s + ['2 ',str2num(Y)];
	end
	if (Z ~= 0)
		s = s + ['3 ',str2num(Z)];
	end
	fprintf(Devices.Piezo,'%s\n', s);
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