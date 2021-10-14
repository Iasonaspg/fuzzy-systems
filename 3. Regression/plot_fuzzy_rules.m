function plot_fuzzy_rules(fis_init,fis_tuned,nmfs)
inputs = randi([1 length(fis_init.input)],1,nmfs);

FisArray = [fis_init, fis_tuned];
TitleArray = ["Initial FIS","Trained FIS"];

figure();
for i=1:length(inputs)
    k = -1;
    x = -1;
    PlotLegend=cell(2,1);
    for j=1:length(FisArray)
        FIS = FisArray(j);
        CurrentInput = FIS.input(i);
        NumMFs = length(CurrentInput.mf);
        if k < 0
            k = round(rand(1,1) *NumMFs);
            k = max(1,k);
            k = min(NumMFs,k);
            x = min(CurrentInput.range):0.0001:max(CurrentInput.range);
        end
        CurrentMF = CurrentInput.mf(k);
        sigma = CurrentMF.params(1);
        mu = CurrentMF.params(2);
        PlotLegend{j,1} = strcat('MF ',num2str(k),' (',strcat(TitleArray(j)), ')');
        y = normpdf(x,mu,sigma);
        y = y/normpdf(mu,mu,sigma);
        hold on  
        subplot(length(inputs),1,i)
        plot(x,y)
        ylim([-0.1,1.1])
        xlim([min(x), max(x)])
        xlabel(strcat('Input',num2str(inputs(i))))
        ylabel('ì')
    end
    legend(cellstr(PlotLegend))
end



end