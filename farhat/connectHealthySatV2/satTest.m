% satTest.m

function satTest()

        %% Variables
    SNR = 25; % in dB %CONFIGURABLE
    
    %numBits = 256*60; % number of transmitted bits
    % numBits = 40; %CONFIGURABLE
    
    numSym = 40;
    
    %SNRin = Input SNR of the system
    %SNRout = Output SNR of the system
    
    modOrd = 16; % Modulation Order %CONFIGURABLE
    dFreq = 20E9; % Downlink Frequency
    uFreq = 30E9; % Uplink Frequency
    
    %Satellite Distance from ground station
    satDist = 1325E3;
    
    %Number of times a satellite connects to a ground station
    satCon = 1; %CONFIGURABLE
    
    %Bandwidth
    B = 14E9; %CONFIGURABLE
    
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
        txData = randi([0 1], numSym * log2(modOrd), 1);
        
        
        % Modulate the data using QAM
        txSig = qammod(txData, modOrd, InputType="bit");
    
        pnoise = comm.PhaseNoise(Level=-50, FrequencyOffset=15e8, SampleRate=2*B);
        y = pnoise(txSig);
        scatterplot(txSig)
        title("Without Phase Noise")
        scatterplot(y)
        title("With Phase Noise")
    
        pInput = bandpower(txSig);
    
        %square root raised cosine filter 
    
        % Signal transmission through the rain channel
        %rxSig = rainChannel(txSig);
        
        %White Noise in the channel
        %As SNR increases noise decreases
        % awgnSig = awgn(txSig, SNR, 'measured');
    
        % Create a BPSK demodulator object
        %bpsk_demod = comm.BPSKDemodulator();
        
        %Thermal Noise for QPSK
        %therNoise_Mod = comm.ThermalNoise('NoiseTemperature',T,'SampleRate', 1/(dFreq));
    
        %Thermal Noise for both transmitter and recevier
        therNoise_Mod = comm.ThermalNoise('NoiseMethod','Noise figure', ...
        'NoiseFigure', 1.5, 'SampleRate', 2*B, 'Add290KAntennaNoise',true);
    
        therSig = therNoise_Mod(txSig);
    
    
        %Phase Noise
        %As level decreases, phase noise decreases. As frequency offset decreases, phase noise decreases. 
        %A level greater than -55dB will cause huge noise changes in the output.
    
        phNzLevel = [-36, -54, -61.5, -74, -78, -79, -80, -89, -89]; % in dBc/Hz
        phNzFreqOff = [10, 50, 100, 500, 1e3, 5e3, 10e3, 50e3, 100e3]; % in Hz
    
        % phaseNoise = comm.PhaseNoise(Level = phNzLevel, FrequencyOffset = phNzFreqOff, SampleRate=2*B); %CONFIGURABLE
    
        phaseNoise = comm.PhaseNoise(Level=-55, FrequencyOffset=14E8, SampleRate=2*B);
        phaseSig = phaseNoise(therSig);
    
        awgnSig = awgn(phaseSig, SNR, "measured");
    
        % I/Q imbalance [change made]
        amplitudeImb = 1; % amplitude imbalance in dB
        phaseImb = 5; %phase imbalance given in degrees
    
        iqImbSig = iqimbal(awgnSig, amplitudeImb, phaseImb);
    
    
        % Frequency offset [change made]
        samplerate = 1;
        offset = 100e3;
    
        freqOffSig = frequencyOffset(iqImbSig,2*B,offset);
    
        % freqOff = frequencyOffset(phaseSig,2*B,100); %CONFIGURABLE
    
        %SNR calculation
    
    
        % pFreq = bandpower(freqOffSig);
        % 
        % pNoise = pFreq-pInput;
        % 
        % snrQ = 10 * log10(pFreq/pNoise);
        % 
        % awgnSig = awgn(freqOffSig, snrQ, 'measured');
        % 
        % % Ouput = input + noise 
        % % power of output = pAwgn
        % % power of signal noise = power of output - power of input
        % 
        % pAwgn = bandpower(awgnSig);
        % 
        % pNoise1 = pAwgn - pInput;
        % 
        % snrF = 10 * log(pAwgn/pNoise1);
    
    
        % SnrTest = 10 * log(pInput/pNoise);
    
        % Demodulate the received signal
        demodSig = qamdemod(freqOffSig, modOrd, OutputType="bit");
        
        % Extract the data from the demodulated signal
        rxData = de2bi(demodSig, 'left-msb');
    
        
        % BER calculation
        [err, ber] = biterr(txData, rxData);
    
        fprintf('Bit Error Rate (BER) = %e (SNR = %d dB)\n', ber, SNR);
        
        berVec(t) = ber; % stores the BER value in the berVec array
    end
    
    %% Results
    
    mer = comm.MER;
    snrEst1 = mer(txSig,therSig);
    % scatterplot(phaseSig);
    
    %scatterplot(phaseNoise(therSig))
    
% %     tiledlayout('vertical')
% %     
% %     figure(1);
% %     nexttile
% %     stem(1:size(txData),txData)
% %     title('Input Data');
% %     
% %     nexttile
% %     figure(2);
% %     plot(1:size(txSig),txSig)
% %     title('Modulated Signal');
% %     
% %     nexttile
% %     figure(2);
% %     stem(1:size(awgnSig),awgnSig)
% %     title('Signal with White Noise');
% %     
% %     nexttile
% %     figure(3);
% %     plot(1:size(therSig),therSig)
% %     title('Signal with Thermal Noise');
% %     
% %     nexttile
% %     figure(4);
% %     plot(1:size(phaseSig),phaseSig)
% %     title('Signal with Phase Noise');
% %     
% %     nexttile
% %     figure(4);
% %     plot(1:size(demodSig),demodSig)
% %     title('Signal with Phase Noise');
% %     
% %     nexttile
% %     figure(5)
% %     stem(1:size(rxData),rxData)
% %     title('Output Data')
% %     
% %     cd = comm.ConstellationDiagram(NumInputPorts=2, ChannelNames = {'txSig', 'therSig'}, ShowReferenceConstellation=false);
% %     cd(txSig, freqOffSig);
% %     



end
