function fis = add_trimf(left,right,labels,var_type,var_ind,fis)
    peaks = length(labels);
    interval = right - left;
    step = interval/(peaks-1);
    center = left;
    for i=1:peaks
        beg = center - step;
        last = center + step;
        fis = addmf(fis,var_type,var_ind,labels(i),'trimf',[beg center last]);
        center = center + step;
    end
end