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
m=2

%stopping criteria
maxtime=Inf;
ntours=100800 %250000 fue primer submit, pero como ponia corte en 100000 en el paper decidi bajar para que

%number of simulations
NR=20

%if mrandom=0 traveler with shortest subtour is selected, if 1 random traveler is selected
ACOparam.mrandom=0;
ACOparam.clustercities=1;
ACOparam.cluster_influence=15;
ACOparam.cluster_method="sectors_maxAngle";%
ACOparam.twoopt=1;%wheteher 2-opt heurisitic is applied
for nr=1:NR
        namefile=folder+instance+"m"+string(m)+"_ACS_mshort_sectorMaxci15_2opt_"+num2str(nr)+".mat"
        namefig=folder+instance+"m"+string(m)+"_ACS_mshort_sectorMaxci15_2opt_"+num2str(nr)+".jpeg"
        if exist(namefile)~=2
            problem=load(instance+".mat")
            problem.c0=[ones(1,m)]% city 1 is selected as depot
            maxIter=round(ntours)/10%10 ants for ACS
            Solution=ACSminmaxTSP_cluster(problem,ACOparam,maxtime,maxIter)
            save(namefile,'Solution')
            figure(2);print(namefig,'-djpeg');
    end
end


