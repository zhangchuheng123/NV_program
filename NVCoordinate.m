%% parameter area
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

% sequence: (0,0) (0,30) (30,0) (30,30)
F(:,1)=[58.2 31.5]';
F(:,2)=[87.9 31.1]';
F(:,3)=[58.5 61.4]';
F(:,4)=[88.3 60.9]';
% NV position
NVposition=[62.0, 23.7]';

%% Program area
% standard marker relative position
S=[0 30 0 30; 0 0 30 30];

% pertubation for the UV coordinate
F = [F(:,3), F(:,1), F(:,4), F(:,2)];
S = [S(:,3), S(:,1), S(:,4), S(:,2)];

% output
fprintf('\nFour markers (XY in UV order): (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) \n', ...
    F(1,1), F(2,1), F(1,2), F(2,2), F(1,3), F(2,3), F(1,4), F(2,4));
%error from XY axis coordinate
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
