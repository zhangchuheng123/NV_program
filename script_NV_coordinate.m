function script_NV_coordinate(F, NVposition)
	% standard marker relative position
	S=[
        0 30 0 30; 
        0 0 30 30
        ];
    
    % adjust F to standard order
    F_adjust = zeros(2, 4);
    F = [F; sum(F,1)];
    F_adjust(:, 1) = F(1:2, F(3,:) == min(F(3,:)));
    F(1:2, F(3,:) == min(F(3,:))) = [0; 0];
    F_adjust(:, 4) = F(1:2, F(3,:) == max(F(3,:)));
    F(1:2, F(3,:) == max(F(3,:))) = [0; 0];
    F_adjust(:, 2) = F(1:2, F(1,:) == max(F(1,:)));
    F(1:2, F(1,:) == max(F(1,:))) = [0; 0];
    F_adjust(:, 3) = F(1:2, F(2,:) == max(F(2,:)));
    
    F = F_adjust;
	fprintf('\nFour markers: (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) (%.1f, %.1f) \n', ...
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

	tm=Fab\(NVposition - F(:,1));
	NVture=tm(1)*Sa+tm(2)*Sb;
	fprintf('NVture (in UV direction) = (%.3f, %.3f) \n', NVture(1), NVture(2));
end