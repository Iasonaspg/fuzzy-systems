%% Pavlidis Michail Iason - 9015%

close all;
clear;
clc;

start = tic();

%% Load dataset, split it evenly based on classes records and normalize input
p_tr = 0.6;
p_val = 0.2;
p_test = 0.2;
data = importdata('./Datasets/EpilepticSeizureRecognition.csv');
data = data.data;

Dtr = [];
Dval = [];
Dtest = [];
classes = unique(data(:,end));
rows_per_class = zeros(1,size(classes,1));
for i=1:size(classes,1)
    class = classes(i);
    data_i = data(data(:,end) == class,:);
    [tr,val,test_set] = split_dataset(p_tr,p_val,data_i);
    Dtr = [Dtr ; tr];
    Dval = [Dval ; val];
    Dtest = [Dtest ; test_set];
    rows_per_class(i) = size(data_i,1);
end

for i=1:size(classes,1)
    p_tr_i = sum(Dtr(:,end) == classes(i));
    p_test_i = sum(Dtest(:,end) == classes(i));
    p_val_i = sum(Dval(:,end) == classes(i));
    fprintf("Records of class %d in initial dataset: %d. Records in training set: %d, validation set: %d and test set: %d\n"...
        ,classes(i),rows_per_class(i),p_tr_i,p_val_i,p_test_i);
end

Dtr  = Dtr(randperm(size(Dtr,1)),:);
Dval  = Dval(randperm(size(Dval,1)),:);
Dtest = Dtest(randperm(size(Dtest,1)),:);

X_tr   = Dtr(:,1:end-1);
X_val  = Dval(:,1:end-1);
X_test = Dtest(:,1:end-1);

X_tr = normalize(X_tr);
X_val = normalize(X_val);
X_test = normalize(X_test);

Y_tr =  Dtr(:,end);
Y_val =  Dval(:,end);
Y_test =  Dtest(:,end);

Dtr   = [X_tr Y_tr];
Dval  = [X_val Y_val];
Dtest = [X_test Y_test];

%% Rank feautures importance using RReliefF algorithm
t1 = tic();
[ranked_feat_ind,~] = relieff(X_tr,Y_tr,230,'method','classification');
toc(t1);

%% Grid search for optimal parameters
t2 = tic();

nFeatures = [8, 14, 18, 20];
r_a = [0.7, 0.6, 0.5, 0.4];

p_cv_tr = 0.8;
p_cv_val = 1 - p_cv_tr;
num_folds = 5;
m = size(Dtr,1);
epoch = 100;

nRules = zeros(length(nFeatures),length(r_a));
mean_errors = zeros(length(nFeatures),length(r_a));
poolobj = gcp;
addAttachedFiles(poolobj,{'class_dependent_training.m'})
for i=1:length(nFeatures)
    feat_ind = ranked_feat_ind(1:nFeatures(i));
    X_tr_trunc = X_tr(:,feat_ind);
    for j=1:length(r_a)
        tj = tic();
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
            
            [~,~,~,tuned_TSK_FIS,val_err] = class_dependent_training([X_tr_cv Y_tr_cv],[X_val_cv Y_val_cv],classes,r,epoch);
            
            fold_error(fold_idx) = min(val_err);
            nrules(fold_idx) = length(tuned_TSK_FIS.rule);
        end
        nRules(i,j) = nrules(1);
        mean_errors(i,j) = mean(fold_error);
        fprintf("Iteration execution time: \n");
        toc(tj);
    end
end
toc(t2);

%% Plot mean error
figure();
rows = ceil(length(nFeatures)/2);
for i=1:length(nFeatures)
    subplot(rows,2,i);
    plot(r_a,mean_errors(i,:),'-o');
    ylim([1.012 1.06]);
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

%% Main model
epoch_main = 1000;
feat_ind_opt = ranked_feat_ind(1:nFeatures_opt);
Dtr_opt  = [X_tr(:,feat_ind_opt) Y_tr];
Dval_opt = [X_val(:,feat_ind_opt) Y_val];
Dtest_opt = [X_test(:,feat_ind_opt) Y_test];
[init_fis,TSK_fis,train_error,TSK_fis_tuned,val_error] = class_dependent_training(Dtr_opt,Dval_opt,classes,r_opt,epoch_main);

%% Calculate and plot the model output
Y_pred = evalfis(Dtest_opt(:,1:end-1),TSK_fis_tuned);
Y_pred = round_and_saturate(Y_pred,min(classes),max(classes));

figure();
plot(Y_test,'*')
hold on
plot(Y_pred,'*')
legend('Real output','Predicted output')
xlabel('Instances')
ylabel('Output')

%% Plot learning curves
figure();

plot(train_error);
hold on;
plot(val_error);
legend('Training','Validation')
xlabel('Epoch')
ylabel('Error')

%% Plot MFs
plot_fuzzy_rules(init_fis,TSK_fis_tuned,2);
figure;
plotmf(TSK_fis_tuned,'input',5);

%% Accuracy metrics
[conf_mat,OA,PA,UA,k_hat] = accuracy_metrics(Y_pred,Y_test);
%fprintf("Number of rules: %d OA: %f and k_hat: %f\n",nRules(i),OA,k_hat);
fprintf("OA: %f and k_hat: %f\n",OA,k_hat);
fprintf("PA: \n");
disp(PA);
fprintf("UA: \n");
disp(UA);
fprintf("conf_mat: \n");
disp(conf_mat);
    
toc(start);