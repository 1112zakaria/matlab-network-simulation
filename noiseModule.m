
function table = noiseModule()
    table = struct('somevalue', 5);
    %% Variables

    SNR = 25; % in dB %CONFIGURABLE

    %numBits = 256*60; % number of transmitted bits
    numBits = 40; %CONFIGURABLE

    %SNRin = Input SNR of the system
    %SNRout = Output SNR of the system

    modOrd = 64; % Modulation Order %CONFIGURABLE
    dFreq = 20E9; % Downlink Frequency
    uFreq = 30E9; % Uplink Frequency

    %Satellite Distance from ground station
    satDist = 1325E3;

    %Number of times a satellite connects to a ground station
    satCon = 2; %CONFIGURABLE

    %Bandwidth
    B = 2E9; %CONFIGURABLE

    %Boltzman's Constant in J/ºK
    K = 1.23E-23;

    %Temperature in Kelvin
    T = 290;

    %Noise Figure in dB
    %Ideal = 0.6 - 0.8 dB
    % F = 10*log(SNRin/SNRout);

    %Noise Power in dB
    % Pnoise = K+T+B+F;

    %Free space Path Loss in dB
    % FSPL = -147.6 + 20*log(uFreq) + 20*log(satDist);

    %Received Power
    % Prx = Ptx + Gtx - FSPL + Grx;

    %Two different methods of determining SNR
    % SNR = Prx - Pnoise;
    % SNR = 20*log(modOrd-1);

    %end
    berVec = zeros(1, 4);
    fc = 433e6; % center frequency in Hz
    fs = 866e6; % sampling frequency in Hz

    %% Noise Calc
    for t = 1:satCon  

        %WEATHER INPUT
        % Channel object creation with propagation loss caused by rain and flicker
        % rainChannel = comm.RicianChannel(...
        %     'SampleRate', fs, ...
        %     'KFactor', 1.45, ...
        %     'DirectPathDopplerShift',DirectPathDopplerShift, ...
        %     'MaximumDopplerShift', 5, ...
        %     'PathDelays', [0 1.5e-5 3.5e-5], ...
        %     'AveragePathGains', [0 -2 -10], ...
        %     'NormalizePathGains', true, ...
        %     'DopplerSpectrum', doppler('Gaussian', 0.1));
        
        % Creating the AWGN Channel Object
        %awgnChannel = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (SNR)', 'SNR', SNR);
        
        % Generation of random binary data
        txData = randi([0 1], numBits, 1);
        pInput = bandpower(txData);
        

        % Modulate the data using QAM
        txSig = qammod(txData, modOrd);
        
        %square root raised cosine filter 

        % Signal transmission through the rain channel
        %rxSig = rainChannel(txSig);
        
        %White Noise in the channel
        %As SNR increases noise decreases
        awgnSig = awgn(txSig, SNR, 'measured');

        % Create a BPSK demodulator object
        %bpsk_demod = comm.BPSKDemodulator();
        
        %Thermal Noise for QPSK
        %therNoise_Mod = comm.ThermalNoise('NoiseTemperature',T,'SampleRate', 1/(dFreq));

        %Thermal Noise for both transmitter and recevier
        therNoise_Mod = comm.ThermalNoise('NoiseMethod','Noise figure', ...
        'NoiseFigure', 30, 'SampleRate', 2*B, 'Add290KAntennaNoise',true);
        
        therSig = therNoise_Mod(awgnSig);


        %Phase Noise
        %As level decreases, phase noise decreases. As frequency offset increases phase noise decreases. 
        %A level greater than -55dB will cause huge noise changes in the output.
        phaseNoise = comm.PhaseNoise('Level',-55,'FrequencyOffset',80); %CONFIGURABLE

        phaseSig = phaseNoise(therSig);

        freqOff = frequencyOffset(phaseSig,2*B,100e3); %CONFIGURABLE

        % Demodulate the received signal
        demodSig = qamdemod(freqOff, modOrd);
        
        % Extract the data from the demodulated signal
        rxData = de2bi(demodSig, 'left-msb');
        
        % BER calculation
        [err, ber] = biterr(txData, rxData);

        % fprintf('Bit Error Rate (BER) = %e (SNR = %d dB)\n', ber, SNR);
        
        %berVec(t) = ber; % stores the BER value in the berVec array
    end

    %% Results

    %mer = comm.MER;
    %snrEst1 = mer(txSig,therSig);
    %scatterplot(phaseSig);

    %scatterplot(phaseNoise(therSig))

    tiledlayout('vertical')

    %figure(1);
    nexttile
    stem(1:size(txData),txData)
    title('Input Data');

    nexttile
    %figure(2);
    stem(1:size(txSig),txSig)
    title('Modulated Signal');
    % 
    nexttile
    %figure(2);
    stem(1:size(awgnSig),awgnSig)
    title('Signal with White Noise');

    nexttile
    %figure(3);
    stem(1:size(therSig),therSig)
    title('Signal with Thermal Noise');
    % % 
    nexttile
    %figure(4);
    stem(1:size(phaseSig),phaseSig)
    title('Signal with Phase Noise');
    % 
    nexttile
    %figure(5)
    stem(1:size(rxData),rxData)
    title('Output Data')

    outputTable = table(txData, txSig, awgnSig, therSig, phaseSig, rxData);
    writetable(outputTable, 'satTestTable.csv');

end
