function [image3D_aligned,m_pos] = Step_scan_check_and_select_interferos(image3D,SSP,nb_ZPD,res)

%[image3D_aligned,l] = check_and_select_interferos(image3D,v,res,data_cam)
% select only the interesting part of the interfero for the fft
% image3D : 3D image containing the interferos
% l : optical retardation (cm)

fHeNe = 31596; %cm-1 frequency of the laser in the FTIR

disp('Checking and selecting the interfero in the image')

% construction du vecteur position
%dl = v/data_cam.freq; % optical displacement step (cm)
pos = [round(size(image3D,1)/2) round(size(image3D,2)/2)]; % position du pixel central pour trouver le ZPD
N_th = round(nb_ZPD+fHeNe/res/SSP+1); % theoritical number of frame
% if mod(N_th,2)
%     N_th = N_th+1; % make N_th even
% end


% find the ZPD and the mirror position
ZPD = find(image3D(pos(1),pos(2),:) == max(image3D(pos(1),pos(2),:)),1); % find ZPD
figure(10)
clf
subplot(311)
plot(squeeze(image3D(pos(1),pos(2),:)))
hold on
plot([ZPD ZPD],[min(squeeze(image3D(pos(1),pos(2),:))) max(squeeze(image3D(pos(1),pos(2),:)))],'--k')
title('Raw signal used to find the ZPD');
legend('Interferogram','Position of the ZPD')
drawnow;

m_pos = linspace(-nb_ZPD/(fHeNe/SSP),1/res,N_th)';  % build the position vector for all the images
image3D_aligned = zeros(size(image3D,1),size(image3D,2),N_th); %prealocating

disp('-------------------------')
fprintf('Expected number of frame : %i, \n and position of ZPD : %i.',N_th,ZPD)
fprintf('\n Note that the position of the ZPD \n should be approximatively %i .\n',nb_ZPD)
disp('-------------------------')

% Extract the right number of images
image3D_aligned = image3D(:,:,ZPD-nb_ZPD+1:ZPD-nb_ZPD+N_th);


id_aligned = find(m_pos<1/res & m_pos>-1/res); % find the interesting position
%image3D_aligned(:,:,N_th-length(id_aligned)+1:N_th) = image3D(:,:,id_aligned); % select only the interesting data
%l = linspace(-1/res,1/res,N_th)'; % creation of the aligned position vector


end

