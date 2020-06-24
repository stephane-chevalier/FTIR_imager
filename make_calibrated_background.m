function make_calibrated_background(bkg_folder,name_bkg,display)
% make_calibrated_background(bkg_folder,name_bkg,display)
% display == 1 for displaying the results, else 0
% bkg_folder = the folder where all the background are stored
% name_bkg = the name for the saved calibrated background
%
%-------------------------------------------------------------------------%
%           Créer le spectre de background pour les interféros
%                   ------------------------------------
%
%                           S. CHEVALIER
%
%                        (UMR CNRS-I2M 5295)
%                            22/06/2020
%
%                             VERSION 3.0
%-------------------------------------------------------------------------%
folders = ls(bkg_folder);

% load data
jj = 1;
for ii = 3:size(folders,1)
    disp(['loading ',folders(ii,:)])
    temp = load(['bkg/',folders(ii,:),'./pt/data.mat']);
    TI(jj,1) = temp.TI;
    S(:,:,jj) = reshape(temp.Spectre,[size(temp.ROI_x,2)*size(temp.ROI_y,2) size(temp.nub,1)]);
    jj = jj+1;
end

%% compute the calibrated background
disp('Computing calibrating background')
C_reshape = zeros(size(S,1),size(S,2));
for ii = 1:length(temp.nub)
    for jj = 1:size(S,1)
        Y = squeeze(S(jj,ii,:));
        C_reshape(jj,ii) = (TI'*TI)\(TI'*Y);
    end
end

%%
C = reshape(C_reshape,[size(temp.ROI_y,2) size(temp.ROI_x,2) size(temp.nub,1)]);

%% display
if display == 1
    px = round([size(temp.ROI_y,2) size(temp.ROI_x,2)]/2+15);
    figure(4)
    clf
    set(gca, 'Xdir', 'reverse','Xscale','log');
    hold on
    for ii = 1:size(S,3)
        S_temp = reshape(S(:,:,ii),[size(temp.ROI_y,2) size(temp.ROI_x,2) size(temp.nub,1)]);
        plot(temp.nub,squeeze(C(px(1),px(2),:))*TI(ii),'r',...
            temp.nub,squeeze(S_temp(px(1),px(2),:)),'-o');
    end

    grid on
    xlabel('Nombre d''onde en cm-1')
    ylabel('Intensité en DL/cm-1')
    title('Spectre')
    drawnow;
end

%% saving
disp('Saving')
save([bkg_folder,'/',name_bkg,'.mat'],'C');

end

