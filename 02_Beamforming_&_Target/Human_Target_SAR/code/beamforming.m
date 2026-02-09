%% Clear part
close all; clear all; clc;

%% Data load #
%h5 folder direction
folder_name = 'm3v20'; % h5 폴더 이름 지정
h5folder = ['./', folder_name]; % ./ 경로 추가


%% Parameter setting #
AFI910_Parameter_AIP
mag_th = 25000; % Maximum threshold < 
el_cal = 0; % Elevation calibration << 
z_cal = 0; % ca 

%% Save mat file
save_name = [folder_name, '_fft']; 

%% Load file, Preallocation

D = dir([h5folder+"\*.h5"]);                            % h5 folder 안에 h5 파일들을 D를 저장
file_num = size(D,1);                                           % 파일 개수에 D의 행 수를 저장 (numel(D))랑 같음
steer_vec=zeros(Nch,numel(Azi.ang),length(Ele.ang));    % steervector 생성 steer_vec(channel 개수, azimuth angle개수, elevation angle개수)
ch_fft_sr = zeros(192, 256);                           % Short_Range의 채널 수 지정 \192개는 채널에 따라서
%%ch_fft_sr_ca = zeros(192, 256);                          % Middle_Range의 채널 수 지정\ 256개는 AFI910이 피크 데이터 256개만 가져옴  
point_ang_srmap = zeros(numel(Azi.ang),numel(Ele.ang)); % SR 포인트 클라우드의 각도
%%point_ang_srmap_cp = zeros(numel(Azi.ang),numel(Ele.ang)); % SR_ca 포인트 클라우드의각도

azi_max = numel(Azi.ang);                               % azi_max : Azimuth angles의 개수(레졸루션에 의해 갯수 바뀜)
ele_max = numel(Ele.ang);                               % ele_max : Elevation angles의 개수(레졸루션에 의해 갯수 바뀜) 



%% Create steerVec
for azi_idx = 1:numel(Azi.ang) 
    temp_azi_rad = Azi.ang(azi_idx) * pi / 180;
    for ele_idx = 1:numel(Ele.ang)
        temp_ele_rad = Ele.ang(ele_idx) * pi / 180;
        for ch_idx=1:Nch
            steer_real = cos(2 * pi * ((Azi.position(ch_idx) * cos(temp_ele_rad) * sin(temp_azi_rad)) + (Ele.position(ch_idx) * sin(temp_ele_rad))));
            steer_imag = -sin(2 * pi * ((Azi.position(ch_idx) * cos(temp_ele_rad) * sin(temp_azi_rad)) + (Ele.position(ch_idx) * sin(temp_ele_rad))));
            steer_vec(ch_idx, azi_idx,ele_idx) = complex(steer_real,steer_imag); % steer_vec >> cos + j sin
        end
    end
end

%% Sampling 파일로 > 스캔으로 > 

