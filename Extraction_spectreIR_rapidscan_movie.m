%-------------------------------------------------------------------------%
%         Extraction du spectre IR à partir des interférogrammes
%               Enregistrement des interféro en rapidscan
% Programme de post-traitement avec tous les interféro dans un seul fichier
%                   ------------------------------------
%
%                           S. CHEVALIER 
%
%                          (UMR CNRS-I2M 5295)
%                              07/11/2019
%
%                             VERSION 2.1
%-------------------------------------------------------------------------%


clear all
clc

%%-------------------- PARAMETRES A MODIFIER ------------------------------

% chemin du dossier où sont les fichiers ptw
path = 'D:\Documents\01_Recherche\02_Publications\03_En_cours\02_Note_technique_FTIR\data\2019-11-06\parafine\solidification_1\res32\test2/';
%path = 'D:\Documents\01_Recherche\02_Publications\03_En_cours\02_Note_technique_FTIR\data\2019-11-06\parafine\bkg\res32/';


% choix du ROI 
x = 10:70;
y = 10:70;

% Spec de la caméra + objectif
l1 = 2; % um longeur d'onde de début de la caméra
l2 = 6.67; % um longeur d'onde de fin de la caméra
TI = 400; %temps d'intégration caméra en us
f_acq = 1300; %frequence acquisition de la caméra (Hz)

% Spec FTIR
v = 0.1581; % vitesse du miroir en cm/s
res = 32; %resolution programmée dans OMNIC en cm-1

% Valeur de l'apodization (0 si pas d'apodization sinon entre 3 et 7).
coef_apo = 20;

%%-------------------- FIN PARAMETRES A MODIFIER --------------------------


%% Définition de la bande spectrale utile
if f_acq/v/2 < 1./(l1*100)*1e6 %compare the wavelength of the camera to the max wavelength that can be obtained from the cam frame rate
    f1 = f_acq/v/2;
else
    f1 = 1./(l1*100)*1e6;
end

f2 = 1./(l2*100)*1e6;
nub0 = linspace(f2,f1,round((f1-f2)/res)+1)';

%% Excution du chargement et de la FFT
% chargement image
noms = ls([path,'/*.ptw']);
[image3Dcut,temps_cut,fullimage] = chargement_PTW_movie([path,noms],x,y);


for n = 1:size(image3Dcut,2)    
    
    image3D = image3Dcut{n};
    
    % construction du vecteur position
    dl = v/f_acq;
    ZPD = find(image3D(1,1,:) == max(image3D(1,1,:)),1); % trouve le ZPD
    m_pos = ([1:size(image3D,3)]'-ZPD)*dl; % build the position vector for all the images   
    
    % On ne prend que les images situées entre -1/res et 1/res
    image3D = image3D(:,:,m_pos<1/res & m_pos>-1/res);
    interfero(n) = {image3D};
    l = linspace(-1/res,1/res,2*f_acq/res/v)'; % vector position for only the images between -1/res and 1/res
    t_temp = temps_cut{n};
    temps(:,n) = t_temp(m_pos<1/res & m_pos>-1/res);
    
    % exécution de la fft
    disp(['Exécution de la fft n°',num2str(n),' sur ',num2str(size(image3Dcut,2))])
    [S,nub,inter_apo{n}] = I2S(image3D,l,res,coef_apo);
        
    %interpole sur la bande spectrale utile
    for i = 1:size(S,1)
        for j = 1:size(S,2)
            Stemp(i,j,:) = interp1(nub,squeeze(S(i,j,:)),nub0); 
        end
    end
    Sinterp{n} = Stemp;
    disp(' ')
    disp(' ')
end


% %% compute the mean multispectral image
% Smean = zeros(size(S,1),size(S,2),size(nub0,1));
% for n = 1:3
%     Smean = Smean+Sinterp{n}/size(noms,1);
% end



%% Affichage
px = [40 40]; % choix du pixel
freq = round(length(nub0)/2); % indice de la fréquence
choix_spectre = 3;

Smean = Sinterp{choix_spectre};
image3D = image3Dcut{choix_spectre};

figure(1)
clf
subplot(2,3,1)
imagesc(fullimage) 
hold on
rectangle('Position',[x(1) y(1) x(end)-x(1) y(end)-y(1)])
hold off
daspect([1 1 1])
colorbar
title('Intensité en DL')

subplot(2,3,2)
imagesc(image3D(:,:,1)) 
colorbar
title('Intensité en DL (ROI)')
daspect([1 1 1])

subplot(2,3,3)
imagesc(Smean(:,:,freq))
hold on
plot(px(1),px(2),'sk')
title(['Fréquence : ',num2str(nub0(freq)),' cm-1'])
daspect([1 1 1])
colorbar



subplot(2,3,4)
hold on
for n = 1:size(image3Dcut,2)
    imageplot = interfero{n};
    plot(l,squeeze(imageplot(px(2),px(1),:)))
end
hold off
xlabel('position miroir en cm')
ylabel('Intensité en DL')
title('Affichage de tous les interférogrammes')

subplot(2,3,5)
plot(l,squeeze(inter_apo{choix_spectre}))
xlabel('position miroir en cm')
ylabel('Intensité en DL')
title(['Affichage de l''interférogramme apodisé n°',num2str(choix_spectre),' sur ',num2str(size(image3Dcut,2))])

subplot(2,3,6)
set(gca, 'Xdir', 'reverse','Xscale','log');
hold on
plot(nub0,squeeze(Smean(px(2),px(1),:)));xlim([1500 4000])
%plot(nub0,squeeze(mean(mean(Smean))));xlim([1500 4000])
grid on
xlabel('Nombre d''onde en cm-1')
ylabel('Intensité en DL/cm-1')
title(['Affichage du spectre n°',num2str(choix_spectre),' sur ',num2str(size(image3Dcut,2))])

%% Sauvegarde
data = struct;
data.Spectre =Sinterp;
data.ROI_x=x;
data.ROI_y=y;
data.TI=TI;
data.coef_apo=coef_apo;
data.filename=noms;
data.v_miroir=v;
data.f_acq=f_acq;
data.resolution=res;
data.nub = nub0;

inter = struct;
inter.interferogrammes = interfero;
inter.position_miroir = l;
inter.temps = temps;



disp('Saving....')

mkdir([path,'pt'])
save([path,'pt/data.mat'],'-struct','data')
save([path,'pt/interferos.mat'],'-struct','inter')
save2pdf([path,'pt/figure.pdf'],gcf,300)
    
disp('Fin du traitement des interféros')





