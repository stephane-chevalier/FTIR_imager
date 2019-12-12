%-------------------------------------------------------------------------%
%         Extraction du spectre IR à partir des interférogrammes
%               Enregistrement des interféro en rapidscan
%                   ------------------------------------
%
%                           S. CHEVALIER 
%
%                          (UMR CNRS-I2M 5295)
%                              08/11/2019
%
%                             VERSION 2.2
%-------------------------------------------------------------------------%


clear all
clc

%%-------------------- PARAMETRES A MODIFIER ------------------------------
%%
% chemin du dossier où sont les fichiers ptw
path = 'E:\flamme\';

% choix du ROI 
x = 1:320;
y = 1:256;

% Spec de la caméra + objectif
TI = 200; %temps d'intégration caméra en us
f_acq = 200; %frequence acquisition de la caméra (Hz)
lmax = 12; % um longeur d'onde max de la caméra

% Spec FTIR
v = 0.0633; % vitesse du miroir en cm/s
res = 5; %resolution programmée dans OMNIC en cm-1

% Valeur de l'apodization (0 si pas d'apodization sinon entre 3 et 7).
coef_apo = 7;

% Soutraction de la thermique
% 1 si on souhaite enlever la thermique
% 0 sinon
therm = 1;

%% -------------------- FIN PARAMETRES A MODIFIER --------------------------

% plus grande longueur d'onde (ou plus petite fréquence) que la caméra peut voir
fmin = 1./(lmax*100)*1e6;


%% Excution du chargement et de la FFT
noms = ls([path,'/*.ptw']);

for n = 1:size(noms,1)
    % chargement image
    [image3D,temps,fullimage] = chargement_PTW([path,noms(n,:)],x,y);    
    
    if therm == 1 % on enlève la thermique ici
        im_therm = mean(image3D(:,:,end-50:end),3);
        image3D = image3D - im_therm;
    end
    
    % construction du vecteur position
    dl = v/f_acq;
    pos = [round(length(x)/2) round(length(y)/2)]; % position du pixel central pour trouver le ZPD
    ZPD = find(image3D(pos(2),pos(1),:) == max(image3D(pos(2),pos(1),:)),1); % trouve le ZPD
    m_pos = ([1:size(image3D,3)]'-ZPD)*dl; % build the position vector for all the images   
    
    % On ne prend que les images situées entre -1/res et 1/res
    if ~isempty(find(m_pos>1/res,1)) && ~isempty(find(m_pos<-1/res,1)) % vérifie que la mesure s'est bien déroulée
        image3D = image3D(:,:,m_pos<1/res & m_pos>-1/res);
        interfero(n) = {image3D};
        l = linspace(-1/res,1/res,size(image3D,3))'; % position vector for only the images between -1/res and 1/res
    else
        disp('Problème d''alignement du laser du FTIR, refaire la manip')
        return
    end
    
    % exécution de la fft
    disp('Exécution de la fft')
    [S,nub,inter_apo] = I2S(image3D,l,res,coef_apo);
        
    % on ne garde que la bande spectrale utile entre f2 et f1
    Sutile{n} = S(:,:,nub>fmin);   
    
    
    disp(' ')
    disp(' ')
    
end
nub0 = nub(nub>fmin)'; % on prend les fréquences sur la bande spectrale utile


%% compute the mean multispectral image
Smean = zeros(size(S,1),size(S,2),size(nub0,1));
for n = 1:size(noms,1)
    Smean = Smean+Sutile{n}/size(noms,1);
end

%% Affichage
px = [150 150]; % choix du pixel
freq = round(length(nub0)/2); % indice de la fréquence

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
for n = 1:size(noms,1)
    imageplot = interfero{n};
    plot(l,squeeze(imageplot(px(2),px(1),:)))
end
hold off
xlabel('position miroir en cm')
ylabel('Intensité en DL')
title('interfero')

subplot(2,3,5)
plot(l,squeeze(inter_apo))
xlabel('position miroir en cm')
ylabel('Intensité en DL')
title('Apodization')

subplot(2,3,6)
set(gca, 'Xdir', 'reverse','Xscale','log');
hold on
plot(nub0,squeeze(Smean(px(2),px(1),:)),'r');%xlim([1500 4000])
%plot(nub0,squeeze(mean(mean(Smean))));%xlim([1500 4000])
grid on
xlabel('Nombre d''onde en cm-1')
ylabel('Intensité en DL/cm-1')
title('Spectre')

%% Sauvegarde
data = struct;
data.Spectre =Smean;
data.ROI_x=x;
data.ROI_y=y;
data.TI=TI;
data.coef_apo=coef_apo;
data.filename=noms;
data.v_miroir=v;
data.f_acq=f_acq;
data.resolution=res;
data.nub = nub0;
if therm == 1 % on enregistre uniquement si on a soustrait la themique
    data.im_therm = im_therm;
end


inter = struct;
inter.interogrammes=interfero;
inter.position_miroir = l;


disp('Saving....')

mkdir([path,'pt'])
save([path,'pt/data.mat'],'-struct','data')
save([path,'pt/interferos.mat'],'-struct','inter')
save2pdf([path,'pt/figure.pdf'],gcf,300)
    
disp('Fin du traitement des interféros')





