% Iasonas Pavlidis - 9015

clc;
clear;
close all;

% Create the Fuzzy Inference System. Most of the options are the default.
fz_pi = newfis("FZ-PI");
fz_pi.type = 'mamdani';
fz_pi.AndMethod = 'min';
fz_pi.ImplicationMethod = 'min'; % mamdani imp operator
fz_pi.OrMethod = 'max';
fz_pi.AggregationMethod = 'max';
fz_pi.DefuzzificationMethod = 'centroid';

% Add control variables
fz_pi = addvar(fz_pi,'input', 'E', [-1 1]);
ind_e = 1;
fz_pi = addvar(fz_pi,'input', 'dE', [-1 1]);
ind_de = 2;
fz_pi = addvar(fz_pi,'output', 'dU', [-1 1]);
ind_du = 1;

% Create membership functions
E_labels  = ["NV","NL","NM","NS","ZR","PS","PM","PL","PV"];
dE_labels = ["NV","NL","NM","NS","ZR","PS","PM","PL","PV"];
dU_labels = ["NL","NM","NS","ZR","PS","PM","PL"];

fz_pi = add_trimf(-1,1,E_labels,'input',ind_e,fz_pi);
fz_pi = add_trimf(-1,1,dE_labels,'input',ind_de,fz_pi);
fz_pi = add_trimf(-1,1,dU_labels,'output',ind_du,fz_pi);

% Plot membership functions
figure;
plotmf(fz_pi,'input',ind_e)
figure;
plotmf(fz_pi,'input',ind_de)
figure;
plotmf(fz_pi,'output',ind_du)