for file_idx = 1:file_num 
 % file_idx = 1;
    filename  = D(file_idx).name;  % D struct 들어가면 name / folder/ date /byte / datenum 등의 정보가 따로 있어서
    h5filpath =[h5folder,'\',filename];

    dir  = endsWith(filename,'l.h5');
    if dir == 0
        dir = -1;
    end
    
    vel_param = extract(filename, digitsPattern);
    vel_param = vel_param{2};
    vel_param = str2double(vel_param)*dir;


    name = extractBefore(filename,".");
    svpath = ['./\2mod\',name];                     % 저장 경로 
    f = waitbar(0, 'wait');                                     % loading bar 생성 {waitbar(0~1, '문구');
    scan_max = length(h5info(h5filpath).Groups); % 파일 마다 0.1의 스캔 인터벌에 오차가 있을 수  
   point_cloud.scan(file_idx) = scan_max;
   point_cloud.name{file_idx} = name;


    for scan_idx = 1 : scan_max
     % scan_idx = 140
       waitbar(scan_idx/scan_max,f,filename+"file ("+file_idx+"/"+file_num+")"+"   scan ("+ scan_idx+"/"+scan_max+") processing");

%% load SR data
        PeakData_sr = reshape(double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/sr_fft_peak_data_cf32FFTData/sr_fft_peak_data_cf32FFTData'])),2,192,256);
        %reshape( A, 2, 192, 256)을 하는데 A는 double이고, h5파일을 읽은건데 그건 파일 경로 다음과
        %같은걸로 하는데 CFAR Out된 채널별 2D_FFT DATA : 192 ch x 256 peak x 2(real,ima) 
        
        PeakCnt_sr = double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/sr_fft_peak_data_s16PeakCnt/sr_fft_peak_data_s16PeakCnt']));
        % total Peak Cnt (max 256)
        Peakfrq_sr = double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/sr_fft_peak_data_rdf32EstFreqIdx/sr_fft_peak_data_rdf32EstFreqIdx']));
        % CFAR Out 된 [R, D] idx 256 x 2(range, doppler)인데 여기선 512x1로 쓰고
        % 포문에서 반쪽 나눠씀
        skip_cnt = 0; % 클라우드 포인트 만들때 하나씩 -인걸로 보와 일괄 스킵할 카운트 변수인듯 처음 파일로부터 몇번째꺼
 %test
    end
        for pnt_idx = 1:PeakCnt_sr % 여기가 g(c,i) * p(c) = g^(c,i)
            ch_fft_sr(:,pnt_idx) = (PeakData_sr(1,:,pnt_idx) + 1j * PeakData_sr(2,:,pnt_idx)).*phase_cal_SR_v1;
            % sr에 채널 fft는 real +1 j * imag에 해당하는걸 사측 제공 calibration값을 통해 보정 (192 x 256)
%% SR Beamforming
            for azi_idx = 1 : azi_max
                for ele_idx = 1 : ele_max             
                    % Rxx = (ch_fft_sr(:,pnt_idx)*ch_fft_sr(:,pnt_idx)'+ 1*diag(ones(1,192)) + 1j*diag(ones(1,192)));
                    % R = inv(Rxx);
                    % point_ang_srmap(azi_idx,ele_idx) = abs((steer_vec(:, azi_idx, ele_idx).'*ch_fft_sr(:,pnt_idx)*ch_fft_sr(:,pnt_idx).'*steer_vec(:,azi_idx,ele_idx))/(steer_vec(:,azi_idx,ele_idx)'*steer_vec(:,azi_idx,ele_idx)));
                    point_ang_srmap(azi_idx,ele_idx) = (abs(steer_vec(:,azi_idx,ele_idx)'*ch_fft_sr(:,pnt_idx))^2);
                    %% point_ang_srmap_cp(azi_idx,ele_idx) = abs(1 /(steer_vec(:, azi_idx, ele_idx)'*R*steer_vec(:, azi_idx, ele_idx))); 
                    %steer_vec(ch,azi_idx,ele_idx)이었는데 전체 체널에서 azi랑 eld의
                    %pnt인덱스에 보정된 결과에 맞는 값을 곱하고 그걸 합하고 절댓값 
                    
                end
            end
            pnt_srmag = max(point_ang_srmap,[],"all");
            % 제일 큰 요소를 기준으로 
            if pnt_srmag > mag_th && Peakfrq_sr(2*(pnt_idx)) ~= 0 && Peakfrq_sr(2*(pnt_idx)-1) > 7.4
          
                [pnt_az_idx,pnt_el_idx] = find(point_ang_srmap == pnt_srmag);
                % point_ang_srmap == pnt_srmag 

                point_cloud.sr_mag{scan_idx,file_idx}(pnt_idx-skip_cnt) =  pnt_srmag;
                % if point_cloud.sr_mag{scan_idx,file_idx}(pnt_idx-skip_cnt) >= mag_th 
                %     point_cloud.sr_mag_th{scan_idx,file_idx}(pnt_idx-skip_cnt) = point_cloud.sr_mag{scan_idx,file_idx}(pnt_idx-skip_cnt) ;
                % else
                %     point_cloud.sr_mag_th{scan_idx,file_idx}(pnt_idx-skip_cnt) =0.1;
                % end
                point_cloud.sr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt) = rang_res_sr * Peakfrq_sr(2*(pnt_idx)-1);

                point_cloud.sr_dop{scan_idx,file_idx}(pnt_idx-skip_cnt) = Peakfrq_sr(2*(pnt_idx));

                point_cloud.sr_el{scan_idx,file_idx}(pnt_idx-skip_cnt) = Ele.ang(pnt_el_idx)+el_cal;

                point_cloud.sr_az{scan_idx,file_idx}(pnt_idx-skip_cnt) = Azi.ang(pnt_az_idx); 
                
                % x 좌표 변환 
                point_cloud.sr_data{scan_idx,file_idx}(1,pnt_idx-skip_cnt) = (point_cloud.sr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    cos(deg2rad(point_cloud.sr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))*...
                    cos(deg2rad(point_cloud.sr_az{scan_idx,file_idx}(pnt_idx-skip_cnt))));
                % y 좌표 변환
                point_cloud.sr_data{scan_idx,file_idx}(2,pnt_idx-skip_cnt) = point_cloud.sr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    cos(deg2rad(point_cloud.sr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))*...
                    sin(deg2rad(point_cloud.sr_az{scan_idx,file_idx}(pnt_idx-skip_cnt)))+((1e-4)*vel_param*scan_idx); 
                % z 좌표 변환
                point_cloud.sr_data{scan_idx,file_idx}(3,pnt_idx-skip_cnt) = point_cloud.sr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    sin(deg2rad(point_cloud.sr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))+z_cal;
                
                else
                skip_cnt = skip_cnt+1;
            end

           
        end
        point_cloud.sr_cnt(scan_idx,file_idx) = PeakCnt_sr - skip_cnt;
         
    %load MR data
        PeakData_mr = reshape(double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/mr_fft_peak_data_cf32FFTData/mr_fft_peak_data_cf32FFTData'])),2,192,256);
        PeakCnt_mr = double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/mr_fft_peak_data_s16PeakCnt/mr_fft_peak_data_s16PeakCnt']));
        Peakfrq_mr = double(h5read(h5filpath, ['/SCAN_',num2str(scan_idx-1,'%05d'),'/mr_fft_peak_data_rdf32EstFreqIdx/mr_fft_peak_data_rdf32EstFreqIdx']));
        
        skip_cnt = 0;
        for pnt_idx = 1:PeakCnt_mr
            ch_fft_mr(:,pnt_idx) = (PeakData_mr(1,:,pnt_idx) + 1j * PeakData_mr(2,:,pnt_idx)).*phase_cal_MR_v1;


%MR Beamforming
            for azi_idx = 1 : azi_max
                for ele_idx = 1 : ele_max             
                    % point_ang_mrmap(azi_idx,ele_idx) = abs(sum(steer_vec(:,azi_idx,ele_idx).*ch_fft_mr(:,pnt_idx)));
                    % point_ang_mrmap(azi_idx,ele_idx) = abs((steer_vec(:, azi_idx, ele_idx).'*ch_fft_mr(:,pnt_idx)*ch_fft_mr(:,pnt_idx).'*steer_vec(:,azi_idx,ele_idx))/(steer_vec(:,azi_idx,ele_idx)'*steer_vec(:,azi_idx,ele_idx)));
                    point_ang_mrmap(azi_idx,ele_idx) = (abs(steer_vec(:,azi_idx,ele_idx)'*ch_fft_mr(:,pnt_idx))^2);

                end
            end
            pnt_mrmag = max(point_ang_mrmap,[],"all");
            if pnt_mrmag > mag_th && Peakfrq_sr(2*(pnt_idx)) ~= 0 && Peakfrq_mr(2*(pnt_idx)-1) > 7.4
                [pnt_az_idx,pnt_el_idx] = find(point_ang_mrmap == pnt_mrmag);
                
                point_cloud.mr_mag{scan_idx,file_idx}(pnt_idx-skip_cnt) =  pnt_mrmag;

                point_cloud.mr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt) = rang_res_mr * Peakfrq_mr(2*(pnt_idx)-1);

                point_cloud.mr_dop{scan_idx,file_idx}(pnt_idx-skip_cnt) = Peakfrq_mr(2*(pnt_idx));

                point_cloud.mr_el{scan_idx,file_idx}(pnt_idx-skip_cnt) = Ele.ang(pnt_el_idx)+el_cal;

                point_cloud.mr_az{scan_idx,file_idx}(pnt_idx-skip_cnt) = Azi.ang(pnt_az_idx);

                point_cloud.mr_data{scan_idx,file_idx}(1,pnt_idx-skip_cnt) = (point_cloud.mr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    cos(deg2rad(point_cloud.mr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))*...
                    cos(deg2rad(point_cloud.mr_az{scan_idx,file_idx}(pnt_idx-skip_cnt))));

                point_cloud.mr_data{scan_idx,file_idx}(2,pnt_idx-skip_cnt) = point_cloud.mr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    cos(deg2rad(point_cloud.mr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))*...
                    sin(deg2rad(point_cloud.mr_az{scan_idx,file_idx}(pnt_idx-skip_cnt)))+((1e-4)*vel_param*scan_idx);

                point_cloud.mr_data{scan_idx,file_idx}(3,pnt_idx-skip_cnt) = point_cloud.mr_rng{scan_idx,file_idx}(pnt_idx-skip_cnt)*...
                    sin(deg2rad(point_cloud.mr_el{scan_idx,file_idx}(pnt_idx-skip_cnt)))+z_cal;
            else
                skip_cnt = skip_cnt+1;
            end
        end
        point_cloud.mr_cnt(scan_idx,file_idx) = PeakCnt_mr - skip_cnt;
        
        sr_end = point_cloud.sr_cnt(scan_idx,file_idx);
        mr_end = point_cloud.mr_cnt(scan_idx,file_idx);
        point_cloud.mix_data{scan_idx,file_idx} = zeros(3,sr_end+mr_end);
        point_cloud.mix_data{scan_idx,file_idx}(:,1:sr_end) = point_cloud.sr_data{scan_idx,file_idx}(:,:);
        point_cloud.mix_data{scan_idx,file_idx}(:,sr_end+1:sr_end+mr_end) = point_cloud.mr_data{scan_idx,file_idx}(:,:);

        mix_mag = zeros(1, sr_end + mr_end);
        mix_mag(:, 1:sr_end) = point_cloud.sr_mag{scan_idx, file_idx}(:,:);
        mix_mag(:, sr_end + 1:sr_end + mr_end) = point_cloud.mr_mag{scan_idx, file_idx}(:,:);
        
        point_cloud.mix_data{scan_idx, file_idx} = [point_cloud.mix_data{scan_idx, file_idx}; mix_mag];

        point_cloud.mix_cnt(scan_idx,file_idx)=sr_end+mr_end;
    end
% x,y,z, mag, 
    close(f)
   
% end
%save([h5folder,'\',save_name,'.mat'],'point_cloud');

%end                 

