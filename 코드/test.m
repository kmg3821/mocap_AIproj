close all; clear; clc;


figure;
alignflag = uicontrol('Style','radiobutton','String','align',...
                      'Position',[50,50,50,50]);
alignflag2 = uicontrol('Style','radiobutton','String','align',...
                      'Position',[50,10,50,50]);

U = [1 0 0 0];

while true

    disp(alignflag.Value);
    disp(alignflag2.Value);

    alignflag2.Value = false;
    
    pause(0.5);
end











