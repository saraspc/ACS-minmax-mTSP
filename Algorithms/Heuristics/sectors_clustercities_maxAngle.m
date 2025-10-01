function cities_cluster=sectors_clustercities_maxAngle(problem)
%%  clusters cities according to the angle between the cities and the depot (located city 1)
% Agrupa las ciudades en clusters según el ángulo entre cada ciudad y el depot (ubicado en la ciudad 1).
% 
% Descripción:
% 1. Calcula los ángulos de todas las ciudades respecto al depot usando las coordenadas (x, y).
% 2. Ordena las ciudades en función de sus ángulos respecto al depot.
% 3. Selecciona una ciudad inicial aquella donde el salto de angulo es
% mayor. Por tanto siempre devuelve misma particion para un problema mTSP
%

% Inicialización
dist=problem.dist;
m=length(problem.c0);%numero clusters=numero viajantes
visualize_cluster=1;
nCities = size(dist, 1);  % Número de ciudades
colores={'b','g','k','m','y',[0.4 0.5 0.8], 'b',[0.8429    0.9102    0.0361],[0.9865    0.8213    0.0635],[0.9876    0.4329    0.609],[ 0.0998    0.1665    0.4204],[0.8589    0.9877    0.9247],[0.7039    0.3240    0.4615],[ 0.3356    0.9167    0.7207],[  0.6415    0.3686    0.2048],[ 0.4167    0.9254    0.0378]};

anglesCisties=zeros(1,nCities);
cities_cluster=cell(m,1);
%cluster_angles=cell(m,1)%solo para analisis


if visualize_cluster
    xmin=min(problem.x);xmax=max(problem.x);
    ymin=min(problem.y);ymax=max(problem.y);
end

% calculate angles from cities to depot (city 1)
for i=1:nCities
    anglesCisties(i)=rad2deg(atan2((problem.y(i)-problem.y(1)),(problem.x(i)-problem.x(1))));
end

[angles_sort,indexs]=sort(anglesCisties);

%!cityrnd=randi(nCities,1,1)
n_per_agent = floor(nCities / m);  % Ciudades por viajante
remaining_cities = nCities - n_per_agent * m;  % Ciudades restantes para el último viajante


% Calcular las diferencias entre ángulos consecutivos
angle_diffs = diff([angles_sort, angles_sort(1) + 360]); % Añade 360 al final para cálculo circular
[valangle,cityrnd]=max(angle_diffs)
cityrnd=cityrnd+1
% large_jump_index = find(angle_diffs > limitangle, 1)+1;  % Tomar el primer salto mayor a 180 grados, si existe
% % Paso 3: Selección del punto de inicio como el de mayor salto
% if ~isempty(large_jump_index)
%     % Si hay un salto mayor a 180 grados, usar ese punto como inicio
%     cityrnd = large_jump_index;
% else
%     % Si no, selecciona un punto de inicio aleatorio
%     cityrnd = randi(nCities);
% end
%cityrnd = randi(nCities)

for k = 1:m

    if k < m
        % Para los primeros m-1 viajantes, asignar el número base de ciudades
        cities_for_this_agent = n_per_agent;
    else
        % Para el último viajante, asignar el número base más las ciudades restantes
        cities_for_this_agent = n_per_agent + remaining_cities;
    end
    % Índices de las ciudades para el viajante k

    start_idx = mod(cityrnd - 1 + (k- 1) * n_per_agent, nCities) + 1;
    end_idx = mod(start_idx - 1 + cities_for_this_agent - 1, nCities) + 1;


    if start_idx <= end_idx
        cities_cluster{k} =  indexs(start_idx:end_idx);
        cluster_angles{k}=angles_sort(start_idx:end_idx);
    else
        cities_cluster{k} = [indexs(start_idx:nCities), indexs(1:end_idx)];
        cluster_angles{k} = [angles_sort(start_idx:nCities), angles_sort(1:end_idx)];
    end
end

for k=1:m
    if sum(cities_cluster{k}==1)==0
cities_cluster{k}(end+1)=1
    end
end

if 1
    figure(1);cla
    h=scatter(problem.x(1),problem.y(1),'MarkerFaceColor','r');
    hold on
    for k=1:m
        scatter(problem.x(cities_cluster{k}),problem.y(cities_cluster{k}),'Color',colores{k});
    end
    axis([xmin xmax ymin ymax])
end
end