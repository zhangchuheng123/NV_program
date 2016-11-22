%% parameter area
% the position of four markers
% sequence: (0,0) (0,30) (30,0) (30,30)
F(:,1)=[0;0];
F(:,2)=[30;0];
F(:,3)=[0;30];
F(:,4)=[30.1;30.0];
% NV position
NVposition=[20;10];

%% Program area
fprintf('Four markers: (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) \n', ...
    F(1,1), F(2,1), F(1,2), F(2,2), F(1,3), F(2,3), F(1,4), F(2,4));
% standard marker relative position
S=[0 30 0 30; 0 0 30 30];
%error from XY axis coordinate
Fa=F(:,2)-F(:,1);
Fb=F(:,3)-F(:,1);
Sa=S(:,2)-S(:,1);
Sb=S(:,3)-S(:,1);

Fab=[Fa Fb];
Fx=F(:,4)-F(:,1);
AB=Fab\Fx;
Sd=AB(1)*Sa+AB(2)*Sb;
deltaxy=Sd-S(:,4);
fprintf('deltaxy = (%.4f, %.4f) \n', deltaxy(1), deltaxy(2));

tm=Fab\(NVposition-F(:,1));
NVture=tm(1)*Sa+tm(2)*Sb;
fprintf('NVture = (%.4f, %.4f) \n', NVture(1), NVture(2));
