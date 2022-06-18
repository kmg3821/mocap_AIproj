close all; clear; clc;
pause(0.5); instrreset;
sel = 4;
dlen = 11*sel;
dt = 0.005;

%%%%%%%%%%%%%%%%%%%%%
fuse = ahrsfilter("AccelerometerNoise",(0.01*9.81)^2,...
                  "MagnetometerNoise",(0.15)^2,...
                  "GyroscopeNoise", deg2rad(0.05)^2,...
                  "LinearAccelerationNoise",(4*9.81)^2,...
                  "LinearAccelerationDecayFactor",0.2);
% fuse = ahrsfilter("LinearAccelerationNoise",(6*9.81)^2,...
%                   "LinearAccelerationDecayFactor",0.2);
%%%%%%%%%%%%%%%%%%%%%
% fuse = imufilter("AccelerometerNoise",(0.01*9.81)^2,...
%                   "GyroscopeNoise", deg2rad(0.05)^2,...
%                   "LinearAccelerationNoise",(2*9.81)^2,...
%                   "LinearAccelerationDecayFactor",0.2);
% fuse = imufilter("LinearAccelerationNoise",(6*9.81)^2,...
%                  "LinearAccelerationDecayFactor",0.2);
%%%%%%%%%%%%%%%%%%%%%
patch = poseplot();

s = serialport('COM4',115200,"Timeout",5);
flush(s);
while read(s,1,"uint8") ~= 85 || read(s,1,"uint8") ~= 80; end
read(s,dlen-2,"uint8");

plot_i = 0;
myq = quaternion(rotm2quat([-1 0 0; 0 1 0; 0 0 -1]'));
while(1)
    data = read(s,dlen,"uint8");
    data = reshape(data,11,sel)';

    % time
    tmp = data(1,:);
    tms = bitor(bitshift(tmp(10),8),tmp(9));
    ts = tmp(8); tm = tmp(7);
    t = tms*1e-3 + ts + tm*60;
    
    % accel, angvel
    tmp = cast(data(2:sel,:),'int16');
    tmp = double(bitor(bitshift(tmp(:,4:2:8),8),tmp(:,3:2:7)));
    aa = tmp(1,:) / 32768*16 *9.81;
    ww = tmp(2,:) / 32768*2000 *pi/180;
    mm = tmp(3,:);

    [~,angvel] = fuse(aa,ww,mm);
    myq = myq*quaternion(angvel*dt,'rotvec');
    
    if plot_i == 0
%         set(patch,Orientation=quat); 
        set(patch,Orientation=myq); 
        drawnow limitrate
    end
    plot_i = mod(plot_i+1,12);
end









