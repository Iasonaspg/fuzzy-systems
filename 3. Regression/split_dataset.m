function [Dtr,Dval,Dtest] = split_dataset(p_tr,p_val,data)
    m = size(data,1);
    idx = randperm(m);
    Dtr = data( idx(1:round(p_tr*m)), :); 
    Dval = data( idx( round(p_tr*m)+1:round((p_tr+p_val)*m) ), :);
    Dtest = data( idx(round((p_tr+p_val)*m)+1:end), :);
end