% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
%
%                   Fonction de chargement sans IHM
% -------------------------------------------------------------------------
%                      S. Chevalier - 23/09/2020
%                               version 1.0
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

function [temps,image3D,fileinfo,fullimage] = chargement_ptw_sans_interface(nomfich,x,y)
% [temps,fullimage,fileinfo] = chargement_ptw_sans_interface(nomfich,x,y)
% temps : time of the image
% image3D : movie
% fileinfo : information related to the acquistion
% nomfich : file name
% x and y : limit of the ROI

%%
% -------------------------------------------------------------------------
%                       Récupération des infos du fichier
% -------------------------------------------------------------------------

[fileinfo] = Lecture_Donnees(nomfich);


%%
% -------------------------------------------------------------------------
%                       Cheargement de la séquence des images
% -------------------------------------------------------------------------
   
tic;
[temps,temp] = Acquisition_Sequence(nomfich,fileinfo);
image3D = temp(y,x,:);
fullimage = temp(:,:,1);
t_load = toc;
disp(['Fichier chargé en ',num2str(t_load),' s']);

end