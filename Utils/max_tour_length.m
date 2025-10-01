function max_ltour = max_tour_length(tour, dist)
    % Inicializa la distancia máxima a 0
    max_ltour = 0;
    m = length(tour);  % Número de viajantes
    
    % Recorre cada viajante
    for k = 1:m
        % Calcula la distancia de la ruta del viajante k
        nk = length(tour{k});
        ltour_k = 0;  % Distancia total para el viajante k
        for t = 1:nk-1
            ltour_k = ltour_k + dist(tour{k}(t), tour{k}(t+1));
        end
        
        % Actualiza la distancia máxima si la ruta actual es mayor
        if ltour_k > max_ltour
            max_ltour = ltour_k;
        end
    end
end