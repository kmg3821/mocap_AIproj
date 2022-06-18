close all; clear; clc;
pause(0.5); instrreset;
dlen = 11*4;

s = serialport('COM6',115200,"Timeout",5);
figure(1);
an_x = animatedline(); an_ax.Marker = '.'; an_ax.Color = 'r';
an_y = animatedline(); an_ay.Marker = '.'; an_ay.Color = 'g';
an_z = animatedline(); an_az.Marker = '.'; an_az.Color = 'b';

flush(s);
while read(s,1,"uint8") ~= 85 || read(s,1,"uint8") ~= 80; end
read(s,dlen-2,"uint8");

% ss = serialport('COM6',115200,"Timeout",5);
% figure(2); an2 = animatedline();
% an2.Marker = '.';
% 
% flush(ss);
% while read(ss,1,"uint8") ~= 85 || read(ss,1,"uint8") ~= 80; end
% read(ss,dlen-2,"uint8");

N = 3000;
accel_logger = zeros(N,3);
angvel_logger = zeros(N,3);
mag_logger = zeros(N,3);
i_plot = 0;
while(1)
    data = read(s,dlen,"uint8");
    data = reshape(data,11,4)';

    % time
    tmp = data(1,:);
    tms = bitor(bitshift(tmp(10),8),tmp(9));
    ts = tmp(8); tm = tmp(7);
    t = tms*1e-3 + ts + tm*60;
    
    % accel, angvel, mag
    tmp = cast(data(2:4,:),'int16');
    tmp = double(bitor(bitshift(tmp(:,4:2:8),8),tmp(:,3:2:7)));
    aa = tmp(1,:) / 32768*16;
    ww = tmp(2,:) / 32768*2000;
    mm = tmp(3,:);

    if i_plot == 0
        figure(1);
        addpoints(an_x, t, ww(1)); xlim([t - 10, t]);
        addpoints(an_y, t, ww(2)); xlim([t - 10, t]);
        addpoints(an_z, t, ww(3)); xlim([t - 10, t]);
    end
    i_plot = mod(i_plot + 1,10);

%     if i <= size(accel_logger,1)
%         accel_logger(i,:) = aa;
%         angvel_logger(i,:) = ww;
%         mag_logger(i,:) = mm;
%         i = i + 1
%     end

%     data2 = read(ss,dlen,"uint8");
%     data2 = reshape(data2,11,4)';

%     % time
%     tmp = data2(1,:);
%     tms2 = bitor(bitshift(tmp(10),8),tmp(9));
%     ts = tmp(8); tm = tmp(7);
%     t2 = tms2*1e-3 + ts + tm*60;
%     
%     % accel, angvel, mag
%     tmp = cast(data2(2:4,:),'int16');
%     tmp = double(bitor(bitshift(tmp(:,4:2:8),8),tmp(:,3:2:7)));
%     aa2 = tmp(1,:) / 32768*16;
%     ww2 = tmp(2,:) / 32768*2000;
%     mm2 = tmp(3,:);

%     if ~mod(tms2,140)
%         figure(2); addpoints(an2,t2, aa2(1)); xlim([t2 - 10, t2]);
%     end
end














