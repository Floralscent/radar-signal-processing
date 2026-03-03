%% Radar param
% Azi FoV = +- 45 / Ele FoV = +-15
% Azi resol =  2 / Ele resol = 5
Nch = 192; %NTx = 12;  NRx = 16;
chirp_interval = 0.05; % sec
ROA_CR_window_size = 30; %?
win_size = 64 ;

minRangebin = 15; %?
maxRangebin = 15;

resolel = 1;
angelmin = -15;
angelmax = 15;

resolaz = 1;
angazmin = -45; 
angazmax = 45;

c= 3e8;
Nchirp = 32;
Nsamples = 1024;

Tc= 256e-6;
Fc= 79e9;

vel_max = c / (4*Tc*Fc);
vel_res = vel_max/32; 

load("phase_cal.mat");

%% Short range paraam , BW 차이남
BW_sr = 3.0*10^9; 
rang_res_sr = c / (2*BW_sr);
freq2rang_sr = 1:Nsamples/2;
freq2rang_sr = freq2rang_sr*rang_res_sr;

%% middle range param
BW_mr = 2.2*10^9;
rang_res_mr = c / (2*BW_mr);
freq2rang_mr = 1:Nsamples/2;
freq2rang_mr = freq2rang_mr*rang_res_mr;

%% AIP (Angle in position?)
Azi.ang = [angazmin : resolaz : angazmax]; % Azimuth Beamforming angle
Ele.ang = [angelmin : resolel : angelmax];
% a.b >> a라는 struct를 형성하고 b라는 요소를 만들어서 다음식 대입

Azi.position = [0.0 0.65 1.3 1.95 2.6 3.25 3.9 4.55 5.2 5.85 6.5 7.15 7.8 8.45 9.1 9.75...
                1.3 1.95 2.6 3.25 3.9 4.55 5.2 5.85 6.5 7.15 7.8 8.45 9.1 9.75 10.4 11.05...
                2.6 3.25 3.9 4.55 5.2 5.85 6.5 7.15 7.8 8.45 9.1 9.75 10.4 11.05 11.7 12.35...
                3.9	4.55 5.2 5.85 6.5 7.15 7.8 8.45 9.1 9.75 10.4 11.05 11.7 12.35 13 13.65...
                5.2 5.85 6.5 7.15 7.8 8.45 9.1 9.75 10.4 11.05 11.7 12.35 13 13.65 14.3 14.95...
                6.5 7.15 7.8 8.45 9.1 9.75 10.4 11.05 11.7 12.35 13 13.65 14.3 14.95 15.6 16.25...
                10.4 11.05 11.7 12.35 13 13.65 14.3 14.95 15.6 16.25 16.9 17.55 18.2 18.85 19.5 20.15...
                11.7 12.35 13 13.65 14.3 14.95 15.6 16.25 16.9 17.55 18.2 18.85 19.5 20.15 20.8 21.45...
                13 13.65 14.3 14.95 15.6 16.25 16.9 17.55 18.2 18.85 19.5 20.15 20.8 21.45 22.1 22.75...
                14.3 14.95 15.6 16.25 16.9 17.55 18.2 18.85 19.5 20.15 20.8 21.45 22.1 22.75 23.4 24.05...
                15.6 16.25 16.9 17.55 18.2 18.85 19.5 20.15 20.8 21.45 22.1 22.75 23.4 24.05 24.7 25.35...
                16.9 17.55 18.2 18.85 19.5 20.15 20.8 21.45 22.1 22.75 23.4 24.05 24.7 25.35 26 26.65];

Ele.position = [0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9...
                1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7...
                3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5...
                5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3...
                7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1...
                9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9...
                0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9 0.0 0.9...
                1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7 1.8 2.7...
                3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5 3.6 4.5...
                5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3 5.4 6.3...
                7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1 7.2 8.1...
                9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9 9.0 9.9];

% Radar channel
% {
% scatter(Azi.position(1:16),Ele.position(1:16))
% scatter(Azi.position(17:32),Ele.position(17:32))
% scatter(Azi.position(33:48),Ele.position(33:48))
% scatter(Azi.position(49:64),Ele.position(49:64))
% scatter(Azi.position(65:80),Ele.position(65:80))
% scatter(Azi.position(81:96),Ele.position(81:96))
% scatter(Azi.position(97:112),Ele.position(97:112),"^")
% scatter(Azi.position(113:128),Ele.position(113:128),"^")
% scatter(Azi.position(129:144),Ele.position(129:144),"^")
% scatter(Azi.position(145:160),Ele.position(145:160),"^")
% scatter(Azi.position(161:176),Ele.position(161:176),"^")
% scatter(Azi.position(177:192),Ele.position(177:192),"^")
% legend('tx1','tx2','tx3','tx4','tx5','tx6','tx7','tx8','tx9','tx10','tx11','tx12')
% xlim([-1 35])
% ylim([-1 11])
% 
% }
