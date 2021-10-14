function plot_mfs(fis,model_id,identifier)
% Plot input membership functions of a FIS
    f = figure;
    p = uipanel('Parent',f,'BorderType','none');
    nrules = length(fis.rule);
    p.Title = sprintf("Memberhip functions - " + identifier + " - TSK model - %d - Number of rules: %d",model_id,nrules); 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';
    p.BackgroundColor = 'white';
    size = length(fis.input);
    rows = ceil(size/2);
    for i=1:size
        subplot(rows,2,i,'Parent',p);
        [x,y] = plotmf(fis,'input',i);
        plot(x,y);
        xlabel(sprintf("x_%d",i));
        ylabel("\mu(x)");
    end
end