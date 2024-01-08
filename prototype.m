startTime = datetime(2022,5,1,5,36,0);
% stopTime = startTime + days(90);
stopTime = startTime + hours(5);
sampleTime = 60;

sc = satelliteScenario(startTime,stopTime,sampleTime);
% Initialize a vector to store the received data
% Set the duration of the simulation to 90 days
duration = 90*24*60; % Duration of the simulation in minutes

%% configuration orbit
%semiMajorAxis (semi-major axis) is half the maximum axis length of an ellipse
%describing the satellites orbit around the Earth, measured in meters
semiMajorAxis = 7155000;

%eccentricity is a measure of how the satellites orbit deviates
% of a perfect circular orbit. It is a number between 0 and 1. The closer to zero,
% more circular is the orbit; the closer to 1, the more elliptical the orbit.
eccentricity = 0.0001030;

%inclination is the angle between the satellites orbital plane and the Earths equator,
% measured in degrees. It is the inclination of the orbit relative to the Earths equator.
inclination = 98.5; 

%rightAscensionOfAscendingNode (right ascension of ascending node) is the angle measured from the
% Earths equator to the point where the satellites orbit crosses the equator going north, measured in degrees.
% Is the longitude of the point where the satellites orbit crosses the equator going north.
rightAscensionOfAscendingNode = 161.5; 

%argumentOfPeriapsis (perihelion argument) is the angle measured from the ascending node to the point where the satellite
% is closest to Earth, measured in degrees. It is the measure of the axis orientation of the ellipse of the orbit.
argumentOfPeriapsis = 0; 

%trueAnomaly is the angle measured from perihelion to the satellites current position along
% its orbit, measured in degrees. It is the position of the satellite along the ellipse of its orbit at the time it is observed.
trueAnomaly = 263.19;  
%end
%% configuration nanosatellite

sat = satellite(sc,semiMajorAxis,eccentricity,inclination, ...
        rightAscensionOfAscendingNode,argumentOfPeriapsis,trueAnomaly,"Name","SACODE BR-1");

%configuration GS
lat = -3.7484767;
lon = -38.5788343;
gs = groundStation(sc,lat,lon,"Name","UFC-PICI");

received_data = [];
erro_rate_vector = [];

ac = access(sat,gs);
intvls = accessIntervals(ac);


% Loop through the duration of the simulation

num = size(intvls,1);
berVec = zeros(num, 1); % vector to store the BER rates
%end
%% For the simulation of communication

SNR = 10; % em dB
fc = 433e6; % center frequency in Hz
fs = 866e6; % sampling frequency in Hz
%numBits = 256*60; % number of transmitted bits
numBits = 10;
rainRate = 50; % Rain rate, specified as a nonnegative scalar in millimeters per hour (mm/h).
%end 
%% Calculating DirectPatchDooplerShift
%To calculate the v_sat_cubesat/c ratio for a satellite in LEO orbit and a ground station, it is necessary to know the altitude of the satellite and the distance between the satellite and the ground station.
%Using the equation shown earlier, we can calculate v_sat_cubesat/c as follows:

%First, we need to calculate the orbital speed of the satellite using the following formula:

%V = sqrt(mu / r)

%onde:

%mu is the Earths gravitational constant (398600.4418 km^3/s^2)
%r is the distance between the center of the Earth and the satellite (Earth radius + satellite altitude)
%Substituting the values, we have:

V = sqrt(398600.4418 / (6378.137 + (semiMajorAxis))); %Km/s

%Speed ​​of light is approximately 299792.458 km/s.
c = 299792.458;
%Finally, we can calculate the v_sat_cubesat/c ratio:

rate_v_sat = V/c;
DirectPathDopplerShift = -2*rate_v_sat * fc;

%end
%% Start of uplink simulation
for t = 1:2  

    
    % Channel object creation with propagation loss caused by rain and flicker
    rainChannel = comm.RicianChannel(...
        'SampleRate', fs, ...
        'KFactor', 1.45, ...
        'DirectPathDopplerShift',DirectPathDopplerShift, ...
        'MaximumDopplerShift', 5, ...
        'PathDelays', [0 1.5e-5 3.5e-5], ...
        'AveragePathGains', [0 -2 -10], ...
        'NormalizePathGains', true, ...
        'DopplerSpectrum', doppler('Gaussian', 0.1));
    
    % Creating the AWGN Channel Object
    %awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SNR', SNR);
    
    % Generation of data to be transmitted
    txData = randi([0 1], numBits, 1);
    

    bpsk_mod = comm.BPSKModulator();
    % Modulate the data using BPSK
    txSig = bpsk_mod(txData);
    
    % Signal transmission through the channel
    rxSig = rainChannel(txSig);
    
    % Create a BPSK demodulator object
    bpsk_demod = comm.BPSKDemodulator();
    
    % Demodulate the received signal
    demod_sig = bpsk_demod(rxSig);
    
    % Extract the data from the demodulated signal
    rxData = de2bi(demod_sig, 'left-msb');
    
    % BER calculation
    [err, ber] = biterr(txData, rxData);
    % fprintf('Bit Error Rate (BER) = %e (SNR = %d dB)\n', ber, SNR);
    
    berVec(t) = ber; % stores the BER value in the berVec array

end
% end
%% results
% figure;
% plot(1:num, berVec);
% xlabel('Overpass index');
% ylabel('BER');
% title('Max BER per overpass');


figure(1);
stem(1:size(txSig),txSig)
title('txSig');


figure(2);
stem(1:size(rxSig),rxSig)
title('rxSig');

figure(3);
stem(1:size(txData),txData)
title('txData');


figure(4)
stem(1:size(rxData),rxData)
title('rxData')


% resuls


%intvls;
%play(sc)