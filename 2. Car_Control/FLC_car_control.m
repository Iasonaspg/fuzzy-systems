% Iasonas Pavlidis - 9015

clc;
clear;
close all;

% Read FIS model
flc = readfis('./CarControl.fis');
flc2 = readfis('./Improved_CarControl.fis');

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

figure;
plotmf(flc2,'output',ind_dTheta)

%% Simulate body motion
close all;

x0 = 4;
y0 = 0.4;
x_des = 10;
y_des = 3.2;
v = 0.05; % constant velocity

obs_x = [5 5 6 6 7 7 10];
obs_y = [0 1 1 2 2 3 3];

thetas = [0,-45,-90];
simulate_car(x0,y0,x_des,y_des,v,obs_x,obs_y,thetas,flc);
fprintf("\n\n");
simulate_car(x0,y0,x_des,y_des,v,obs_x,obs_y,thetas,flc2);

function simulate_car(x0,y0,x_des,y_des,v,obs_x,obs_y,thetas,fuzzy_controller)
    for i = 1:length(thetas)
        xi = x0;
        yi = y0;
        route = [xi yi];
        theta = thetas(i);
        d = [];
        while (xi <= x_des)
            [dH,dV] = get_dist(xi,yi,obs_x,obs_y);
            d = [d; [xi yi dH dV]];
            dTheta = evalfis([dV dH theta],fuzzy_controller);
            theta = theta + dTheta;
            if (theta > 180); theta = theta - 360; end
            if (theta < -180); theta = theta + 360; end
            xi = xi + v*cosd(theta);
            yi = yi + v*sind(theta);
            route = [route ; [xi yi]];
        end

        fprintf("Final position: (%f,%f)\n",xi,yi);
        figure;
        plot(obs_x,obs_y);
        xlim([0 10]);
        ylim([0 4]);
        hold on;
        plot(route(:,1),route(:,2));
        grid;
        plot(x0,y0,'*');
        plot(x_des,y_des,'*');
        title("Initial theta = " + thetas(i) + " degrees");
    end
end






