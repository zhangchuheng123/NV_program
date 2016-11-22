%% move it to a position
identifier = 'Scan_natural-3_';
scan(10, 10, 20, 1, 0, identifier);

%% scanz example
X = 10;
Y = 10;
Z = 15:0.5:30;
CountNum = 40;
scan(X, Y, Z, CountNum, 0, identifier);

%% sample big marker
Z0 = 24.5;
X = 1:0.5:20;
Y = 1:0.5:20;
Z = 0;
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% sample area
cross_x = 6.0;
cross_y = 10.5;

X = 20:0.5:90;
Y = 20:0.5:90;
Z = [6, 7, 8];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Center scan for NV
X0 = 54;
Y0 = 36;
Delta = 3;
X = X0-Delta:0.1:X0+Delta;
Y = Y0-Delta:0.1:Y0+Delta;
Z = 6;
Z = Z + Z0;
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% scanz over NV
NV_x = 54.0;
NV_y = 35.7;
Z = 20:0.1:35;
CountNum = 40;
scan(NV_x, NV_y, Z, CountNum, 0, identifier);

%% Coarse scan for small markers
X = 25:0.5:65;
Y = 25:0.5:65;
Z = [0];
Z = Z + Z0; 
CountNum = 1;
scan(X, Y, Z, CountNum, Z0, identifier);

%% Scan for small marker
first_x = cross_x + 18.5;
first_y = cross_y + 23.5;

if ((NV_x < first_x + 30) && (NV_y < first_y + 30))
    X0 = first_x;
    Y0 = first_y;
elseif ((NV_x < first_x + 60) && (NV_y < first_y + 30))
    X0 = first_x+30;
    Y0 = first_y;
elseif ((NV_x < first_x + 30) && (NV_y < first_y + 60))
    X0 = first_x;
    Y0 = first_y+30;
else
    X0 = first_x+30;
    Y0 = first_y+30;
end
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