%-------------------------------------------------------------------------%
%         Extraction du spectre IR � partir des interf�rogrammes
%               Enregistrement des interf�ro en rapidscan
% Programme de post-traitement avec tous les interf�ro dans un seul fichier
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

% chemin du dossier o� sont les fichiers ptw
path = 'G:\Stef\FTIR\2019-11-21\solidification2\data3/';

% choix du ROI 
x = 40:130;
y = 10:100;

% Spec de la cam�ra + objectif
TI = 170; %temps d'int�gration cam�ra en us
f_acq = 507; %frequence acquisition de la cam�ra (Hz)
lmax = 5.87; % um longeur d'onde de fin de la cam�ra

% Spec FTIR
v = 0.0633; % vitesse du miroir en cm/s
res = 5; %resolution programm�e dans OMNIC en cm-1

% Valeur de l'apodization (0 si pas d'apodization sinon entre 3 et 7).
coef_apo = 5;

% 1 si on souhaite enlever la thermique
% 0 sinon
therm = 1;


%% -------------------- FIN PARAMETRES A MODIFIER --------------------------

% plus grande longueur d'onde (ou plus petite fr�quence) que la cam�ra peut voir
fmin = 1./(lmax*100)*1e6;


%% Excution du chargement et de la FFT
% chargement image
noms = ls([path,'/*.ptw']);
[image3Dcut,temps_cut,fullimage] = chargement_PTW_movie([path,noms],x,y);


for n = 1:size(image3Dcut,2)
    
    image3D = image3Dcut{n};
    
    if therm == 1 % on enl�ve la thermique ici
        im_therm(:,:,n) = mean(image3D(:,:,end-50:end),3);
        image3D = image3D - im_therm(:,:,n);
    end
    
    % construction du vecteur position
    dl = v/f_acq;
    ZPD = find(image3D(1,1,:) == max(image3D(1,1,:)),1); % trouve le ZPD
    m_pos = ([1:size(image3D,3)]'-ZPD)*dl; % build the position vector for all the images   
    
    % On ne prend que les images situ�es entre -1/res et 1/res
    if ~isempty(find(m_pos>1/res,1)) && ~isempty(find(m_pos<-1/res,1)) % v�rifie que la mesure s'est bien d�roul�e
        image3D = image3D(:,:,m_pos<1/res & m_pos>-1/res);
        interfero(n) = {image3D};
        l = linspace(-1/res,1/res,size(image3D,3))'; % position vector for only the images between -1/res and 1/res
        t_temp = temps_cut{n}; %variable temporaire
        temps(:,n) = t_temp(m_pos<1/res & m_pos>-1/res);
    else
        disp('Probl�me d''alignement du laser du FTIR, refaire la manip')
        return
    end
    
    % ex�cution de la fft
    disp(['Ex�cution de la fft n�',num2str(n),' sur ',num2str(size(image3Dcut,2))])
    [S,nub,inter_apo{n}] = I2S(image3D,l,res,coef_apo);
        
    % on ne garde que la bande spectrale utile entre f2 et f1
    Sutile{n} = S(:,:,nub>fmin);
    
    
    disp(' ')
    disp(' ')
end

nub0 = nub(nub>fmin)'; % on prend les fr�quences sur la bande spectrale utile


%% Affichage
px = [40 40]; % choix du pixel
freq = round(length(nub0)/2); % indice de la fr�quence
choix_spectre = 3;

Smean = Sutile{choix_spectre};
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
title('Intensit� en DL')

subplot(2,3,2)
imagesc(image3D(:,:,1)) 
colorbar
title('Intensit� en DL (ROI)')
daspect([1 1 1])

subplot(2,3,3)
imagesc(Smean(:,:,freq))
hold on
plot(px(1),px(2),'sk')
title(['Fr�quence : ',num2str(nub0(freq)),' cm-1'])
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
ylabel('Intensit� en DL')
title('Affichage de tous les interf�rogrammes')

subplot(2,3,5)
plot(l,squeeze(inter_apo{choix_spectre}))
xlabel('position miroir en cm')
ylabel('Intensit� en DL')
title(['Affichage de l''interf�rogramme apodis� n�',num2str(choix_spectre),' sur ',num2str(size(image3Dcut,2))])

subplot(2,3,6)
set(gca, 'Xdir', 'reverse','Xscale','log');
hold on
%plot(nub0,squeeze(Smean(px(2),px(1),:)));
%plot(nub0,squeeze(mean(mean(Smean))));xlim([1500 4000])
for n = 1:size(image3Dcut,2)
    imageplot = Sutile{n};
    plot(nub0,squeeze(mean(mean(imageplot(30:40,30:40,:)))))
end
xlim([1500 4000])
grid on
xlabel('Nombre d''onde en cm-1')
ylabel('Intensit� en DL/cm-1')
title(['Affichage du spectre n�',num2str(choix_spectre),' sur ',num2str(size(image3Dcut,2))])

%% Sauvegarde
data = struct;
data.Spectre = Sutile;
data.ROI_x=x;
data.ROI_y=y;
data.TI=TI;
data.coef_apo=coef_apo;
data.filename=noms;
data.v_miroir=v;
data.f_acq=f_acq;
data.resolution=res;
data.nub = nub0;
data.temps = temps;

if therm == 1 % on enl�ve la thermique ici
    data.im_therm = im_therm;
end

inter = struct;
inter.interferogrammes = interfero;
inter.position_miroir = l;
inter.temps = temps;



disp('Saving....')

mkdir([path,'pt'])
save([path,'pt/data.mat'],'-struct','data')
save([path,'pt/interferos.mat'],'-struct','inter')
save2pdf([path,'pt/figure.pdf'],gcf,300)
    
disp('Fin du traitement des interf�ros')

