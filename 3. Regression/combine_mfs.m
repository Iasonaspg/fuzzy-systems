function combine_mfs(fis1,fis2,id)
% Plot input membership functions of a FIS
    f = figure;
    p = uipanel('Parent',f,'BorderType','none'); 
    p.Title = sprintf("Memberhip functions - Input x_%d",id); 
    p.TitlePosition = 'centertop'; 
    p.FontSize = 12;
    p.FontWeight = 'bold';
    p.BackgroundColor = 'white';
   
    subplot(1,2,1,'Parent',p);
    [x,y] = plotmf(fis1,'input',id);
    plot(x,y);
    xlabel(sprintf("x_%d",id));
    ylabel("\mu(x)");
    title('Initial model');
    
    subplot(1,2,2,'Parent',p);
    [x,y] = plotmf(fis2,'input',id);
    plot(x,y);
    xlabel(sprintf("x_%d",id));
    ylabel("\mu(x)");
    title("Tuned model");
end