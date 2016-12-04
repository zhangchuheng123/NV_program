function calibration

    % author:   Zhang Chuheng 
    %   email:    zhangchuheng123 (AT) gmail.com
    %   home:     zhangchuheng123.github.io
    %   github:   zhangchuheng123
    % Date:     
    %   Establish:          Oct. 24, 2016
    %   Modify:             Nov. 13, 2016       Add decay

    % Description:
    %   This is for Calibration of NV center 

    global isInitialize

	stepsize = 0.5;
    half_decay_iter_number = 10;
	cali_mode = '6 points';

    % check for initialzation
    if ( (~exist('isInitialize','var')) || (isempty(isInitialize)) || (isInitialize ~= 1) )
        initialization_for_scan;
    end
    
    iter_number = 0;

    while 1
%         current_stepsize = stepsize .* exp(-(iter_number / half_decay_iter_number)) .* rand();
        current_stepsize = stepsize .* rand();
        iter_number = iter_number + 1;
        data = zeros(3,3,3);
        % original point
        data(2,2,2) = read_detector();
        % display current count
        disp(sprintf('Calibration center counts = %.2f k', data(2,2,2)));
        % get the other six points
        for direction = 1:3
            MVR(direction, current_stepsize);
            data(2 + (direction == 1),2 + (direction == 2),2 + (direction == 3)) = read_detector();
            MVR(direction, - 2*current_stepsize);
            data(2 - (direction == 1),2 - (direction == 2),2 - (direction == 3)) = read_detector();
            MVR(direction, current_stepsize);
        end
        % find which point gets the maximum counts, and move to that point
        index = find(data == max(data(:)), 1, 'first');
        [ind1, ind2, ind3] = ind2sub([3,3,3], index);
        ind = [ind1, ind2, ind3];
        direction = find(ind ~= 2, 1, 'first'); 
        if (~ isempty(direction))
            pm_sign = ind(direction) - 2;
            MVR(direction, pm_sign .* current_stepsize);
        end
    end
end

function detector_val = read_detector
	global Detector;
    % counts in 100ms
	fprintf(Detector,'%d', [4]);
	data = fread(Detector, 6);
	fprintf(Detector,'%d', [0]);
	detector_val  = data(4)*65536 + data(5)*256 + data(6);
    % convert to kilo counts per second
    detector_val = detector_val / 100;
end

function MVR(direction, stepsize)
	global Piezo;
	s = ['MVR ', num2str(direction) ,' ', num2str(stepsize)];
	fprintf(Piezo, '%s\n', s);
	pause(0.1);
end

