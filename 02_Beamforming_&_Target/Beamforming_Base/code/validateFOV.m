
function FOV = validateFOV(point_cloud)


az_all  = [];
el_all  = [];
rng_all = [];
mag_all = [];

[cnt_scan_max, file_num] = size(point_cloud.mix_cnt);

for file_idx = 1:file_num
    for scan_idx = 1:cnt_scan_max
        
        cnt = point_cloud.mix_cnt(scan_idx,file_idx);
        if cnt <= 0
            continue;
        end
        
        pc = point_cloud.mix_data{scan_idx,file_idx}; % [x;y;z;mag]
        xyz = pc(1:3,1:cnt);
        mag = pc(4,1:cnt);
        
        x = xyz(1,:);
        y = xyz(2,:);
        z = xyz(3,:);
        
        rng = sqrt(x.^2 + y.^2 + z.^2); %좌표로 거리와 각도 역산
        az  = atan2d(y,x);
        el  = atan2d(z, sqrt(x.^2 + y.^2));
        
        az_all  = [az_all  az];
        el_all  = [el_all  el];
        rng_all = [rng_all rng];
        mag_all = [mag_all mag];
    end
end

%% 
FOV.mode = 'mix';

FOV.az.min  = prctile(az_all,1);
FOV.az.max  = prctile(az_all,99);
FOV.az.core = prctile(az_all,[5 95]);

FOV.el.min  = prctile(el_all,1);
FOV.el.max  = prctile(el_all,99);
FOV.el.core = prctile(el_all,[5 95]);

FOV.az.all  = az_all;
FOV.el.all  = el_all;
FOV.rng.all = rng_all;
FOV.mag.all = mag_all;

%% 시각화
figure;
scatter(FOV.az.all, FOV.rng.all, 6, FOV.mag.all,'filled'); %거리-azi 별 점
grid on; colorbar;
xlabel('Azimuth [deg]');
ylabel('Range [m]');
title('MIX Azimuth-Range FOV');
xline(FOV.az.core(1),'r--','5%');
xline(FOV.az.core(2),'r--','95%');

figure;
histogram(FOV.az.all,100,'Normalization','pdf'); % azi 포인트 확률 밀도함수
grid on; hold on;
xline(FOV.az.core(1),'r--');
xline(FOV.az.core(2),'r--');
xlabel('Azimuth [deg]');
ylabel('PDF');
title('MIX Azimuth FOV');

figure;
histogram(FOV.el.all,100,'Normalization','pdf');
grid on; hold on;
xline(FOV.el.core(1),'r--');
xline(FOV.el.core(2),'r--');
xlabel('Elevation [deg]');
ylabel('PDF');
title('MIX Elevation FOV');


fprintf('\n========== MIX FOV VALIDATION ==========\n');
fprintf('Azimuth  FOV (1~99%%) : [%.2f , %.2f] deg\n',FOV.az.min,FOV.az.max);
fprintf('Azimuth  Core (5~95%%): [%.2f , %.2f] deg\n',FOV.az.core(1),FOV.az.core(2));
fprintf('Elevation FOV (1~99%%): [%.2f , %.2f] deg\n',FOV.el.min,FOV.el.max);
fprintf('Elevation Core(5~95%%): [%.2f , %.2f] deg\n',FOV.el.core(1),FOV.el.core(2));

% >>========== MIX FOV VALIDATION ==========
% Azimuth  FOV (1~99%) : [-45.00 , 45.00] deg
% Azimuth  Core (5~95%): [-41.00 , 43.00] deg
% Elevation FOV (1~99%): [-15.00 , 15.00] deg
% Elevation Core(5~95%): [-10.00 , 10.00] deg

end
