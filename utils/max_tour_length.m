function max_ltour = max_tour_length(tour, dist)
    % Initialize the maximum tour length to 0
    max_ltour = 0;
    m = length(tour);  % Number of travelers
    
    % Iterate over each traveler
    for k = 1:m
        % Compute the length of traveler k's tour
        nk = length(tour{k});
        ltour_k = 0;  % Total length for traveler k
        for t = 1:nk-1
            ltour_k = ltour_k + dist(tour{k}(t), tour{k}(t+1));
        end
        
        % Update the maximum length if the current tour is longer
        if ltour_k > max_ltour
            max_ltour = ltour_k;
        end
    end
end
