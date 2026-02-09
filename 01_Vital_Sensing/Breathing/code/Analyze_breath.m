clear all; %close all; clc;

%% File load
load('radar_breath_data.mat'); 
% radar_data는 radar_dat에서 한 chirp의 데이터만 한 chirp의 샘플 수는 256개이므로 256 x 2400 크기.
% num_scan은 radar_data의 scan .
%512 x 2400 인데 한 chirp 만 생각해서 256개 짤라 쓰고  그럼 2400 scan? 
% 그니까 256 x 2400 > 128 x 2400 == sample num x scan num 인거네?
% num chirp* sample_per_chrip*scan >> 2*256*2400>>1*256*2400
radar_data =  radar_dat(1:256, :);
num_scan =  size(radar_data, 2);

%% Parameter
BW=  6e9;
Tc=  128e-6;
Fc=  61e9;
Fs=  2e6;
scan_duration=  50e-3;
c=  3e8;

% Pre-allocation
NFFT=256;
w=hamming(256);
w1=hamming(2400);
signal_fft_once = zeros(size(radar_data(1:end/2,:)));

for scan_idx = 1:size(radar_data,2)
    % radar_data_ES는 radar_data의 각 scan_idx의 데이터 256 x 1.
    % fft_inst는 radar_data_ES의 평균을 제거하고 hamming window w를 적용한 뒤, FFT를 수행한 결과
    radar_data_EC =  radar_data(:, scan_idx);
    fft_inst = fft((radar_data_EC - mean(radar_data_EC)) .* w);
    signal_fft_once(:,scan_idx) = fft_inst(1:NFFT/2);
    
    % 특정 scan_idx에서의 mag_spec1은 signal_fft_once의 절대값
    % 특정 scan_idx에서의 inst_phase_map은 signal_fft_once의 위상각
    mag_spec1(:,scan_idx) =  abs(signal_fft_once(:,scan_idx));
    inst_phase_map(:,scan_idx) =  angle(signal_fft_once(:,scan_idx));
end
phase_map = unwrap(inst_phase_map,[],2);

rang_res = c / (2*BW);
freq2rang = 1:NFFT/2;
freq2rang = freq2rang*rang_res;
time = (1:num_scan)*scan_duration;

% 1.5정도까지 보는 이유 : 애초에 실험 시 상항을 고려, 그 이상은 필요가없어서
% 레이더로 인체 호흡 미세 변위 측정하는데 피실험체가 1.5m위치인데 그 이상 거리는 클러터로 봐야겠구나.
%dB scale %보기좋게 나오는거 아무거나...아무거나...? 보기좋다의 기준은 뭐..? 주기성이 잘 보임<<

% Magnitude (Range spectrogram)
figure,
        imagesc(time, freq2rang, 20*log10(mag_spec1)); axis xy;
        xlabel('Time [s]', 'FontSize', 16); 
        ylabel('Range [m]', 'FontSize', 16);
        ylim([0 1.51]);
        caxis([0 80]);
        title('Range Spectrogram', 'FontSize', 18); % 타이틀 폰트 18로 수정

% Phase (Phase map)
figure,
        imagesc(time, freq2rang, phase_map); axis xy;
        xlabel('Time [s]', 'FontSize', 16); 
        ylabel('Range [m]', 'FontSize', 16);
        ylim([0 1.51]);
        caxis([-10 10]);
        title('Phase Map', 'FontSize', 18); % 타이틀 폰트 18로 수정


