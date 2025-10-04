function visualize_tours(x,y,c0,tour,name,fbest_globalbest)
colors={'b','g','k','m','y',[0.4 0.5 0.8], 'b',[0.8429    0.9102    0.0361],[0.9865    0.8213    0.0635],[0.9876    0.4329    0.609],[ 0.0998    0.1665    0.4204],[0.8589    0.9877    0.9247],[0.7039    0.3240    0.4615],[ 0.3356    0.9167    0.7207],[  0.6415    0.3686    0.2048],[ 0.4167    0.9254    0.0378]};
figure(2);cla
scatter(x,y)
%add city labels
for i=1:length(x)
    text(x(i),y(i),num2str(i));
end
hold on;
m=length(tour);
for k=1:m
    %mark the depot in red
    scatter([x(c0(k))],[y(c0(k))],'x',"LineWidth",4,'MarkerFaceColor','r','MarkerEdgeColor','r')
    for t=1:length(tour{k})-1
        plot([x(tour{k}(t)),x(tour{k}(t+1))],[y(tour{k}(t)),y(tour{k}(t+1))],'Color',colors{k});
    end
end 
title( strrep(name, '_', '\_')+ ",   lmax=" +num2str(fbest_globalbest))
end


