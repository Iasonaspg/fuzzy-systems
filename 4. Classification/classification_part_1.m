%% Pavlidis Michail Iason - 9015%

close all;
clear;
clc;

start = tic();

%% Load dataset, split it evenly based on classes records and normalize input
p_tr = 0.6;
p_val = 0.2;
p_test = 0.2;
data = load('./Datasets/haberman.data');

Dtr = [];
Dval = [];
Dtest = [];
classes = unique(data(:,end));
rows_per_class = zeros(1,size(classes,1));
for i=1:size(classes,1)
    class = classes(i);
    data_i = data(data(:,end) == class,:);
    [tr,val,test] = split_dataset(p_tr,p_val,data_i);
    Dtr = [Dtr ; tr];
    Dval = [Dval ; val];
    Dtest = [Dtest ; test];
    rows_per_class(i) = size(data_i,1);
end

for i=1:size(classes,1)
    p_tr_i = sum(Dtr(:,end) == classes(i));
    p_test_i = sum(Dtest(:,end) == classes(i));
    p_val_i = sum(Dval(:,end) == classes(i));
    fprintf("Records of class %d in initial dataset: %d. Records in training set: %d, validation set: %d and test set: %d\n"...
        ,classes(i),rows_per_class(i),p_tr_i,p_val_i,p_test_i);
end

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

%% Create TSK models that will use class independent subtractive clustering
r_a = [0.3 0.7 0.3 0.7];
class_dependent_flag = [false false true true];
epoch = 300;
nRules = [];

for i=1:length(r_a)
    if class_dependent_flag(i) == false
        [TSK_fis,train_error,TSK_fis_tuned,val_error] = TSK_classification_model(X_tr,Y_tr,Dval,r_a(i),epoch);
    else
        [TSK_fis,train_error,TSK_fis_tuned,val_error] = class_dependent_training(Dtr,Dval,classes,r_a(i),epoch);
    end

    % Plot trained membership functions 
    plot_mfs(TSK_fis_tuned,i,'Min validation error model');
    nRules = [nRules length(TSK_fis_tuned.rule)];
    
    Y_pred = evalfis(X_test,TSK_fis_tuned);
    Y_pred = round_and_saturate(Y_pred,min(classes),max(classes));
            
    % Plot learning curve
    figure(2);
    subplot(2,2,i);
    plot(train_error)
    hold on;
    plot(val_error)
    %ylim([0.25 0.5]);
    ylabel('Error')
    xlabel('Epoch')
    legend('Training','Validation')
    title(sprintf("Learning Curve TSK model - %d",i))
    
    % Accuracy metrics
    [conf_mat,OA,PA,UA,k_hat] = accuracy_metrics(Y_pred,Y_test);
    fprintf("Number of rules: %d OA: %f and k_hat: %f\n",nRules(i),OA,k_hat);
    fprintf("PA: \n");
    disp(PA);
    fprintf("UA: \n");
    disp(UA);
    fprintf("conf_mat: \n");
    disp(conf_mat);
end

toc(start);


