function [image3D_aligned,l] = check_and_select_interferos(image3D,v,res,data_cam)

%[image3D_aligned,l] = check_and_select_interferos(image3D,v,res,data_cam)
% select only the interesting part of the interfero for the fft
% image3D : 3D image containing the interferos
% l : mirror position

disp('Checking and selecting the interfero in the image')

% construction du vecteur position
dl = v/data_cam.freq; % mirror step (cm)
pos = [round(size(image3D,1)/2) round(size(image3D,2)/2)]; % position du pixel central pour trouver le ZPD
N_th = round(2/res/v*data_cam.freq); % theoritical number of frame

% find the ZPD and the mirror position
ZPD = find(image3D(pos(1),pos(2),:) == max(image3D(pos(1),pos(2),:)),1); % find ZPD
m_pos = ([1:size(image3D,3)]'-ZPD)*dl; % build the position vector for all the images

image3D_aligned = zeros(size(image3D,1),size(image3D,2),N_th); %prealocating

id_aligned = find(m_pos<1/res & m_pos>-1/res); % find the interesting position
image3D_aligned(:,:,N_th-length(id_aligned)+1:N_th) = image3D(:,:,id_aligned); % select only the interesting data
l = linspace(-1/res,1/res,N_th)'; % creation of the aligned position vector

%% check the mirror position
if length(id_aligned)-N_th >= -1
    disp('Mirror aligned, well done !')
elseif length(id_aligned)-N_th > -10
    disp('Warning the mirror is sligly unaligned')
elseif length(id_aligned)-N_th > -100
    disp('Warning the mirror is significantly unaligned')
elseif length(id_aligned)-N_th > -1000
    disp('Warning the mirror is highly unaligned, some data are replaced to compensate')    
    id_replaced = squeeze(find(image3D_aligned(1,1,:)==0));
    image3D_aligned(:,:,id_replaced)=image3D_aligned(:,:,end:-1:end-length(id_replaced)+1);
    figure(2);clf;plot(squeeze(image3D_aligned(1,1,:)))
else
    disp('Warning something wrong in the mirror alignment, processing stop')
    return
end
end

