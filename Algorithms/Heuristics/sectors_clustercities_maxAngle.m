function cities_cluster=sectors_clustercities_maxAngle(problem)
%% Cluster cities by angular sector with respect to the depot
% Groups cities into m clusters according to the polar angle of each city
% with respect to the depot (assumed to be city 1). The starting city for
% the circular sweep is chosen at the largest angular gap, which makes the
% partition deterministic for a given instance of the mTSP.
%
% Steps:
% 1) Compute the angles of all cities with respect to the depot using (x, y) coordinates.
% 2) Sort cities by angle.
% 3) Identify the largest angular jump and start the sweep there to create
%    m contiguous angular sectors with approximately n/m cities each.

% Initialization
dist=problem.dist;
m=length(problem.c0); % number of clusters = number of travelers
visualize_cluster=1;% set to 0 to disable plotting
nCities = size(dist, 1);  % total number of cities
colores={'b','g','k','m','y',[0.4 0.5 0.8], 'b',[0.8429    0.9102    0.0361],[0.9865    0.8213    0.0635],[0.9876    0.4329    0.609],[ 0.0998    0.1665    0.4204],[0.8589    0.9877    0.9247],[0.7039    0.3240    0.4615],[ 0.3356    0.9167    0.7207],[  0.6415    0.3686    0.2048],[ 0.4167    0.9254    0.0378]};

anglesCities=zeros(1,nCities); % polar angles (in degrees) of all cities
cities_cluster=cell(m,1);% output clusters (indices of cities)

% Compute the angle of each city with respect to the depot (city 1)
for i=1:nCities
    anglesCities(i)=rad2deg(atan2((problem.y(i)-problem.y(1)),(problem.x(i)-problem.x(1))));
end

[angles_sort,indexs]=sort(anglesCities);

% Base number of cities per traveler and remainder
n_per_agent = floor(nCities / m);
remaining_cities = nCities - n_per_agent * m;


% Find the largest circular angular gap and start the partition after it
angle_diffs = diff([angles_sort, angles_sort(1) + 360]);
[~,cityrnd]=max(angle_diffs);
cityrnd=cityrnd+1;

% Build m contiguous angular sectors
for k = 1:m
    if k < m
        cities_for_this_agent = n_per_agent;
    else
        cities_for_this_agent = n_per_agent + remaining_cities;
    end
    start_idx = mod(cityrnd - 1 + (k- 1) * n_per_agent, nCities) + 1;
    end_idx = mod(start_idx - 1 + cities_for_this_agent - 1, nCities) + 1;

    if start_idx <= end_idx
        cities_cluster{k} =  indexs(start_idx:end_idx);
    else
        cities_cluster{k} = [indexs(start_idx:nCities), indexs(1:end_idx)];
    end
end

% Ensure the depot (city 1) is included in every cluster
for k=1:m
    if sum(cities_cluster{k}==1)==0
        cities_cluster{k}(end+1)=1;
    end
end

if visualize_cluster
    xmin=min(problem.x);xmax=max(problem.x);
    ymin=min(problem.y);ymax=max(problem.y);
    figure(1);cla
    scatter(problem.x(1),problem.y(1),'MarkerFaceColor','r','MarkerEdgeColor','r');
    hold on
    for k=1:m
        scatter(problem.x(cities_cluster{k}),problem.y(cities_cluster{k}),'MarkerEdgeColor',colores{k});
    end
    axis([xmin xmax ymin ymax])
end
end