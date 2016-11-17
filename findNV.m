%% move it to a position
identifier = 'Scan_natural-4_'
scan(10, 10, 20, 1, 0, identifier);

%% scanz example
X = 10;
Y = 10;
Z = 20:0.5:40;
CountNum = 20;
scan(X, Y, Z, CountNum, 0, identifier);

%% sample big marker
Z0 = 20;
X = 1:0.5:20;
Y = 1:0.5:20;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% sample area
X = 30:0.5:60;
Y = 30:0.5:60;
Z = [6, 8];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Center scan for NV
X0 = 60;
Y0 = 74.5;
Delta = 5;
X = X0-Delta:0.2:X0+Delta;
Y = Y0-Delta:0.2:Y0+Delta;
Z = [8];
Z = Z + Z0;
CountNum = 1;

%% Coarse scan for small marker
X = 20:0.5:90;
Y = 20:0.5:90;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Scan for small marker
X0 = 50;
Y0 = 50;
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