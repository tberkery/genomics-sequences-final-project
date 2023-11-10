% Pset 5 question 1 Langevin dynamics
clc; clear;
%rng(5)

%% 1) PUT IN INITIAL COORDINATES HERE
%init_pos = [0,0,1; 0,0,2; 0,0,3; 0,0,4; 0,0,5];
init_pos = [0,0,1; 0,0,2; 0,0,3; 0,0,4; 0,0,5; 0,0,6; 0,0,7; 0,0,8; 0,0,9; 0,0,10; 0,0,11; 0,0,12; 0,0,13; 0,0,14];

%% 2) PUT IN THE H-P COARSE GRAINING HERE 
% H is hydrophobic (true), P is polar (false)
%is_hydrophil = [true;false;false;true;true];
is_hydrophil = [false;false;false;true;true; true;false;false; true; true; true; false; false; false];

%% 3) PUT THE CLUSTER MEANS HERE
clust_means = ones(1,7); % placeholder

%% 4) RUN LD SIMULATION HERE
% running LD with T=2, dt=0.003, steps = 10,000 (need to change)
[times, potentials, kinetics, temperatures, equilibrium_pos, clusters] = LD(init_pos, is_hydrophil, 1, 0.003, 10000, clust_means);

%% 5) Print clusters
clusters

%% PLOT RESULTS HERE
int_energies = kinetics + potentials;
figure(1);
hold on
plot(times, potentials);
plot(times, kinetics);
%plot(times, temperatures)
legend("PE", "KE")
xlabel("Time")
ylabel("Energy")
hold off

ave_PE = sum(potentials(9001:10000))/length(potentials(9001:10000))
ave_KE = sum(kinetics(9001:10000))/length(kinetics(9001:10000)) 
ave_E = sum(int_energies(9001:10000))/length(int_energies(9001:10000))

figure(2)
plot3(equilibrium_pos(:,1), equilibrium_pos(:,2), equilibrium_pos(:,3))