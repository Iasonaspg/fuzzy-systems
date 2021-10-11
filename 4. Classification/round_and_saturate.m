function y = round_and_saturate(x,min,max)
    y = round(x);
    
    for i=1:length(y)
        if y(i) > max
            y(i) = max;
        elseif y(i) < min
            y(i) = min;
        end
    end 
end