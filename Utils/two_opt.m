function [tour,improved]=two_opt(tour,dist)
%2-opt es una heurística de mejora local utilizada en problemas TSP para optimizar una solución inicial (ruta) intercambiando pares de aristas.
% Este enfoque es sencillo pero muy efectivo y mejora progresivamente una ruta hasta alcanzar un óptimo local.
%Para cada par de aristas no consecutivas en la ruta, se evalúa si intercambiarlas reduce la longitud total de la ruta.
%Si la inversión del segmento (conocida como una operación 2-opt) mejora la ruta, se actualiza la solución actual con la nueva ruta.
%Si no mejora, se descarta el cambio y se sigue evaluando otros pares de aristas.
improved=0;
improved_it=1;%improvement in last iteration
while improved_it %mientras se mejore sigue
    [tour,improved_it]=two_opt_iteration(tour,dist);
    if improved_it
        improved=1;%at least in one iteration the tour improved
    end
end
end
%

%sin neighborlist ni radius
function [tour,improved]=two_opt_iteration(tour,dist)
improved=0;
n=length(tour);
for i=1:n-3
    for j=i+2:n-1
        %old new edgest
        %edge1=[tour(i) tour(i+1)]
        %edge2=[tour(j) tour(j+1)]
        lenEdges=dist(tour(i), tour(i+1))+dist(tour(j), tour(j+1));
        %the two new edges
        %new1=[tour(i) tour(j) ]
        %new2=[tour(i+1) tour(j+1) ]
        lenEdgesSwap=dist(tour(i),tour(j))+dist(tour(i+1),tour(j+1));

        % tourswap=[ tour(1:i) flip(tour(i+1:j)) tour(j+1:end)];
        % ltourtourswap=tour_length(tourswap,dist)

        %compare the length of the new and old edges
        if lenEdgesSwap<lenEdges
            %contruct the tour with the swap
            try
            tour=[ tour(1:i)  flip(tour(i+1:j))  tour(j+1:end)];%he quitado ; respecto al codigo anterior
            catch
                keyboard;
            end
            improved=1;
            return
        end
    end
end
end
