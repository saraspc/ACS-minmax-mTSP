clear all; close all

addpath(pwd+"\TSP_instances")
addpath(pwd+"\Algorithms")
addpath(pwd+"\Algorithms\Heuristics")
addpath(pwd+"\Utils")

ACOparam.alpha=1;ACOparam.beta=2;
ACOparam.rho=[0.9]

%folder to save the results
folder="ResultsMinMax\"

%select a TSP instance from TSP_instances folder
instance="berlin52"

%number of travellers
m=3

%stopping criteria
maxtime=Inf;
ntours=100000

%number of simulations
NR=20

%if mrandom=0 traveler with shortest subtour is selected, if 1 random traveler is selected
ACOparam.mrandom=0;
ACOparam.clustercities=1;
ACOparam.cluster_influence=15;
ACOparam.cluster_method="sectors_maxAngle";%
ACOparam.twoopt=1;%wheteher 2-opt heurisitic is applied or not
for nr=1:NR
        namefile=folder+instance+"m"+string(m)+"_ACS_"+num2str(nr)+".mat"
        namefig=folder+instance+"m"+string(m)+"_ACS_"+num2str(nr)+".jpeg"
        if exist(namefile)~=2
            problem=load(instance+".mat")
            problem.c0=[ones(1,m)]% city 1 is selected as depot
            maxIter=round(ntours)/10%10 ants for ACS
            Solution=ACSminmaxTSP_cluster(problem,ACOparam,maxtime,maxIter)
            save(namefile,'Solution')
            figure(3);print(namefig,'-djpeg');
    end
end


