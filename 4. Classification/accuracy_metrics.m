function [conf_matrix,OA,PA,UA,k] = accuracy_metrics(Y_pred,Y)
    conf_matrix = confusionmat(Y,Y_pred);
    N = length(Y);
    OA = trace(conf_matrix)/N;

    k = size(conf_matrix,1);
    PA = zeros(1,k);
    UA = zeros(1,k);
    x_iric = 0;
    for i=1:k
        x_ii = conf_matrix(i,i);
        sum_i = sum(conf_matrix(i,:));
        sum_j = sum(conf_matrix(:,i));
        PA(i) = x_ii / sum_j;
        UA(i) = x_ii / sum_i;
        x_iric = x_iric + sum_i*sum_j;
    end
    k = (N*trace(conf_matrix) - x_iric) / (N^2 - x_iric);
end