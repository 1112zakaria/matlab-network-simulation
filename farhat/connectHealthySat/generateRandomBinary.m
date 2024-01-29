function result = generateRandomBinary()
    % Generate a random number between 0 and 1
    random_number = rand();
    
    % Round the random number to either 0 or 1
    result = round(random_number);


    % HERE NEED LOGICS IN PLACE TO CHECK WHETHER THE LINK FROM testingSat.m
    % is healthy or not. If not healthy, abandon that satellite.
end
