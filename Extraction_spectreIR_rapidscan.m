%-------------------------------------------------------------------------%
%         Extraction du spectre IR � partir des interf�rogrammes
%               Enregistrement des interf�ro en rapidscan
%                   ------------------------------------
%
%                           S. CHEVALIER 
%
%                          (UMR CNRS-I2M 5295)
%                              09/07/2019
%
%                             VERSION 2.0
%-------------------------------------------------------------------------%


clear all
clc

%%-------------------- PARAMETRES A MODIFIER ------------------------------

% chemin du dossier o� sont les fichiers ptw
path = '../moyen/';


% choix du ROI 
x = 70:140;
y = 14:100;

% Spec de la cam�ra + objectif
l1 = 2; % um longeur d'onde de d�but de la cam�ra
l2 = 6.67; % um longeur d'onde de fin de la cam�ra
TI = 280; %temps d'int�gration cam�ra en us
f_acq = 870; %frequence acquisition de la cam�ra (Hz)


% Spec FTIR
v = 0.04747; % vitesse du miroir en cm/s
res = 4; %resolution programm�e dans OMNIC en cm-1

% Valeur de l'apodization (0 si pas d'apodization sinon entre 10 et 15).
coef_apo = 15;

%%-------------------- FIN PARAMETRES A MODIFIER --------------------------


%% Excution du chargement et de la FFT
noms = ls([path,'/*.ptw']);


for j = 1:size(noms,1)
    % chargement image
    [image3D,temps,fullimage] = chargement_PTW([path,noms(j,:)],x,y);
    interfero(j) = {image3D};
    
    % construction du vecteur position
    dl = v/f_acq;
    if length(size(image3D)) == 3
        ZPD = find(image3D(1,1,:)==max(image3D(1,1,:)),1); % trouve le ZPD
        l = ([1:size(image3D,3)]'-ZPD)*dl;
    else
        ZPD = find(image3D==max(image3D,1)); % trouve le ZPD
        l = ([1:size(image3D,1)]'-ZPD)*dl;
    end
        
    % ex�cution de la fft
    disp('Ex�cution de la fft')
    [S,nub,inter_apo] = I2S(image3D,l,res,coef_apo);
    if j == 1
        Smean = S;  %initilisation
    else 
        Smean = Smean + S; %calcul la moyenne des spectres
    end
    disp(' ')
    disp(' ')
end
Smean = Smean/j;




%% Selection de la zone de fr�quence d'int�r�t
f1 = 1./(l1*100)*1e6;
f2 = 1./(l2*100)*1e6;
f = find(nub>f2 & nub<f1);
Smean = Smean(:,:,f); % on se limite � la vision cam�ra;
nub = nub(f);



%% Affichage
freq = 1000; % indice de la fr�quence

figure(1)
clf
subplot(2,3,1)
imagesc(fullimage) 
hold on
rectangle('Position',[x(1) y(1) x(end)-x(1) y(end)-y(1)])
hold off
daspect([1 1 1])
colorbar
title('Intensit� en DL')

subplot(2,3,2)
imagesc(image3D(:,:,1)) 
colorbar
title('Intensit� en DL (ROI)')
daspect([1 1 1])

subplot(2,3,3)
imagesc(S(:,:,freq))
title(['Fr�quence : ',num2str(nub(freq)),' cm-1'])
daspect([1 1 1])
colorbar


px = [1 1]; % choix du pixel
subplot(2,3,4)
hold on
for j = 1:size(noms,1)
    imageplot = interfero{j};
    plot(l,squeeze(imageplot(px(2),px(1),:)))
end
hold off
xlabel('position miroir en cm')
ylabel('Intensit� en DL')
title('interfero')

subplot(2,3,5)
plot(l,squeeze(inter_apo))
xlabel('position miroir en cm')
ylabel('Intensit� en DL')
title('Apodization')

subplot(2,3,6)
set(gca, 'Xdir', 'reverse','Xscale','log');
hold on
plot(nub,squeeze(Smean(px(2),px(1),:)));xlim([1500 5000])
grid on
xlabel('Nombre d''onde en cm-1')
ylabel('Intensit� en DL/cm-1')
title('Spectre')

%% Sauvegarde
data = struct;
data.Spectre =Smean;
data.ROI_x=x;
data.ROI_y=y;
data.TI=TI;
data.coef_apo=coef_apo;
data.position_miroir=l;
data.filename=noms;
data.v_miroir=v;
data.f_acq=f_acq;
data.resolution=res;
data.interogrammes=interfero;


%%
disp('Saving....')

mkdir([path,'pt'])
save([path,'pt/data.mat'],'data')
save2pdf([path,'pt/figure.pdf'],gcf,300)
    
disp('Fin du traitement des inter�fos')





