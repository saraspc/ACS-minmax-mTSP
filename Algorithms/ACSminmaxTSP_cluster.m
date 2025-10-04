function [Solution]=ACSminmaxTSP_cluster(problem,ACOparam,maxtime,maxIter)
% This function implements the proposed ACS-based algorithm for the
% min-max multiple traveling salesman problem (mTSP). The probability
% transition rule is modified to incorporate cluster information, giving
% higher priority to cities that belong to the cluster of the current traveler.
%
% INPUT:
%   problem   - Structure with the problem data:
%                  .dist   : [n x n] distance matrix between cities
%                  .name   : string with the instance name (e.g., 'berlin52')
%                  .x      : 2D Euclidean x-coordinates of the cities
%                  .y      : 2D Euclidean y-coordinates of the cities
%                  .c0     : depot of the travellers (city 1 as default)
%   ACOparam  - Structure with the ACS parameters (number of ants, alpha,
%               beta, rho, q0, etc.)
%   maxtime   - Maximum computation time (in seconds)
%   maxIter   - Maximum number of iterations
%
% OUTPUT:
%   Solution  - Best solution found, including assignment of cities to
%               travelers and corresponding tour lengths


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%INITIALIZATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dist=problem.dist;
%1s in the diagonal
dist(find(eye(size(dist)))) = 1;

%city coordinates (only used for graphical representation)
x=problem.x;
y=problem.y;
symmetric=issymmetric(dist);
ncities=length(dist);
%number of travellers
m=length(problem.c0);

% parameter settings
a=ACOparam.alpha;
b=ACOparam.beta;
Nants=10;
rho=ACOparam.rho;
q0=0.9;
cluster_influence=ACOparam.cluster_influence;%if 0 cluster influence is desactivated

tiempo=0;  it=0;
itglobalBest=0;%iteration at which the global best solution is found
fbest_globalbest=realmax;%fitness of the global best solution

%construct a tour to know Cnn length of a heuristic tour to initialize the pheromones
if strcmp(ACOparam.cluster_method,"sectors_maxAngle")%determinista
    tour=NN_sectors_maxAngle(problem);
end
ltour=max_tour_length(tour,dist);

%initialized pheromones between cities
phmone=ones(ncities,ncities);
phmone0=1/(ncities*ltour);
phmone=phmone0*phmone;

if ~isinf(maxIter);fbest_globalbest_iterations=zeros(1,maxIter);end

if strcmp(ACOparam.cluster_method,"sectors_maxAngle")
    cities_cluster=sectors_clustercities_maxAngle(problem)
end

heur=(1./dist);%TSP heuristic
heur(isinf(heur))=1;%  replace Inf values (zero distances on the diagonal) by 1

while tiempo<maxtime & it<maxIter

    tic1=tic;
    it=it+1;

    %% Generate tours
    tours=cell(Nants,1);
    ltours=zeros(m,Nants);%evaluate fitness while constructing

    %set initial city
    for i=1:Nants
        for k=1:m
            tours{i}{k}=[problem.c0(k)];
        end
    end

    ticcloop=tic;
    for ant=1:Nants
        tour=tours{ant};
        visited=zeros(1,ncities);
        visited([tours{ant}{:}])=1;
        n_visited=1;
        while n_visited<ncities
            %select traveller to choose next move
            if ACOparam.mrandom
                k=randi(m,1);
            else %select the traveller with shorest subtour
                ltours_ant=ltours(:,ant);
                ltours_ant(ltours_ant==0)=1;%avoid dividing by 0
                [~,k]=min(ltours_ant);
            end
            i=tour{k}(end);

            if ACOparam.clustercities
                cluster_k=ones(1,ncities);
                cluster_k(cities_cluster{k})=cluster_influence;
                prob=(phmone(i,:).^a).*(heur(i,:)).^b.*cluster_k;
            else
                prob=(phmone(i,:).^a).*(heur(i,:)).^b;
            end

            %zero probability to visited cities
            prob(logical(visited))=0;
            %pesudorandom ACS proportional rule
            if rand<q0 %q0 ACS parameter, the choice with max prob is taken
                [~,posmax]=max(prob);
                prob=zeros(1,length(prob));
                prob(posmax)=1;
            end

            prob=prob./sum(prob);

            %sample
            rnum=rand;
            acup = cumsum(prob);
            %next candidate city j
            j = find(acup >=rnum, 1);

            %ACS local pheromone update rule
            phmone(i,j)=phmone(i,j)*(1-0.1) +0.1*phmone0;
            if symmetric; phmone(j,i)= phmone(i,j); end

            %add city j to subtour of k-th traveller
            tour{k}(end+1)=j;
            visited(j)=1;
            n_visited=n_visited+1;
            %eval subtours' length while constructing
            ltours(k,ant)=ltours(k,ant)+dist(tour{k}(end-1), tour{k}(end));
        end

        %close the subtours
        for k=1:m
            tour{k}(end+1)= tour{k}(1);
            ltours(k,ant)=ltours(k,ant)+dist(tour{k}(end-1), tour{k}(end));%eval return to depot
        end
        tours{ant}=tour;
    end
    toc(ticcloop)

    %% evaluate fitness
    lmaxtours=max(ltours);
    [lmaxtours_sorted,order]=sort(lmaxtours);
    fbestit=lmaxtours_sorted(1);
    ind=order(1);
    bestTourit=tours{ind};

    if fbestit<fbest_globalbest% se ha mejorado la mejor solucion encontrada (considerando desde it=1)
        fbest_globalbest=fbestit;
        bestTour_globalbest=bestTourit;
        itglobalBest=it;
    end

    %% local search heuristic (applied to the subtours of each traveller individually)
    if ACOparam.twoopt
        for k=1:m
            [bestTour_globalbest{k}]=two_opt(bestTour_globalbest{k},dist);
        end
        %update fitness
        fbest_globalbest=max_tour_length(bestTour_globalbest,dist);
    end

    %% ACS pheromone update
    for k=1:m
        for t=1:length(bestTour_globalbest{k})-1
            phmone(bestTour_globalbest{k}(t),bestTour_globalbest{k}(t+1))=rho*phmone(bestTour_globalbest{k}(t),bestTour_globalbest{k}(t+1))+(1-rho)/fbest_globalbest;
            if symmetric; phmone(bestTour_globalbest{k}(t+1),bestTour_globalbest{k}(t))=phmone(bestTour_globalbest{k}(t),bestTour_globalbest{k}(t+1)); end
        end
    end

    fbest_globalbest_iterations(it)=fbest_globalbest;
    tiempo=tiempo+toc(tic1);

    time(it)=tiempo;
    disp(sprintf('ACS mTPS: %s m=%d Iteration:%d/%d time %f/%f,  fbest_globalbest=%d, itglobalBest=%d',problem.name,m,it,maxIter,tiempo,maxtime,fbest_globalbest,itglobalBest));


end
Solution.fbest_globalbest_iterations=fbest_globalbest_iterations;
Solution.time=time;
Solution.itglobalBest=itglobalBest;
Solution.Nants=Nants;
Solution.bestTour_globalbest=bestTour_globalbest;

if ~isempty(x)
    figure(3)
    visualize_tours(x,y,problem.c0,bestTour_globalbest,problem.name,fbest_globalbest)
end

end





