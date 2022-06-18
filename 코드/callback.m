function callback(src,~)
    
    sel = src.UserData.sel;
    dlen = src.UserData.dlen;
    dt = src.UserData.dt;
    align = src.UserData.align;

    data = read(src,dlen,"uint8"); % 데이터 읽기
    data = reshape(data,11,sel)';

    if any(data(:,1) ~= 85) % 오류 처리 (미흡)
        while read(src,1,"uint8") ~= 85 || read(src,1,"uint8") ~= 81; end
        read(src,dlen-2,"uint8");
%         error('missing data');
    end
    
    % accel, angvel, mag
    tmp = cast(data(1:sel,:),'int16'); % 데이터형 변환
    tmp = double(bitor(bitshift(tmp(:,4:2:8),8),tmp(:,3:2:7)));
    aa = tmp(1,:) / 32768*16 *9.81;
    ww = tmp(2,:) / 32768*2000 *pi/180;
    mm = tmp(3,:);

    [~,angvel] = src.UserData.fuse(aa,ww,mm); % 각속도 추정
    src.UserData.quat = normalize(... % 쿼터니언 업데이트
      src.UserData.quat*quaternion(rotatepoint(align,angvel*dt),'rotvec'));

end




