clear all;  clc;

%% File load %%%%%%%% 파일 가져오기
% Radar dataset parameter 
num_chirp= 64; % 한 scan의 chirp 수 
sample_per_chirp= 256; % 한 chirp의 sample
chirp_num = 0:num_chirp-1;

load('radar_4figure_data.mat');  % 파일 가져오기
radar_data=double(timeData);
%  radar_data를 sample_per_chirp x num_chirp x num_scan 크기로 변환 << reshpae. 
% num_scan은 radar_data의 scan
num_scan= 798; % scan의 수, 총 데이터는 sample * chirp * scan 
radar_data=reshape(radar_data,sample_per_chirp,num_chirp,num_scan);% 256 64 798
% column이 한 스캔에 있는 처프의 인덱스, row가 스캔의 인덱스  


%% Parameter %%%%%%%% 파라미터 변경사항
% 레이더 사양 
BW=  3e9; % Bandwidth 3 GHz
Tc=  256e-6; % Chirp duaration 256 us
Fc=  61e9; % Center frequency 61 GHz
Fs=  1e6; % Sampling frequency 1 MHz
scan_duration=  100e-3; % Scan duration 100 ms 
c = physconst('LightSpeed'); % 빛의 속도, 볼츠만 상수, 지구 반지름 상수 불러오기 명령어

% Pre-allocation 사전 할당 해놓기 >> 속도 상의 이점
NFFT1=sample_per_chirp; % 한 chrip의 sample 숫자를 NFFT1이라는 변수 지정
w1=hamming(sample_per_chirp); % 한 chirp의 sample 숫자를 가지는 햄밍 윈도우 반환, 왜 하필 햄밍일까?
%sidelobe 많이 줄고, mainlobe 폭 괜찮고, drop - off trade-off다 괜찮네? 
signal_fft_once = zeros(size(radar_data(1:end/2,:,:))); 
% fft 첫번째에 대해 한 chirp에 있는 sample 절반, 나머지에 대해 사이즈를 가지는 0 메트릭스 사전 할당
signal_fft_twice = zeros(size(radar_data(1:end/2,:,:)));
% fft 두번째에 대해 한 chirp에 있는 sample 절반, 나머지에 대해 사이즈를 가지는 0 메트릭스 사전 할당
rang_vel = zeros(size(radar_data(1:end/2,:),1),size(radar_data,3));
% range 와 velocity 에 대해 한 chirp에 있는 sample 절반,총 스캔 사이즈를 가지는 0 메트릭스 사전 할당

%% 1st FFT 첫번째 FFT하기 
for scan_idx = 1:size(radar_data,3) %1부터 num_scan의 수 , 798번 반복
    % radar_data_ES는 radar_data의 각 scan_idx의 데이터 256 x 64 크기.
    radar_data_ES = radar_data(:,:,scan_idx) ; 
    for chirp_idx = 1:size(radar_data,2) % 1부터 chirp의 수, 64번 반복
        % radar_data_EC는 radar_data_ES의 각 chirp의 데이터 256 x 1 크기.
        % fft_inst는 radar_data_EC의 평균을 제거하고 hamming window w1을 적용한 뒤, FFT를 수행한 결과
        radar_data_EC = radar_data_ES(:,chirp_idx)  ;
        fft_inst = fft(detrend(radar_data_EC,0).*w1) ; %데이터의 평균을 제거하고 윈도우 쳐서 DC성분 제거후 SNR개선
        signal_fft_once(:,chirp_idx,scan_idx) = fft_inst(1:NFFT1/2);
    end
    % 특정 scan_idx에서의 range_spec1은 signal_fft_once의 각 행에 대한 절댓값의 평균
    rang_spec1(:,scan_idx) = mean(abs(signal_fft_once(:,:,scan_idx)),2); 
end

