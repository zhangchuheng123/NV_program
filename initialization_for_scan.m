function initialization_for_scan

    % This is the initialization of Piezo and Detector

    global Piezo Detector isInitialize;

    fprintf('Initialing...');

    % delete all the serial port from memory in case some port is occupied by other applications
    delete(instrfindall);

    % Piezo is connected by ip addressing 
    % ip = 192.168.54.3 / 192.168.13.2
    % port = 50000
    Piezo =  tcpip('192.168.54.3', 50000);

    % Detector is connected by serial port 
    % you can find the port number in device management on your computer 
    Detector = serial('com3');
    Detector.Terminator = 'CR';
    Detector.BaudRate = 2000000;
    % Detector.InputBufferSize = 32768;
    % Detector.OutputBufferSize = 32768;

    % open for connection 
    fopen(Detector);
    fopen(Piezo);

    % initialization for Detector 
    fprintf(Detector, '%d', [0]);
    fprintf(Detector, '%d', [1]);
    fread(Detector,6);
    fprintf(Detector, '%d', [0]);

    % initialization for piezo
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

    % flag varialble 
    isInitialize = 1;

    fprintf('finished \n');
end