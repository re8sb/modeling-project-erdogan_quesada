% 6311 netlogo project

close all
clear 
clc

%% load data
data = xlsread("Wound infection model example experiment-spreadsheet.csv");

%% calculate the maximum for each trial
nruns = 6*10;
mtrials = 6;

%calculate maximum number of cells for each experiment
for n = 1:nruns
    maximum.bacteria(n) = max(data(17:185,2*n));
    maximum.neutrophil(n) = max(data(17:185,2*n+1));
    maximum.macrophage(n) = max(data(17:185,2*n+2));
    
    count.bacteria(:,n) = data(17:185,2*n);
    count.neutrophil(:,n) = data(17:185,2*n+1);
    count.macrophage(:,n) = data(17:185,2*n+2);
end

maximum.bacteria = reshape(maximum.bacteria,[10,6]);
maximum.neutrophil = reshape(maximum.neutrophil,[10,6]);
maximum.macrophage = reshape(maximum.macrophage,[10,6]);

%calculate mean max value across 10 experiments for each of the 
%6 different susceptibility scores
for m = 1:mtrials
average.max_bacteria(m) = mean(maximum.bacteria(1+(m-1)*10:10+(m-1)*10));
average.max_neutrophil(m) = mean(maximum.neutrophil(1+(m-1)*10:10+(m-1)*10)); 
average.max_macrophage(m) = mean(maximum.macrophage(1+(m-1)*10:10+(m-1)*10));

average.bacteria(:,m) = mean(count.bacteria(:,1+(m-1)*10:10+(m-1)*10));
average.neutrophil(:,m) = mean(count.neutrophil(:,1+(m-1)*10:10+(m-1)*10)); 
average.macrophage(:,m) = mean(count.macrophage(:,1+(m-1)*10:10+(m-1)*10));
end

p.bacteria = kruskalwallis(maximum.bacteria);
p.neutrophil = kruskalwallis(maximum.neutrophil);
p.macrophage = kruskalwallis(maximum.macrophage);

figure
boxplot(maximum.bacteria)
xlabel('Susceptibility (% Probability)')
xticklabels({'50','60','70','80','90','100'})
ylabel('Maximum Bacteria Count')
title('Approach to Normality for Y') 

bacteria_zero = [48, 44, 44, 41, 38, 33];
t = [1:6];
figure
plot(t,bacteria_zero,'o','linewidth',2)

    
    