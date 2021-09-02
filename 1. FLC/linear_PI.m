% Iasonas Pavlidis - 9015

clc;
clear;
close all;

% Poles and requirements
p1 = 0;
p2 = 0.1;
p3 = 10;
max_over = 0.08;
max_tr = 0.6;
max_gain = 62.99;
min_damp = 0.63;

% Various zeros near the dominant pole
zer = [0.11 0.13 0.15 0.17 0.20];
c = zer(1);
op_loop = tf([1 c],[1 10.1 1 0])
figure
rlocus(op_loop)

% Gain selection based on max gain and min damping
K = 60;
cl_loop = feedback(K*op_loop,1,-1)

%step response
figure
step(cl_loop)

% step response characteristics
s = stepinfo(cl_loop);
fprintf('Rise Time is : %f seconds. Max val: %f\n',s.RiseTime,max_tr);
fprintf('Overshoot is : %f %%. Max val: %f \n',s.Overshoot,max_over*100);

% PI gains
Kp = K / 25;
Ki = c*Kp;