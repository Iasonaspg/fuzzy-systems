% Iasonas Pavlidis - 9015

clc;
clear;
close all;

% Create the Fuzzy Inference System. Most of the options are the default.
fz_pi = newfis("FZ-PI");
fz_pi.type = 'mamdani';
fz_pi.AndMethod = 'min';
fz_pi.ImplicationMethod = 'min'; % mamdani imp operator
fz_pi.AggregationMethod = 'max';
fz_pi.DefuzzificationMethod = 'centroid';
fz_pi.OrMethod = 'max';

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

% Create and add rule bases
in_values = [-4 -3 -2 -1 0 1 2 3 4];
out_values = [-3 -2 -1 0 1 2 3];

ub = max(out_values);
lb = -ub;
rules = [];
for i=1:length(E_labels)
    x = in_values(i);
    for j=1:length(dE_labels)
        y = in_values(j);
        z = max( min(x+y,ub), lb);
        out_ind = find(out_values == z);
        rule = [i j out_ind 1 1];
        rules = [rules; rule];
    end
end
fz_pi = addrule(fz_pi,rules);

Kp = 2.4;
Ki = 0.2640;
alpha = min(Kp/Ki,1);

writefis(fz_pi,"./Mat_files/FZ_PI.fis");


%% Run first the simulation in Simulink
ref_resp = load('pi_resp.mat');
pi_resp = load('fz_pi_resp.mat');

figure;
plot(ref_resp.resp.Time,ref_resp.resp.Data);
hold on;
plot(pi_resp.resp.Time,pi_resp.resp.Data);

xlabel('Time in seconds');
ylabel('Rad/s');
legend('Classic PI','Fuzzy PI (Initial)');
stepinfo(pi_resp.resp.Data,pi_resp.resp.Time)

%%

ref_resp = load('pi_resp.mat');
pi_resp = load('fz_pi_resp.mat');
fz_pi_resp_tuned = load('fz_pi_resp_tuned.mat');

figure;
plot(ref_resp.resp.Time,ref_resp.resp.Data);
hold on;
plot(pi_resp.resp.Time,pi_resp.resp.Data);
hold on;
plot(fz_pi_resp_tuned.resp.Time,fz_pi_resp_tuned.resp.Data);
xlabel('Time in seconds');
ylabel('Rad/s');
legend('Classic PI','Fuzzy PI (Initial)','Fuzzy PI (Tuned)');

stepinfo(fz_pi_resp_tuned.resp.Data,fz_pi_resp_tuned.resp.Time)

%% Ruleviewer
ruleview(fz_pi);
out = evalfis([0.25 0],fz_pi);
fprintf("Output of Du given as input [0.25,0]: %f\n",out);

gensurf(fz_pi);


%% Ramp Response

ref_resp = load('ref_sig.mat');
pi_resp = load('pi_resp.mat');
fz_pi_resp_tuned = load('fz_pi_resp_tuned.mat');

figure;
plot(ref_resp.resp.Time,ref_resp.resp.Data);
hold on;
plot(pi_resp.resp.Time,pi_resp.resp.Data);
hold on;
plot(fz_pi_resp_tuned.resp.Time,fz_pi_resp_tuned.resp.Data);
xlabel('Time in seconds');
ylabel('Rad/s');
legend('Reference Signal','Classical PI','Fuzzy PI (Tuned)');




