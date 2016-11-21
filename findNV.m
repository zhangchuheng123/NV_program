%% move it to a position
identifier = 'Scan_natural-4_';
scan(10, 10, 20, 1, 0, identifier);

%% scanz example
X = 10;
Y = 10;
Z = 15:0.5:30;
CountNum = 40;
scan(X, Y, Z, CountNum, 0, identifier);

%% sample big marker
Z0 = 26.5;
X = 1:0.5:20;
Y = 1:0.5:20;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% sample area
X = 20:0.5:90;
Y = 20:0.5:90;
Z = [6, 7, 8];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Center scan for NV
X0 = 84.5;
Y0 = 52.5;
Delta = 3;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = 6;
Z = Z + Z0;
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% scanz over NV
X0 = 80.7;
Y0 = 57.3;
Z = 20:0.1:35;
CountNum = 40;
scan(X0, Y0, Z, CountNum, 0, identifier);

%% Coarse scan for small markers
X = 25:0.5:65;
Y = 25:0.5:65;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Scan for small marker
X0 = 29.5;
Y0 = 60.0;
Delta = 3;

X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);
scan(X+30, Y, Z, CountNum, Z0, identifier);
scan(X, Y+30, Z, CountNum, Z0, identifier);
scan(X+30, Y+30, Z, CountNum, Z0, identifier);