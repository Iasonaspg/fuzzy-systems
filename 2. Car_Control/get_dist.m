function [dH,dV] = get_dist(x,y,obs_x_vec,obs_y_vec)
% Calulate the horizontal and vertical distance of the next closer obstacle
    
    dH = obs_x_vec(end) + 0.2 - x;
    dV = 0;
    flagX = true;
    flagY = true;

    len = length(obs_x_vec);
    for i=1:(len)
        dx = obs_x_vec(i) - x;
        dy = y - obs_y_vec(i);
        if  dx > 0 && dy > 0 && flagX == true
            dV = dy;
            flagX = false;
        elseif dx > 0 && dy < 0 && flagY == true
            dH = abs(dx);
            flagY = false;
        end
    end

dV = min(max(dV,0),1);
dH = min(max(dH,0),1);
end