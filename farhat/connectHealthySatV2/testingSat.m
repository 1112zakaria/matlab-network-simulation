close all;

startTime = datetime(2023,10,21,1,13,0);
stopTime = startTime + hours(5);
sampleTime = 60;
sc = satelliteScenario(startTime,stopTime,sampleTime);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Satellite 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
semiMajorAxis = 10000000;                                                                  % meters
eccentricity = 0;
inclination = 60;                                                                          % degrees
rightAscensionOfAscendingNode = 0;                                                         % degrees
argumentOfPeriapsis = 0;                                                                   % degrees
trueAnomaly = 0;                                                                           % degrees
sat1 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis,trueAnomaly,Name="Satelitte 1");

gimbalrxSat1 = gimbal(sat1);
gimbaltxSat1 = gimbal(sat1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Satellite 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
semiMajorAxis = 10000000;                                                                   % meters
eccentricity = 0;
inclination = 60;                                                                           % degrees
rightAscensionOfAscendingNode = 0;                                                          % degrees
argumentOfPeriapsis = 0;                                                                    % degrees
trueAnomaly = -55;                                                                            % degrees
sat2 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis,trueAnomaly,Name="Satelitte 2");

gimbalrxSat2 = gimbal(sat2);
gimbaltxSat2 = gimbal(sat2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Satellite 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
semiMajorAxis = 10000000;                                                                  % meters
eccentricity = 0;
inclination = 60;                                                                          % degrees
rightAscensionOfAscendingNode = 0;                                                         % degrees
argumentOfPeriapsis = 0;                                                                   % degrees
trueAnomaly = -110;                                                                           % degrees
sat3 = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis,trueAnomaly,Name="Satelitte 3");

gimbalrxSat3 = gimbal(sat3);
gimbaltxSat3 = gimbal(sat3);

%%%%%%%%%%%%%%%%%%%%%%%%%%% Receving antennas of satellites %%%%%%%%%%%%%%%%
gainToNoiseTemperatureRatio = 5;                                                        % dB/K
systemLoss = 3;                                                                         % dB
rxSat1 = receiver(gimbalrxSat1,Name="Satellite 1 Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);
rxSat2 = receiver(gimbalrxSat1,Name="Satellite 2 Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);
rxSat3 = receiver(gimbalrxSat1,Name="Satellite 3 Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);

%%%%%%%%%%%%%%%%%%%%%%%%%%% transmitting antennas of satellites %%%%%%%%%%%%%%%%
frequency = 27e9;                                                                     % Hz
power = 20;                                                                           % dBW
bitRate = 20;                                                                         % Mbps
systemLoss = 3;                                                                       % dB
txSat1 = transmitter(gimbaltxSat1,Name="Satellite 1 Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);
txSat2 = transmitter(gimbaltxSat1,Name="Satellite 2 Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);
txSat3 = transmitter(gimbaltxSat1,Name="Satellite 3 Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% transmit and receive antenna properties %%%%%%%%
dishDiameter = 0.5;                                                                    % meters
apertureEfficiency = 0.5;
gaussianAntenna(txSat1,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(rxSat1,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(txSat2,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(rxSat2,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(txSat3,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(rxSat3,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% ground stations %%%%%%%%%%%%%%%%%%%%%%%%
gs1 = groundStation(sc,Name="Ground Station 1");

latitude = 52.2294963;                                              % degrees
longitude = 0.1487094;                                              % degrees
gs2 = groundStation(sc,latitude,longitude,Name="Ground Station 2");

gimbalgs1 = gimbal(gs1);
gimbalgs2 = gimbal(gs2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% transmitting antenna of GS1 %%%%%%%%%%%%%%%%
frequency = 30e9;                                                                          % Hz
power = 40;                                                                                % dBW
bitRate = 20;                                                                              % Mbps
txGs1 = transmitter(gimbalgs1,Name="Ground Station 1 Transmitter",Frequency=frequency, ...
        Power=power,BitRate=bitRate);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% receiving antenna of GS2 %%%%%%%%%%%%%%%%
requiredEbNo = 14;                                                                     % dB
rxGs2 = receiver(gimbalgs2,Name="Ground Station 2 Receiver",RequiredEbNo=requiredEbNo);


%%%%%%%%%%%%%%% transmit and receive antennas properties of GSs %%%%%%%%%%%%%%%%
dishDiameter = 5;                                % meters
gaussianAntenna(txGs1,DishDiameter=dishDiameter);
gaussianAntenna(rxGs2,DishDiameter=dishDiameter);

%%%%%%%%%%%%%%%%%%%%%%%%% antenna pointings %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pointAt(gimbalgs1,sat1);
pointAt(gimbalrxSat1,gs1);
pointAt(gimbaltxSat1,sat2); %%%% why do we need this??? Sat 3 pointAts are fine
pointAt(gimbalrxSat2,sat1); %%%% why do we need this??? Sat 3 pointAts are fine
pointAt(gimbaltxSat2,gs2);
pointAt(gimbalgs2,sat2);

pointAt(gimbalgs1, sat3); % Aim Ground Station 1 towards Satellite 3
pointAt(gimbalrxSat3, gs1); % Aim Satellite 3's receiver towards Ground Station 1
pointAt(gimbaltxSat3, gs2); % Aim Satellite 3's transmitter towards Ground Station 2
pointAt(gimbalgs2, sat3); % Aim Ground Station 2 towards Satellite 3

%%%%%%%%%%%%%%%%%%%%% Getting best satellites from middleman %%%%%%%%%%%%%%%%
% Set the desired number of satellites 
% (assume its 1 for now since other one is already in the array)
numSat = 3;

bestSats= middleMan(numSat);
satellites = cell(1, numel(bestSats)); % Convert to row array

% Get best satellite names
for i = 1:numel(bestSats)
    satellites{i} = ['sat' num2str(bestSats(i))];
end
bestSatsName = cellfun(@(x) evalin('base', x), satellites);
disp(bestSatsName);

s = bestSatsName;     % list of all good weather satellites

%%%%%%%%%%%%%%%%%% Link assigning to GSs and Satellites %%%%%%%%%%%%%%%%
ac = access(gs1, s, gs2); 
acinterval = accessIntervals(ac);
linkNumber = size(acinterval, 1);


%%%%%%%% Getting start and end times for each satellite GSs links %%%%%%%%%
for i = 1:linkNumber

    % Extract the times from the ith row of the table
    startTimes = acinterval.StartTime(i);
    endTimes = acinterval.EndTime(i);

    fprintf('Running satTest.m for link %d:\n', i);
    fprintf('Start Time: %s\n', startTimes);
    fprintf('End Time: %s\n', endTimes);

end


%%%%%%%%%%%% Calling link code as many times as satellites available %%%%%
for i = 1:numel(s)
    % Call the MATLAB file "satTest.m"
    satTest();
end

%%%%%%%%%%%%%%%%%%%%%%%%%% Earth graphics %%%%%%%%%%%%%%%%%%%%%%%%%%%%
play(sc);