NFFT2 = num_chirp;
w2 = hamming(num_chirp);
%실수 fft하면 두개 나오는데 허수fft하면 한개 나오는 이유 
%% 2nd FFT
for scan_idx = 1:size(radar_data,3) %scan수 만큼 반복, 798번
    % fft_once_ES는 signal_fft_once의 각 scan_idx의 데이터 128 x 64 크기.
    fft_once_ES = signal_fft_once(:,:,scan_idx);
    for range_bin = 1:size(signal_fft_once,1) % 한 fft once에는 chirp의 sample수의 절반만큼(실수 푸리에> 대칭되서 복사)가 반영되어 있음 
        % fft_once_ER는 fft_once_ES의 각 range_bin의 데이터 1 x 64 크기.
        % fft_inst는 fft_once_ER의 평균을 제거하고 hamming window w2를 적용한 뒤, FFT를 수행한 결과
        fft_once_ER = fft_once_ES(range_bin,:);
        fft_inst = fft(detrend(fft_once_ER,0).*w2') ;
        signal_fft_twice(range_bin,:,scan_idx) = fftshift(fft_inst);
    end
    % 특정 scan_idx에서의 Doppler_map은 signal_fft_twice의 절대값을 취한 뒤 각 열에 대한 평균
    % 특정 scan_idx에서의 rang_spec2는 signal_fft_twice의 절대값을 취한 뒤 각 행에 대한 평균
    Doppler_map(:,scan_idx) = mean(abs(signal_fft_twice(:,:,scan_idx)),1);
    rang_spec2(:,scan_idx) =mean(abs(signal_fft_twice(:,:,scan_idx)),2);
end


%% Threshold 방법론과 V max

max_vel= c/Fc/(4*Tc) ; % 속력 최대치는 람다/(4*Tc)
fft2vel=linspace(-max_vel,max_vel,NFFT2+1); %fft 속도 축의 크기는 0을 포함하기때문에 NFFT2 = num_chirp +1 등분
fft2vel=fft2vel(2:end); %64개니까 첫번째껄 하나 버려
range_vel_thr = 8; % 쓰레숄드 상수 보정값
for scan_idx=1:size(radar_data,3)
    % tmp_fft2 = signal_fft_twice의 각 scan_idx의  128 x 64 크기.
    tmp_fft2 = signal_fft_twice(:,:,scan_idx); %tmp임시변수인데 fft 두번 한 것들 각각 저장
    

    thr_window = ones(size(tmp_fft2)); %tmp_fft = fft twice 사이즈에 1행렬 생성
    thr_window(3:end-2,3:end-2)=0; % 양옆, 위아래 두줄 말고 다 0처리
    thr = sum(sum(abs(tmp_fft2).*thr_window))/sum(thr_window(:)); 
    %fft 두번 한거에 절댓값에 Threshol window 치고 그걸 정규화? 시킨걸 Threshold 로 계산
  
    tmp = abs(tmp_fft2)>range_vel_thr*thr; %임시 값들을 Threshold와 range_vel Threshold 상수값보다 절대값이 큰 아이 찾기
    nonzero_idx=find(sum(tmp,2)~=0);  %tmp의 행의 합이 0과 같지 않은 인덱스를 찾음
    
    for range_bin=nonzero_idx'
        vel_idx=find(tmp(range_bin,:)==1); %tmp의 행의 합이 0과 같지 않은 인덱스를 바탕으로 Threshold보다 큰 값 인덱스 찾음
        vel_min=fft2vel(vel_idx(1)); 
        vel_max=fft2vel(vel_idx(end));
        
        if abs(vel_min) > abs(vel_max)
            rang_vel(range_bin,scan_idx) = vel_min;
        else
            rang_vel(range_bin,scan_idx) = vel_max;
        end
        % if문을 작성하세요. vel_min과 vel_max의 절대값을 비교하여,
        % vel_min의 절대값이 크면, rang_vel(range_bin,scan_idx)에는 vel_min
        % 그렇지 않으면 vel_max가 저장
    end    
end

%% Figure


rang_res =  c/(2*BW);

freq2rang = 1:sample_per_chirp/2;
freq2rang = freq2rang*rang_res;
time = [1:num_scan]*scan_duration;

% max_vel= c/Fc/(4*Tc) ; % 속력 최대치는 람다/(4*Tc)
% fft2vel=linspace(-max_vel,max_vel,NFFT2+1); %fft 속도 축의 크기는 0을 포함하기때문에 NFFT2 = num_chirp +1 등분
% fft2vel=fft2vel(2:end); %64개니까 첫번째껄 하나 버려


% 
% figure,
% imagesc(20*log10(abs(radar_data(:,:,400))));
% xlabel('Chirp Num'); ylabel('Sample');
% ax = gca; ax.YDir = 'normal';
% colorbar
% title('raw sig at 400th scan');
% 
% 
% figure,
% imagesc(chirp_num, freq2rang,20*log10(abs(signal_fft_once(:,:,400))))
% hold on
% xlabel('Chirp Num'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Magnitude');
% colorbar
% % [max_val, max_idx] = (signal_fft_once(:,:,400))
% 
% figure,
% imagesc(chirp_num, freq2rang,angle(signal_fft_once(:,:,400))) %35 sample index 선형 변화
% xlabel('Chirp Num'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Phase');
% colorbar
% 
% figure,
% imagesc(fft2vel, freq2rang, abs(signal_fft_twice(:,:,400)));
% xlabel('Velocity [m/s]'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Magnitude');
% colorbar
%% Figure
figure,imagesc(time,freq2rang,20*log10(rang_spec1));% Range spectrogram(1st FFT)
xlabel('Time [s]', 'FontSize', 12); ylabel('Range [m]', 'FontSize', 12);
ax = gca; ax.YDir = 'normal';
title('Range spectrogram (1st FFT)', 'FontSize', 20);
% colorbar

figure,imagesc(time,freq2rang,20*log10(rang_spec2));% Range spectrogram(2nd FFT)
xlabel('Time [s]','FontSize', 12); ylabel('Range [m]', 'FontSize', 12);
ax = gca; ax.YDir = 'normal';
title('Range spectrogram (2nd FFT)', 'FontSize', 20);
% colorbar

figure,imagesc(time,fft2vel,20*log10(Doppler_map));% Doppler map
xlabel('Time [s]', 'FontSize', 12); ylabel('Velocity [m/s]', 'FontSize', 12);
ax = gca; ax.YDir = 'normal';
title('Doppler map', 'FontSize', 20);
% colorbar

figure, imagesc(time, freq2rang, rang_vel); % Range velocity map
xlabel('Time [s]', 'FontSize', 12);
ylabel('Range [m]', 'FontSize', 12);
ax = gca; ax.YDir = 'normal';
title('Range velocity map', 'FontSize', 20);

cb = colorbar;  % colorbar 객체 생성
cb.Label.String = 'Velocity [m/s]';  % colorbar에 라벨 추가
cb.Label.FontSize = 12;  % colorbar 라벨 폰트 크기 설정

% 색상 범위 구성
cmap = [...
    linspace(0, 0.2, 100)', linspace(0, 0.4, 100)', linspace(0.5, 1, 100)';  % -1.7 ~ -0.5 (어두운 남색 -> 하늘색)
    linspace(0.5, 0.7, 50)', linspace(0.9, 1, 50)', linspace(0.9, 1, 50)';  % -0.5 ~ 0.5 (밝은 하늘색)
    linspace(1, 1, 100)', linspace(0.7, 1, 100)', linspace(0, 0, 100)'];  % 0.5 ~ 3 (노랑색 더 강하게)

colormap(cmap);
caxis([-1.7 3]);  % 값 범위 설정




% caxis([-1.7  3]);

%클러터 제거가 레인지 별로 평균을 내보고, 그 값을 처프 별로 빼(?)

% figure(1)
% subplot(1,3,1)
% imagesc(20*log10(abs(radar_data(:,:,400))));
% hold on
% xlabel('Chirp Num'); ylabel('Sample');
% ax = gca; ax.YDir = 'normal';
% colorbar
% title('raw sig at 400th scan');
% 
% subplot(1,3,3)
% imagesc(fft2vel, freq2rang, abs(signal_fft_twice(:,:,400)));
% hold on
% xlabel('Velocity [m/s]'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Magnitude');
% colorbar
% 
% subplot(2,3,2)
% imagesc(chirp_num, freq2rang,20*log10(abs(signal_fft_once(:,:,400))))
% hold on
% xlabel('Chirp Num'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Magnitude');
% colorbar
% 
% subplot(2,3,5)
% imagesc(chirp_num, freq2rang,angle(signal_fft_once(:,:,400)))
% hold on
% xlabel('Chirp Num'); ylabel('Range [m]');
% ax = gca; ax.YDir = 'normal';
% title('Phase');
% colorbar
    

