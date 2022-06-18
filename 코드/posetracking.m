close all; clear; clc;
pause(0.5); instrreset;

sel = 3; % 수신할 데이터 선택 개수
dlen = 11*sel; % 데이터 길이 (byte 단위)
dt = 0.005; % 샘플링 속도 200 Hz

figure; view(3); axis equal; grid; hold on; % plot 애니메이션
xlim([-2,2]); ylim([-2,2]); zlim([-2,2]);
pole1 = line('LineWidth', 5);
pole2 = line('LineWidth', 5);
alignflag = uicontrol('Style','radiobutton','String','align',...
                      'Position',[50,50,50,50]);
recordflag = uicontrol('Style','radiobutton','String','record',...
                       'Position',[50,10,50,50]);

fuse1 = ahrsfilter("AccelerometerNoise",(0.01*9.81)^2,...
                   "MagnetometerNoise",(0.15)^2,...
                   "GyroscopeNoise", deg2rad(0.05)^2,...
                   "LinearAccelerationNoise",(6*9.81)^2,...
                   "LinearAccelerationDecayFactor",0.35);
fuse2 = ahrsfilter("AccelerometerNoise",(0.01*9.81)^2,...
                   "MagnetometerNoise",(0.15)^2,...
                   "GyroscopeNoise", deg2rad(0.05)^2,...
                   "LinearAccelerationNoise",(6*9.81)^2,...
                   "LinearAccelerationDecayFactor",0.35);

load('model3.mat');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s1 = serialport('COM4',115200,"Timeout",5); 
s1.UserData = struct('quat', quaternion(rotm2quat(eye(3))),...
                     'align', quaternion(1,0,0,0),...
                     'fuse', fuse1,...
                     'sel', sel,...
                     'dlen', dlen,...
                     'dt', dt);
flush(s1);
while read(s1,1,"uint8") ~= 85 || read(s1,1,"uint8") ~= 81; end
read(s1,dlen-2,"uint8");
configureCallback(s1,"byte",dlen,@callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s2 = serialport('COM6',115200,"Timeout",5); 
s2.UserData = struct('quat', quaternion(rotm2quat(eye(3))),...
                     'align', quaternion(1,0,0,0),...
                     'fuse', fuse2,...
                     'sel', sel,...
                     'dlen', dlen,...
                     'dt', dt);
flush(s2);
while read(s2,1,"uint8") ~= 85 || read(s2,1,"uint8") ~= 81; end
read(s2,dlen-2,"uint8");
configureCallback(s2,"byte",dlen,@callback);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

flag = true;
reclen = 500; ptr = 1;
record = table;
record1 = quaternion(zeros(reclen,4));
record2 = quaternion(zeros(reclen,4));

while true

    myq1 = s1.UserData.quat; % 팔 상박에 붙어있는 imu 쿼터니언 (global)
    myq2 = s2.UserData.quat; % 팔 하박에 붙어있는 imu 쿼터니언 (global)

    v1 = -rotatepoint(myq1,[0 0 1]); % 팔 상박 벡터 (global)
    v2 = -rotatepoint(myq2,[0 0 1]); % 팔 하박 벡터 (global)

    set(pole1,'XData',[0 v1(1)],'Ydata',[0 v1(2)],'Zdata',[0 v1(3)]);
    set(pole2,'XData',[v1(1) v1(1)+v2(1)],...
              'Ydata',[v1(2) v1(2)+v2(2)],...
              'Zdata',[v1(3) v1(3)+v2(3)]);
    drawnow limitrate;

    record.record = [myq1.compact myq2.compact];
    poselabel = trainedModel.predictFcn(record); poselabel = poselabel{1};

    switch poselabel
        case 'nuet'
            title('차렷','FontSize',30);
        case 'side'
            title('옆','FontSize',30);
        case 'up'
            title('위','FontSize',30);
        case 'fronbent'
            title('옆굽','FontSize',30);
        case 'upbent'
            title('위굽','FontSize',30);
    end

    if flag && alignflag.Value % 차렷 자세 초기화
        s1.UserData.align = myq1;
        s2.UserData.align = myq2;
        s1.UserData.quat = quaternion(1,0,0,0);
        s2.UserData.quat = quaternion(1,0,0,0);
        flag = false;
    end

%     if recordflag.Value % 데이터 저장
%         record1(ptr,:) = myq1;
%         record2(ptr,:) = myq2; 
%         if ptr == reclen
%             ptr = 1;
%             recordflag.Value = false;
%             filename = "data-" + datestr(now,'HH-MM-SS');
%             save(filename,'record1','record2');
%         else
%             ptr = ptr + 1;
%         end
%     end
    
    pause(0.03); % plot 주기 조절 (너무 작으면 안됨)
end


























