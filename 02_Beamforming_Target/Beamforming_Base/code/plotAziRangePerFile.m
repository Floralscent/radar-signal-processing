function plotAziRangePerFile(point_cloud, steer_ang,thr)
%plotAziRangePerFile(point_cloud, steer_ang,1e7)
[cnt_scan_max, file_num] = size(point_cloud.mix_cnt);

assert(length(steer_ang) == file_num, ...
    'steer_ang length must match num of files'); % load point_cloud > steer_ang = -60:5:60 ;  thr = 1e7

% 
target_files = [2, 6, 18, 25];
sub_plot_idx = 1; 
h_fig_sub = figure('Name', 'Selected Files Comparison');

for file_idx = 1:file_num

    az_all  = [];
    rng_all = [];
    mag_all = [];

    valid_azi = steer_ang(file_idx);

    for scan_idx = 1:cnt_scan_max

        cnt = point_cloud.mix_cnt(scan_idx, file_idx);
        if cnt <= 0
            continue;
        end

        pc = point_cloud.mix_data{scan_idx, file_idx}; % [x;y;z;mag]
        xyz = pc(1:3, 1:cnt);
        mag = pc(4, 1:cnt);

        x = xyz(1,:);
        y = xyz(2,:);
        z = xyz(3,:);

        % rng = sqrt(x.^2 + y.^2 + z.^2);
        % az  = atan2d(y, x);
        rng = point_cloud.mix_rng{scan_idx,file_idx};
        
        az = point_cloud.mix_az{scan_idx,file_idx};
        el = point_cloud.mix_el{scan_idx,file_idx};

        az_all  = [az_all  az];
        rng_all = [rng_all rng];
        mag_all = [mag_all mag];

    end
    
    %% thr
    idx = mag_all > thr;
    
    az_filtered  = az_all(idx);
    rng_filtered = rng_all(idx);
    mag_filtered = mag_all(idx);

    %% Plot 모든 azi에 대해 보고 특징적인 값 찾자
    % figure;
    % scatter(az_filtered, rng_filtered, 8, mag_filtered, 'filled');
    % grid on; colorbar;
    % 
    % xlabel('Azimuth [deg]');
    % ylabel('Range [m]');
    % title(sprintf('Steering = %d deg (File %d)', valid_azi, file_idx));
    % 
    % xline(valid_azi, 'r--', 'Steer angle');
    % xlim([-60 60]);
    % xticks(-60:5:60);
    % ylim([0 3.5]);
    
    %% FOV중에 특징적인 값
    if ismember(file_idx, target_files)
        figure(h_fig_sub); 
      
        subplot(4, 1, sub_plot_idx); 
        
        scatter(az_filtered, rng_filtered, 10, mag_filtered, 'filled');

        grid on;
        ylabel('Range [m]');
        title(sprintf('File %d: Steer %d^o', file_idx, valid_azi));
        
        
        xlim([-60 60]); xticks(-60:5:60); ylim([0 3.5]);
        xline(valid_azi, 'r--');
        
        if sub_plot_idx == 4
            xlabel('Azimuth [deg]');
            cb = colorbar;
            cb.Location = 'manual'; %
            cb.Position = [0.93, 0.11, 0.02, 0.815]; % [left, bottom, width, height]
            ylabel(cb, 'Magnitude'); 
        end
        
        sub_plot_idx = sub_plot_idx + 1;
    end

    

end
end

