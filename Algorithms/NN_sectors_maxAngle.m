function [tour] = NN_sectors(problem)
% realiza partición de las ciudades  segun sectores (angulos), y
% luego utiliza NN para cada viajante

%% partición segun 
cities_centroid=sectors_clustercities_maxAngle(problem);

%% Implementación NN para cada viajante
c0=problem.c0;
m=length(c0);%number of travellers
dist=problem.dist;

n=size(dist,1);

for k=1:m
    cities_travelerk=cities_centroid{k};
    ncities_viajantek=length(cities_travelerk);

    tour{k}=[c0(k)];

    visited=ones(1,n);%quitamos las que no estan asignadas al agente
    visited(cities_travelerk)=0;%ponemos a 0 las que tiene q visitar agente k
    visited(c0(k))=1;% la depot  si que esta visitada
    while sum(visited)<n
        i=tour{k}(end);
        p=1./dist(i,:);
        p(isinf(p))=1;%!
        p(logical(visited))=0;
        [val,j]=max(p);
        visited(j)=1;
        tour{k}(end+1)=j;
    end
    %close the tour
    tour{k}(end+1)=c0(k);
end
ltour=max_tour_length(tour,problem.dist)
if 1
 visualize_tours(problem.x,problem.y,problem.c0,tour,problem.name,ltour)
end
end

function visualize_tours(x,y,c0,tour,name,fbest_globalbest)
colors={[0 0 1],[0 1 0],[1 0.5 0.5],'m','k','y',[0.4 0.5 0.8], 'b',[0.8429    0.9102    0.0361],[0.9865    0.8213    0.0635],[0.9876    0.4329    0.609],[ 0.0998    0.1665    0.4204],[0.8589    0.9877    0.9247],[0.7039    0.3240    0.4615],[ 0.3356    0.9167    0.7207],[  0.6415    0.3686    0.2048],[ 0.4167    0.9254    0.0378]};
figure(2);cla
scatter(x,y)
%añadimos labels de cada ciudad
for i=1:length(x)
    text(x(i),y(i),num2str(i));
end
hold on;
m=length(tour);
for k=1:m
    %mark the depots in red
    scatter([x(c0(k))],[y(c0(k))],'x',"LineWidth",4,'MarkerFaceColor','r')
    for t=1:length(tour{k})-1
        plot([x(tour{k}(t)),x(tour{k}(t+1))],[y(tour{k}(t)),y(tour{k}(t+1))],'Color',colors{k});
    end
end
title( strrep(name, '_', '\_')+ ",   l=" +num2str(fbest_globalbest))
end


