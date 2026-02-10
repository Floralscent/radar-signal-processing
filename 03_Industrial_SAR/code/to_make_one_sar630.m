
clear; clc; close all;
tic;

%% Paraam Load
Parameter_630; 
gPhaseCal_complex = gPhaseCal_complex(:); 

%% Path & File Setting
folder_name = '20rtol';
h5folder = ['./', folder_name];
D = dir(fullfile(h5folder, '*_fft.mat'));
file_num = size(D, 1);

%% Radar & Platform >> 실험 환경 유의!
v_platform = 0.02;     %20mm/s
T_scan = 0.1;           
platform_axis = 'x';   %

% Target Range(분석할 거리 범위) >2nd fft로 확인할것 
range_min = 2.9;        
range_max = 3.4;        
doppler_half_bins = 2;  

%% Steering Vector
lambda = c / fc;
range_res = c / (2 * BW);
freq2rang = (1:(Nsamples/2)) * range_res; 

azi_ang = Azi.ang;
ele_ang = Ele.ang;
azi_max = numel(azi_ang);
ele_max = numel(ele_ang);

[AZI_grid, ELE_grid] = meshgrid(azi_ang, ele_ang);
AZI_grid = AZI_grid.'; ELE_grid = ELE_grid.'; 

ux = cosd(ELE_grid) .* cosd(AZI_grid);
uy = cosd(ELE_grid) .* sind(AZI_grid);
uz = sind(ELE_grid);

% Steering Vector 생성
steer_vec = zeros(Nch, azi_max, ele_max);
for azi_idx = 1:azi_max
    az_rad = deg2rad(azi_ang(azi_idx));
    for ele_idx = 1:ele_max
        el_rad = deg2rad(ele_ang(ele_idx));
        for ch_idx = 1:Nch
            phase = 2*pi*(Azi.position(ch_idx)*cos(el_rad)*sin(az_rad) + Ele.position(ch_idx)*sin(el_rad));
            steer_vec(ch_idx, azi_idx, ele_idx) = exp(-1j*phase);
        end
    end
end

%% Main Process
rng_bins = find(freq2rang >= range_min & freq2rang <= range_max); % 2nd fft로 타겟 확인후에 그과정에 있는거만

for file_idx = 1:file_num
    filename = D(file_idx).name;
    fprintf('Processing: %s\n', filename);
    
    load(fullfile(h5folder, filename)); 
    scan_max = numel(scan_data);
    scan_center = round(scan_max/2);
    
    sar_accum = complex(zeros(azi_max, ele_max, numel(rng_bins)));
    incoh_sum = zeros(azi_max, ele_max, numel(rng_bins));
    
    dop_center = round(Nchirp/2);
    dop_range = (dop_center - doppler_half_bins):(dop_center + doppler_half_bins);
    
    for scan_idx = 1:scan_max
        disp_dist = v_platform * T_scan * (scan_idx - scan_center);% 시간에 따른 누적, 910 사용할땐 xyz 좌표pt 직접 반영했음
        radar_pos = [0, 0, 0];
        if platform_axis == 'x', radar_pos(1) = disp_dist; else, radar_pos(2) = disp_dist; end
        
        for rng_idx = 1:numel(rng_bins)
            current_rng_idx = rng_bins(rng_idx);
            bf_complex = complex(zeros(azi_max, ele_max));
            
            for dop_idx = dop_range
                ch_fft = zeros(Nch, 1);
                for ch_idx = 1:Nch
                    ch_fft(ch_idx) = scan_data(scan_idx).channel_data(ch_idx).fft2(current_rng_idx, dop_idx);
                end %채널
                ch_fft = ch_fft .* gPhaseCal_complex;
                tmp = squeeze(sum(steer_vec .* reshape(ch_fft, [Nch, 1, 1]), 1));
                bf_complex = bf_complex + tmp;
            end %도플러
            bf_complex = bf_complex / numel(dop_range);
            
            % SAR Slant Range Correction 슬랜트 거리, 실제 거리와 공칭 거리 혼용 주의
            R_phys = freq2rang(current_rng_idx); %레이더가 측정한 타겟 거리
            Rx = ux * R_phys - radar_pos(1);
            Ry = uy * R_phys - radar_pos(2);
            Rz = uz * R_phys - radar_pos(3);
            R_now = sqrt(Rx.^2 + Ry.^2 + Rz.^2);
            deltaR = R_now - R_phys; %레이더 측정 거리와 실제 위치간의 차이
            
            phase_corr = exp(-1j * 4*pi * deltaR / lambda); %를 위상으로 적용
            
            sar_accum(:,:,rng_idx) = sar_accum(:,:,rng_idx) + bf_complex .* phase_corr; %위상 적용
            incoh_sum(:,:,rng_idx) = incoh_sum(:,:,rng_idx) + abs(bf_complex).^2; %에너지 누적
        end % 거리
    end % 스캔
    
    %% visual
    for rng_idx = 1:numel(rng_bins)
        current_rng = freq2rang(rng_bins(rng_idx));
        
        figure('Name', sprintf('Range %.3f m', current_rng), 'NumberTitle', 'off');
        
        % Left: Coherent SAR
        subplot(1,2,1);
        imagesc(azi_ang, ele_ang, abs(sar_accum(:,:,rng_idx)).^2.');
        axis xy; colorbar; colormap(jet);
        xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
        title(sprintf('SAR Image (R=%.2f m)', current_rng));
        
        % Right: Incoherent Sum 
        subplot(1,2,2);
        imagesc(azi_ang, ele_ang, incoh_sum(:,:,rng_idx).');
        axis xy; colorbar; colormap(jet);
        xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
        title('Incoherent Sum');
    end
    
    %% Combined Result
    
    if numel(rng_bins) > 1
        combined_img = sum(abs(sar_accum).^2, 3);
        figure('Name', 'Final Combined SAR Result', 'NumberTitle', 'off');
        imagesc(azi_ang, ele_ang, combined_img.');
        axis xy; colorbar; colormap(jet);
        xlabel('Azimuth (deg)'); ylabel('Elevation (deg)');
        title(sprintf('Combined SAR (%.2f - %.2f m)', range_min, range_max));
    end
end

toc;