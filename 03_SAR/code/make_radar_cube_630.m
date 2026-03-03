%% Clear part
close all; clear all; clc;
tic;

%% Data load #
%h5 folder direction
folder_name = '20rtol'; % h5 폴더, 파일에 r이 있을경우와 l이 있을 경우 방향이 다르므로 주의  
h5folder = ['./', folder_name]; % ./ 경로 추가 

%% Parameter setting #
Copy_of_Parameter_630
% Parameter_630
%% Save mat file
save_name = [folder_name, '_fft']; 

%% Load file

D = dir([h5folder+"\*.h5"]);                            % h5 folder 안에 h5 파일들을 D를 저장
file_num = size(D,1);                                           % 파일 개수에 D의 행 수를 저장 (numel(D))랑 같음
steer_vec=zeros(Nch,numel(Azi.ang),length(Ele.ang));
Tc=  256e-6;
azi_max = numel(Azi.ang);                               
ele_max = numel(Ele.ang);  

range_res =  c/(2*BW);
NFFT1 = Nsamples; %256
w1=hamming(Nsamples); 
NFFT2 = Nchirp ; %64
w2 = hamming(Nchirp);
doppler_res = lambda / (2 * Nchirp * chirp_interval );

max_vel= c/fc/(4*Tc) ; 
fft2vel=linspace(-max_vel,max_vel,NFFT2+1); 
fft2vel=fft2vel(2:end);




%% Sample2Scan


for file_idx = 1:file_num
    % file_idx = 1;
    filename  = D(file_idx).name;  
    h5filpath =[h5folder,'\',filename];
   
    %% SAR 방향 존재시 

    dir  = endsWith(filename,'l.h5');
    if dir == 0
        dir = -1;
    vel_param = extract(filename, digitsPattern);
    vel_param = vel_param{2};
    vel_param = str2double(vel_param)*dir;
    end
    %%
    name = extractBefore(filename,".");
    svpath = ['./\2mod\',name];                     % 저장 경로 
    f = waitbar(0, 'wait');                                     % loading bar 생성 {waitbar(0~1, '문구');
   scan_max = length(h5info(h5filpath).Groups); 
   
   doppler_axis = (-Nchirp/2):(Nchirp/2 - 1);

  
 
  %% Data Load
 for scan_idx = 1:scan_max
    waitbar(scan_idx/scan_max,f,filename+"file ("+file_idx+"/"+file_num+")"+"   scan ("+ scan_idx+"/"+scan_max+") processing");

    radar_data = reshape(double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx,'%05d'),'/Sim_TimeData'])),Nsamples,Nch,Nchirp,[]);

    % Preallocate
    % scan_data(scan_idx).channel_data = struct('channel_id', {},
    % 'rawdata', {}, 'fft1', {}, 'fft2', {}); % rawdata를 담아서 넘기기엔 비효율적이라 생략
    scan_data(scan_idx).channel_data = struct('channel_id', {}, 'fft1', {}, 'fft2', {});
    RD_cube = zeros(Nch, Nsamples/2, Nchirp); 

    for ch_idx = 1:Nch
        scan_data(scan_idx).channel_data(ch_idx).channel_id = ch_idx;
        % scan_data(scan_idx).channel_data(ch_idx).rawdata = squeeze(radar_data(:, ch_idx, :));
        rawdata = squeeze(radar_data(:, ch_idx, :));
        for chirp_idx = 1:Nchirp
            % radar_data_ch = scan_data(scan_idx).channel_data(ch_idx).rawdata(:, chirp_idx);
            radar_data_ch = rawdata(:, chirp_idx);
            fft_inst = fft(detrend(radar_data_ch,0).*w1);
            scan_data(scan_idx).channel_data(ch_idx).fft1(:, chirp_idx) = fft_inst(1:NFFT1/2);
        end

        for range_bin = 1:size(scan_data(scan_idx).channel_data(ch_idx).fft1,1)
            radar_data_rb = scan_data(scan_idx).channel_data(ch_idx).fft1(range_bin,:);
            fft_inst = fft(detrend(radar_data_rb,0).*w2');
            scan_data(scan_idx).channel_data(ch_idx).fft2(range_bin,:) = fftshift(fft_inst);
        end

        RD_cube(ch_idx,:,:) = scan_data(scan_idx).channel_data(ch_idx).fft2;
    end %ch 루프 끝
 end % 스캔 루프 끝
% save([h5folder, '\', name, '_fft.mat'], 'scan_data', '-v7.3');
save([h5folder, '\', name, '_fft.mat'], 'scan_data');
    RD_avg = squeeze(mean(abs(RD_cube),1));  
    figure,
    imagesc(fft2vel, freq2rang, RD_avg);
    xlabel('Velocity [m/s]'); ylabel('Range [m]');
    ax = gca; ax.YDir = 'normal';
    title('Average Range-Doppler Map');
    colorbar

end % 파일루프 끝
close(f)
time = toc

%% 임의 채널 하나 고르고 거리 확인해보기 >> 3.1~3.2까지
% ch4_range_time = []; % [Range_bin x Scan_idx]
% 
% for scan_idx = 1:scan_max
% 
%     ch4_fft1 = abs(scan_data(scan_idx).channel_data(4).fft1);
%     ch4_range_time(:, scan_idx) = mean(ch4_fft1, 2); 
% end
% 
% % 시각화
% figure('Name', 'Channel 4 Range-Time Spectrogram', 'Color', 'w');
% imagesc(1:scan_max, freq2rang, 10*log10(ch4_range_time)); % 시간축 변경없이 모든 스캔 - 거리 확인
% xlabel('Scan Index (Time)'); 
% ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Channel 4: Range-Time');
% colorbar;
% colormap(jet);
% grid on;
% 
% 
% ylim([0 10]); % 관측 범위 설정