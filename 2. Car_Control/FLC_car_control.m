% Iasonas Pavlidis - 9015

clc;
clear;
close all;

% Read FIS model
flc = readfis('./CarControl.fis');

% Plot membership functions
dV_labels  = ["VS","S","M","L","VL"];
ind_dV = 1;
dH = dV_labels;
ind_dH = 2;
theta_labels = ["NL","NS","ZR","PS","PL"];
ind_theta = 3;
dTheta_labels = theta_labels;
ind_dTheta = 1;

figure;
plotmf(flc,'input',ind_dV)
figure;
plotmf(flc,'input',ind_dH)
figure;
plotmf(flc,'input',ind_theta)
figure;
plotmf(flc,'output',ind_dTheta)

%% Simulate body motion
close all;

x0 = 4;
y0 = 0.4;
x_des = 10;
y_des = 3.2;
v = 0.05; % constant velocity

obs_x = [5 5 6 6 7 7 10];
obs_y = [0 1 1 2 2 3 3];

plot(obs_x,obs_y);
xlim([0 10]);
ylim([0 4]);










