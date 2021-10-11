function [TSK_fis,train_error,TSK_fis_tuned,val_error] = TSK_classification_model(Xtr,Ytr,Dval,r,epoch)
    opt = genfisOptions('SubtractiveClustering');
    opt.ClusterInfluenceRange = r;

    TSK_fis = genfis(Xtr,Ytr,opt);
    
    for j=1:size(TSK_fis.output.mf,2)
        TSK_fis.output.mf(j).type = 'constant';
        TSK_fis.output.mf(j).params = TSK_fis.output.mf(j).params(1);
    end

    anfis_opt = anfisOptions();
    anfis_opt.InitialFIS = TSK_fis;
    anfis_opt.EpochNumber = epoch;
    anfis_opt.ValidationData = Dval;
    anfis_opt.OptimizationMethod = 1; 
    anfis_opt.DisplayANFISInformation = false;
    anfis_opt.DisplayErrorValues = 0; 
    anfis_opt.DisplayStepSize = 0;
    anfis_opt.DisplayFinalResults = 0;

    [TSK_fis,train_error,~,TSK_fis_tuned,val_error] = anfis([Xtr Ytr],anfis_opt);
end