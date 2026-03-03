% Radar parameters
Nch = 8;                % Number of channels
Nchirp = 64;            % Number of chirps
Nsamples = 256;         % Number of samples
chirp_interval = 0.05;  % Chirp interval (sec)
ROA_CR_window_size = 30;
win_size = 64;
minRangebin = 3;
maxRangebin = 48;
anglemin = -45;         % Azimuth angle minimum
anglemax = 45;          % Azimuth angle maximum
BW = 3e9;             % Bandwidth
freq2rang = linspace(0, 1e6/2, Nsamples/2+1);
freq2rang = freq2rang(2:end);
freq2rang = 256 * (1/(1e6)) * (3e8) / (2*BW) * freq2rang;

% Phase calibration
gPhaseCal.real = single([1.0000, -0.0756, 0.8994, 0.2376, -0.9589, 0.4933, -0.9764, -0.0705]);
gPhaseCal.imag = single([0.0000, 0.9971, -0.4372, 0.9714, -0.2838, -0.8699, 0.2162, -0.9975]);
gPhaseCal_complex = single(gPhaseCal.real + 1j*gPhaseCal.imag);

% Antenna positions
Azi.position = [0.0, 0.0, 0.5, 1.0, 0.5, 0.5, 1.0, 1.5]; % Azimuth positions
Ele.position = [0.0, -0.5, -0.5, -0.5, 0.5, 0.0, 0.0, 0.0]; % Elevation positions

anglemin = -45;         % Azimuth angle minimum
anglemax = 45;          % Azimuth angle maximum
% Beamforming angles
Azi.ang = anglemin:1:anglemax; % Azimuth angles (-60 to 60 degrees, 5-degree steps)
Ele.ang = -15:1:15;            % Elevation angles (-60 to 60 degrees, 5-degree steps)

% Wavelength (assuming carrier frequency, e.g., 61 GHz for automotive radar)
fc = 61e9; % Carrier frequency (61 GHz)
c = 3e8;   % Speed of light
lambda = c / fc; % Wavelength