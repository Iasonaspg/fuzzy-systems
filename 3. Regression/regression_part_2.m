%% Pavlidis Michail Iason - 9015%

close all;
clear;
clc;

start = tic();

% Load dataset, split it and normalize input
p_tr = 0.6;
p_val = 0.2;
p_test = 0.2;
csv = importdata('./Datasets/superconductivity.csv');
data = csv.data;

[Dtr,Dval,Dtest] = split_dataset(p_tr,p_val,data);

X_tr   = Dtr(:,1:end-1);
X_val  = Dval(:,1:end-1);
X_test = Dtest(:,1:end-1);

X_tr   = (X_tr - min(X_tr)) ./ (max(X_tr) - min(X_tr));
X_val  = (X_val - min(X_val)) ./ (max(X_val) - min(X_val));
X_test = (X_test - min(X_test)) ./ (max(X_test) - min(X_test));

Y_tr =  Dtr(:,end);
Y_val =  Dval(:,end);
Y_test =  Dtest(:,end);

Dtr   = [X_tr Y_tr];
Dval  = [X_val Y_val];
Dtest = [X_test Y_test];

%% Rank feautures importance using RReliefF algorithm
t1 = tic();
[ranked_feat_ind,~] = relieff(X_tr,Y_tr,140); 
toc(t1);

%% Grid search for optimal parameters
t2 = tic();

nFeatures = [4, 7, 9, 12];
r_a = [0.6, 0.5, 0.4, 0.3];

p_cv_tr = 0.8;
p_cv_val = 1 - p_cv_tr;
num_folds = 5;
m = size(Dtr,1);

nRules = zeros(length(nFeatures),length(r_a));
mean_errors = zeros(length(nFeatures),length(r_a));
for i=1:length(nFeatures)
    feat_ind = ranked_feat_ind(1:nFeatures(i));
    X_tr_trunc = X_tr(:,feat_ind);
    for j=1:length(r_a)
        cv_part = cvpartition(m,'KFold',num_folds);
        
        r = r_a(j);
        fold_error = zeros(1,num_folds);
        nrules = zeros(1,num_folds);
        parfor fold_idx = 1:num_folds
            tr_cv_ind = training(cv_part,fold_idx);
            val_cv_ind = test(cv_part,fold_idx);
            X_tr_cv = X_tr_trunc(tr_cv_ind,:);
            Y_tr_cv = Y_tr(tr_cv_ind);
            X_val_cv = X_tr_trunc(val_cv_ind,:);
            Y_val_cv = Y_tr(val_cv_ind);
            
            % Create the TSK model using substractive clustering
            opt = genfisOptions('SubtractiveClustering');
            opt.ClusterInfluenceRange = r;
            
            TSK_fis = genfis(X_tr_cv,Y_tr_cv,opt); 

            % Tune the TSK model
            anfis_opt = anfisOptions();
            anfis_opt.InitialFIS = TSK_fis;
            anfis_opt.EpochNumber = 100;
            anfis_opt.DisplayANFISInformation = 0;
            anfis_opt.DisplayFinalResults = 0;
            anfis_opt.ValidationData = [X_val_cv Y_val_cv];
            anfis_opt.DisplayErrorValues = 0; 
            anfis_opt.DisplayStepSize = 0;
            [~,~,~,tuned_TSK_FIS,val_err] = anfis([X_tr_cv Y_tr_cv],anfis_opt);
            
            fold_error(fold_idx) = min(val_err);
            nrules(fold_idx) = length(tuned_TSK_FIS.rule);
        end
        nRules(i,j) = nrules(1);
        mean_errors(i,j) = mean(fold_error);
    end
end
toc(t2);

%% Plot mean error
figure();
rows = ceil(length(nFeatures)/2);
for i=1:length(nFeatures)
    subplot(rows,2,i);
    plot(r_a,mean_errors(i,:),'-o');
    ylim([14 21]);
    for j=1:length(r_a)
        text(r_a(j),mean_errors(i,j),sprintf("Rules = %d",nRules(i,j)));
    end
    title(sprintf("Number of Features = %d",nFeatures(i)));
    xlabel('Cluster radius');
    ylabel('Mean Error');
end

%% Find optimal parameters
min_error = min(min(mean_errors));
[i,j] = find(mean_errors == min_error);
nFeatures_opt = nFeatures(i);
r_opt = r_a(j);

%% Create and tune the final model based on optimal parameters
t3 = tic();
epoch = 150;
opt = genfisOptions('SubtractiveClustering');
opt.ClusterInfluenceRange = r_opt;

feat_ind = ranked_feat_ind(1:nFeatures_opt);
Dtr_trunc = [X_tr(:,feat_ind) Y_tr];
Dval_trunc = [X_val(:,feat_ind) Y_val];
Dtest_trunc = [X_test(:,feat_ind) Y_test];

TSK_fis = genfis(Dtr_trunc(:,1:end-1),Y_tr,opt); 

% Train the final TSK model
anfisOpt = anfisOptions();
anfisOpt.InitialFIS = TSK_fis;
anfisOpt.EpochNumber = epoch;
anfisOpt.ValidationData = Dval_trunc; 
anfisOpt.DisplayANFISInformation = false;
anfisOpt.DisplayErrorValues = 0; 
anfisOpt.DisplayStepSize = 0;
anfisOpt.DisplayFinalResults = 0;
[TSK_fis,train_error,~,TSK_fis_tuned,val_error] = anfis(Dtr_trunc,anfisOpt);

% Calculate and plot the model output
Y_pred = evalfis(Dtest_trunc(:,1:end-1),TSK_fis_tuned);

figure();
plot(Y_test,'*')
hold on
plot(Y_pred,'*')
legend('Real output','Predicted output')
xlabel('Instances')
ylabel('Output')

toc(t3);
%% Plot learning curves
figure();

plot(train_error);
hold on;
plot(val_error);
legend('Training','Validation')
xlabel('Epoch')
ylabel('Error')

%% Plot MFs
combine_mfs(TSK_fis,TSK_fis_tuned,2);
combine_mfs(TSK_fis,TSK_fis_tuned,3);

%% Calculate metrics
RMSE = rmse(Y_test,Y_pred);
R2 = r2(Y_test,Y_pred);
NMSE = nmse(Y_test,Y_pred);
NDEI = sqrt(nmse(Y_test,Y_pred));
fprintf("RMSE = %f  NMSE = %f  NDEI = %f  R^2 = %f\n",RMSE,NMSE,NDEI,R2);

toc(start);

function x = rmse(y,y_pred)
    err_sq = (y - y_pred).^2;
    mse = sum(err_sq)/length(y);
    x = sqrt(mse);
end

function x = r2(y,y_pred)
    SS_res = sum( (y - y_pred).^2 );
    SS_tot = sum( (y - mean(y)).^2 );
    x = 1 - SS_res/SS_tot;
end

function x = nmse(y,y_pred)
    sig_e = sum( (y - y_pred).^2 );
    sig_x = sum( (y - mean(y)).^2 );
    x = sig_e/sig_x;
end
