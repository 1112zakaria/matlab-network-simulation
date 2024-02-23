function result = middleMan(numSat)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Empty array to store the results
    dataFromGetPredic = [];

    % Loop numSat value times
    for i = 1:numSat
        
        result = getPredicVal();

        % Append the result to above array
        dataFromGetPredic = [dataFromGetPredic; result];
    end    
    disp('predicVal - middle man based on numSat: ');
    disp(dataFromGetPredic);

    % Below I hardcoded the values and put in "data" variable. 
    % Use "dataFromGetPredic" once that predic function gives different values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%% replace below snippet with above snippet code %%%%%%%%

    sat1 = [-10.45, 45.1, 10, 1.57, 99.38];
    sat2 = [-5.66, 52.13, 3, 4.39, 99.71];
    sat3 = getPredicVal();
    sat4 = [-18.71, 47.65, 5, 2.59, 99.50];
    sat5 = [-11.0861, 44.16, 9, 1.20, 99.33];

    %data = [sat1; sat2; sat3; sat4; sat5];
    data = [sat1; sat2; sat3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    disp('hardcodeVal - middle man: ');
    disp(data);
    temp_range = [-40, 80]; % Optimal temperature range in degrees Celsius
    humidity_range = [20, 80]; % Optimal humidity range in percentage
    precipitation_range = [1, 5]; % Optimal precipitation range in mm
    windspeed_range = [20, 50]; % Optimal wind speed range in km/hr

    scores = zeros(size(data, 1), 1);
    for i = 1:size(data, 1)
        % Temperature score
        if data(i, 1) >= temp_range(1) && data(i, 1) <= temp_range(2)
            temp_score = 100; % Score of 100 if within optimal temperature range
        else
            temp_score = 0; % 0 score outside optimal range
        end
        
        % Humidity score
        if data(i, 2) >= humidity_range(1) && data(i, 2) <= humidity_range(2)
            humidity_score = 100 - data(i, 2); % Better scores for lower humidity
        else
            humidity_score = 0; % 0 score outside optimal range
        end
        
        % Precipitation score
        if data(i, 3) >= precipitation_range(1) && data(i, 3) <= precipitation_range(2)
            precip_score = 1 / (data(i, 3) + 1); % Better scores for lower precipitation
        else
            precip_score = 0; % 0 score outside optimal range
        end
        
        % Wind speed score
        if data(i, 4) >= windspeed_range(1) && data(i, 4) <= windspeed_range(2)
            wind_score = 1 / (data(i, 4) + 1); % Better scores for lower wind speed
        else
            wind_score = 0; % 0 score outside optimal range
        end
        
        % Calculate total score for each satellite (no station pressure)
        scores(i) = temp_score + humidity_score + precip_score + wind_score;
    end

    % Sort the satellites number based on their weather scores
    [sorted_scores, idx] = sort(scores, 'descend');
    
    % Select the best 2 satellites
    top_2_satellites = idx(1:2);
    
    disp("Best 2 satellites are (from middle man):")
    disp(top_2_satellites)
    
    disp(['numSat from middleMan: ', num2str(numSat)]);
    result = top_2_satellites;

end
