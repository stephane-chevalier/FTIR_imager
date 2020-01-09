function [image3D,fullimage,Data] = Chargement_MAT_SLS(noms,x,y)
% Load the SLS mat file, then extract and save the raw data
% Return the ROI 3D image



if isempty(noms)
    disp('Le fichier n''existe pas,, vérifier le nom')
    return
end

load(noms);
flag = 1;
j = 1;

while flag == 1
    
    Data(:,:,j+1) = eval(['Frame',num2str(j)]);
    
    t_temp = eval(['Frame',num2str(j),'_DateTime']);
    t(j+1) = t_temp(6)+t_temp(7)/1000;
    j = j + 1;
    
    if ~exist(['Frame',num2str(j)])
        flag = 0;
    end
end

fullimage = Data(:,:,100);
image3D = Data(y,x,:);

end

