clear all;
close all;

startTime = datetime(2023,10,21,1,13,0);
endTime = startTime + hours(5);
sampleTime = 60;
sc = satelliteScenario(startTime,endTime,sampleTime);

%sat = satellite(sc,"threeSatelliteConstellation.tle");

%show(sat)
%groundTrack(sat,"LeadTime",1200);

semiMajorAxis = 10000000;                                                                  % meters
eccentricity = 0;
inclination = 60;                                                                          % degrees
rightAscensionOfAscendingNode = 0;                                                         % degrees
argumentOfPeriapsis = 0;                                                                   % degrees
trueAnomaly = 0;                                                                           % degrees
sat = satellite(sc,semiMajorAxis,eccentricity,inclination,rightAscensionOfAscendingNode, ...
    argumentOfPeriapsis,trueAnomaly,Name="Sat_1");

gimbalrxSat = gimbal(sat);
gimbaltxSat = gimbal(sat);
%gimCam = gimbal(sat);

gainToNoiseTemperatureRatio = 5;                                                        % dB/K
systemLoss = 3;                                                                         % dB
rxSat = receiver(gimbalrxSat,Name="Satellite Receiver",GainToNoiseTemperatureRatio= ...
    gainToNoiseTemperatureRatio,SystemLoss=systemLoss);

frequency = 27e9;                                                                     % Hz
power = 20;                                                                           % dBW
bitRate = 20;                                                                         % Mbps
systemLoss = 3;                                                                       % dB
txSat = transmitter(gimbaltxSat,Name="Satellite Transmitter",Frequency=frequency, ...
    power=power,BitRate=bitRate,SystemLoss=systemLoss);

dishDiameter = 0.5;                                                                    % meters
apertureEfficiency = 0.5;
gaussianAntenna(txSat,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);
gaussianAntenna(rxSat,DishDiameter=dishDiameter,ApertureEfficiency=apertureEfficiency);


gs1 = groundStation(sc,Name="Ground Station 1");
latitude = 52.2294963;                                              % degrees
longitude = 0.1487094;                                              % degrees
gs2 = groundStation(sc,latitude,longitude,Name="Ground Station 2");


pointAt(gimbaltxSat,gs2);
pointAt(gimbalrxSat,gs1);


gimbalgs1 = gimbal(gs1);
gimbalgs2 = gimbal(gs2);

frequency = 30e9;                                                                          % Hz
power = 40;                                                                                % dBW
bitRate = 20;                                                                              % Mbps
txGs1 = transmitter(gimbalgs1,Name="Ground Station 1 Transmitter",Frequency=frequency, ...
        Power=power,BitRate=bitRate);

requiredEbNo = 14;                                                                     % dB
rxGs2 = receiver(gimbalgs2,Name="Ground Station 2 Receiver",RequiredEbNo=requiredEbNo);

dishDiameter = 5;                                % meters
gaussianAntenna(txGs1,DishDiameter=dishDiameter);
gaussianAntenna(rxGs2,DishDiameter=dishDiameter);

pointAt(gimbalgs1,sat);
pointAt(gimbalgs2,sat);

lnk = link(txGs1,rxSat,txSat,rxGs2);

a = linkIntervals(lnk);
b = a(2,"Duration");

% intvls = accessIntervals(a);

play(sc);


% Start and end time in single rows
firstRow = table2array(a(1, 4:5));
secondRow = table2array(a(2, 4:5));

% Separating start and end times
startTime1 = firstRow(1);
endTime1 = firstRow(2);
startTime2 = secondRow(1);
endTime2 = secondRow(2);

% Show the results
disp('Start time 1:');
disp(startTime1);

disp('end time 1:');
disp(endTime1);

disp('Start time 2:');
disp(startTime2);

disp('end time 2:');
disp(endTime2);

linkNumber = size(a, 1);

for i = 1:linkNumber

    % Extract the times from the ith row of the table
    startTimes = a.StartTime(i);
    endTimes = a.EndTime(i);

    fprintf('Running satTest.m for link %d:\n', i);
    fprintf('Start Time: %s\n', startTimes);
    fprintf('End Time: %s\n', endTimes);

    % Call the MATLAB file "satTest.m"
    satTest();

end

