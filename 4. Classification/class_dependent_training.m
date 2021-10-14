function [init_fis,TSK_fis,train_error,TSK_fis_tuned,val_error] = class_dependent_training(Dtr,Dval,classes,r,epoch)
    nclasses = length(classes);
    min_cl = min(classes);
    max_cl = max(classes);
    inputs = size(Dtr,2)-1;
    
    % conduct subtractive clustering for each class
    rules = [];
    rule_ptr = zeros(1,nclasses+1);
    centers = [];
    sigmas = [];
    for i=1:nclasses
        [c, sig] = subclust( Dtr(Dtr(:,end)==classes(i),:), r);
        centers = [centers; c];
        sigmas = [sigmas; sig];
        rule_ptr(i+1) = rule_ptr(i) + size(c,1);
        rules = [rules size(c,1)];
    end
    nRules = sum(rules);

    TSK_fis = newfis('TSK_fis','sugeno');

    % Add input variable
    for i=1:inputs
        min_val_i = min(Dtr(:,i));
        max_val_i = max(Dtr(:,i));
        TSK_fis = addvar(TSK_fis,'input',sprintf("x_%d",i),[min_val_i max_val_i]);
    end

    % Add output variable
    TSK_fis = addvar(TSK_fis,'output','out1',[min_cl max_cl]);

    % Each input needs one MF for each cluster
    for i=1:inputs
        for j=1:nclasses
            offset = rule_ptr(j);
            for k=1:rules(j)
                TSK_fis=addmf(TSK_fis,'input',i,sprintf("%s_mf_%d",TSK_fis.input(i).name,k),'gaussmf',...
                    [sigmas(j,i) centers(offset+k,i)]);
            end  
        end
    end
    
    % Each output needs one MF for each cluster
    params = [];
    for i=1:nclasses
       params = [params i*ones(1,rules(i))] ;
    end
    for i=1:nRules
        TSK_fis = addmf(TSK_fis,'output',1,sprintf("%s_mf_%d",TSK_fis.output.name,i),'constant',params(i));
    end

    % One rule for each cluster. It has the form [rule_id rule_id rule_id ... rule_id]
    ruleList = zeros(nRules,inputs+1);
    for i=1:nRules
        ruleList(i,:) = i;
    end
    ruleList=[ruleList ones(nRules,2)];
    TSK_fis = addrule(TSK_fis,ruleList);
    init_fis = TSK_fis;

    % Tune final model
    anfis_opt = anfisOptions();
    anfis_opt.InitialFIS = TSK_fis;

    anfis_opt.ErrorGoal = 0;
    anfis_opt.EpochNumber = epoch;
    anfis_opt.ValidationData = Dval;
    anfis_opt.OptimizationMethod = 1;
    anfis_opt.DisplayANFISInformation = false;
    anfis_opt.DisplayErrorValues = 0; 
    anfis_opt.DisplayStepSize = 0;
    anfis_opt.DisplayFinalResults = 0;

    [TSK_fis,train_error,~,TSK_fis_tuned,val_error] = anfis(Dtr,anfis_opt);
end