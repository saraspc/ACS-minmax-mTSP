function [tour,improved]=two_opt(tour,dist)
% 2-opt is a local improvement heuristic used in TSP to optimize an initial
% solution (route) by swapping pairs of edges.
% This approach is simple yet very effective and progressively improves a
% route until a local optimum is reached.
% For every pair of non-consecutive edges in the route, it checks whether
% swapping them reduces the total tour length.
% If reversing the segment (the 2-opt move) improves the route, the current
% solution is updated with the new route.
% If it does not improve, the change is discarded and other edge pairs are evaluated.
improved=0;
improved_it=1; % improvement in the last iteration
while improved_it % keep iterating while there is improvement
    [tour,improved_it]=two_opt_iteration(tour,dist);
    if improved_it
        improved=1; % at least one iteration improved the tour
    end
end
end
%

% without neighbor list or radius
function [tour,improved]=two_opt_iteration(tour,dist)
improved=0;
n=length(tour);
for i=1:n-3
    for j=i+2:n-1
        % old edges
        % edge1 = [tour(i) tour(i+1)]
        % edge2 = [tour(j) tour(j+1)]
        lenEdges=dist(tour(i), tour(i+1))+dist(tour(j), tour(j+1));
        % the two new edges
        % new1 = [tour(i) tour(j)]
        % new2 = [tour(i+1) tour(j+1)]
        lenEdgesSwap=dist(tour(i),tour(j))+dist(tour(i+1),tour(j+1));

        % tourswap = [ tour(1:i) flip(tour(i+1:j)) tour(j+1:end)];
        % ltourtourswap = tour_length(tourswap,dist)

        % compare the length of the new and old edges
        if lenEdgesSwap<lenEdges
            % construct the tour with the swap
            try
            tour=[ tour(1:i)  flip(tour(i+1:j))  tour(j+1:end)]; % removed ';' compared to the previous code
            catch
                keyboard;
            end
            improved=1;
            return
        end
    end
end
end