% for range_idx = 29:33 
%     [c,lags] = xcorr(mag_spec1(range_idx,:));
%     [pxx,w] = periodogram(mag_spec1(range_idx,:),hamming(size(mag_spec1,2)));
%     figure(range_idx),
%     subplot(1,2,1)
%     stem(lags,c)
%     hold on
%     subplot(1,2,2)
%     plot(w,10*log10(pxx))
%     range_mean(range_idx) = mean(mag_spec1(range_idx,:));
%     fft_inst2 = fft(detrend(signal_fft_once(range_idx,:),0).*w2');
%     signal_fft_twice(range_idx,:) = fftshift(fft_inst2);
% end
% % 여기서 한번더 fft쳐서 주기성을 확인해봐야할까? 시간축을 주파수축으로 보냈을때 데이터가 한 주파수에 몰려 있음 주기적이니까?


%% 호흡 신호가 잘 나타나는 range bin 선택
range_bin=  32;

%% 호흡수 추출
[b,a] = butter(4,[0.1 0.4]/(1/scan_duration/2));
window_size = 15/scan_duration;     % window time 15초
moving_size = 1/scan_duration;      % moving time 1초
Nwins = length(1:moving_size:num_scan-window_size+1);
for idxWin = 1:Nwins
    % magnitude와 phase 
    
    % magnitude 이용
    inst_radar = phase_map(range_bin,(1:window_size)+(idxWin-1)*moving_size);
    
    filt_radar = filtfilt(b,a,inst_radar-mean(inst_radar));
  
    zero_point = find([0; filt_radar(:)].*[filt_radar(:); 0] < 0);
	num_zero = length(zero_point)-1;
    zero_time = (zero_point(end)-zero_point(1))*scan_duration;
    Radar_RR(idxWin) = (num_zero/2)/zero_time*60;
end
%% 특정 Range Bin에 대한 Phase 그래프 (호흡 신호가 잘 나타나는 Range Bin 선택)
range_bin = 32; 

% 선택한 Range Bin에서의 phase 변화를 시각화
figure;
plot(time, phase_map(range_bin, :), 'LineWidth', 2);
xlabel('Time [s]', 'FontSize', 16);  % x축 라벨
ylabel('Phase', 'FontSize', 16);  % y축 라벨
title(['Phase of Range Bin ', num2str(range_bin)], 'FontSize', 18);  % 타이틀
grid on;  % 그리드 추가

%% Figure
% 슬라이드 19의 그림처럼 레이더로 측정한 호흡수(Radar_RR)와 호흡 센서로 측정한 호흡수(RESP_RR)를 결과로 나타내면 됩니다.
figure, hold on;
        plot((1:length(Radar_RR))+15-1, Radar_RR, 'k', 'LineWidth', 2);
        plot((1:length(RESP_RR))+15-1, RESP_RR, '--r', 'LineWidth', 2);
        xlim([15 120]); ylim([5 25]);
        xlabel('Time [s]', 'FontSize', 16); % 라벨 크기 16으로 수정
        ylabel('Respiration Rate', 'FontSize', 16); % 라벨 크기 16으로 수정
        legend('Radar RR', 'RESP RR');
        title('Respiration Rate: Radar vs Ground Truth', 'FontSize', 18);  % 타이틀 추가
        grid on;
%% 상관계수

difference = abs(Radar_RR - RESP_RR);

% 2. 평균 호흡수 차이
mean_diff = mean(difference);

% 3. 퍼센트 오차 
percentage_error = (mean_diff / mean(RESP_RR)) * 100;

fprintf('레이더로 추출한 호흡수와 그라운드 트루스 간의 평균 절대 오차: %.2f%%\n', percentage_error);

% 두 신호의 상관계수를 계산 (얼마나 유사한지)
corr_coef = corr(Radar_RR(:), RESP_RR(:));  % 상관계수

fprintf('상관계수: %.2f\n', corr_coef);

% MSE (Mean Squared Error)
mse_value = mean((Radar_RR - RESP_RR).^2);  % Mean Squared Error 계산

fprintf('MSE (평균 제곱 오차): %.4f\n', mse_value);
%>>> 
% 레이더로 추출한 호흡수와 그라운드 트루스 간의 평균 절대 오차: 2.41%
% 상관계수: 0.84
% MSE (평균 제곱 오차): 0.2183

