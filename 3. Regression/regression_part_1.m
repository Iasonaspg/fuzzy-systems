% Pavlidis Michail Iason - 9015%

close all;
clear;
clc;

tic();

% Load dataset, split it and normalize input
p_tr = 0.6;
p_val = 0.2;
p_test = 0.2;
data = load('./Datasets/airfoil_self_noise.dat');

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

% Create TSK models
Input_MFs = [2,3,2,3];
MFs_Type = ["gbellmf","gbellmf","gbellmf","gbellmf"];
Out_Type = ["constant","constant","linear","linear"];
epochs = 140;
rows =  ceil(length(Input_MFs)/2);

RMSE = [];
NMSE = [];
NDEI = [];
R2   = [];
for i=1:length(Input_MFs)
    % TSK options
    opt = genfisOptions('GridPartition');
    opt.NumMembershipFunctions = Input_MFs(i); % same MF number for all inputs
    opt.InputMembershipFunctionType = MFs_Type(i); % same MF type for all inputs
    opt.OutputMembershipFunctionType = Out_Type(i);
    
    TSK_fis = genfis(X_tr,Y_tr,opt);
    
    % Tune TSK FIS with ANFIS
    anfis_opt = anfisOptions();
    anfis_opt.InitialFIS = TSK_fis;
    anfis_opt.EpochNumber = epochs;
    anfis_opt.DisplayANFISInformation = 0;
    anfis_opt.DisplayFinalResults = 1;
    anfis_opt.ValidationData = Dval;
    anfis_opt.OptimizationMethod = 1; % hybrid method, backpropagation + least squares
    
    % plot initial membership functions
    plot_mfs(TSK_fis,i,'Initial model');
    
    [TSK_fis,train_error,~,tuned_TSK_fis,val_error] = anfis(Dtr,anfis_opt);
    
    % Plot trained membership functions 
    plot_mfs(tuned_TSK_fis,i,'Min validation err model'); % minimum val error
    
    % Plot learning curve
    figure(4);
    subplot(rows,2,i);
    plot(train_error)
    hold on;
    plot(val_error)
    ylim([0 10]);
    ylabel('Error')
    xlabel('Epoch')
    legend('Training','Validation')
    title(sprintf("Learning Curve TSK model - %d",i))
    
    % Plot prediction error
    figure(5);
    subplot(rows,2,i);
    Y_pred = evalfis(X_test,tuned_TSK_fis);
    rel_err = (Y_test - Y_pred) ./ Y_test;
    plot(1:length(rel_err),rel_err);
    ylim([-0.25 0.25]);
    ylabel('Relative Prediction Error');
    xlabel('Data point');
    title(sprintf("Prediction Error TSK model - %d",i))
    
    % Calculate accuracy metrics
    RMSE = [RMSE rmse(Y_test,Y_pred)];
    R2 = [R2 r2(Y_test,Y_pred)];
    NMSE = [NMSE nmse(Y_test,Y_pred)];
    NDEI = [NDEI sqrt(NMSE(i))];
end

for i=1:length(Input_MFs)
   fprintf("Model %d - RMSE = %f  NMSE = %f  NDEI = %f  R^2 = %f\n",i,RMSE(i),NMSE(i),NDEI(i),R2(i));
end

toc();

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
