%% SCRIPT_Derive_RollPitchYaw
%syms Roll Pitch Yaw
Roll = -pi/2;
Pitch = -pi/3;
Yaw = -pi;

H = Rz(Yaw)*Ry(Pitch)*Rx(Roll);
R = H(1:3,1:3);

%% Recover angles
% Assume Pitch \in [-pi/2,pi/2] -> cos(Pitch) \in [0,1]
