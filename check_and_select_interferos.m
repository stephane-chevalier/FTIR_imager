function [image3D_aligned,m_pos] = check_and_select_interferos(image3D,v,res,data_cam)

%[image3D_aligned,l] = check_and_select_interferos(image3D,v,res,data_cam)
% select only the interesting part of the interfero for the fft
% image3D : 3D image containing the interferos
% l : optical retardation (cm)
% v : vitesse optique (cm/s)

disp('Checking and selecting the interfero in the image')

% construction du vecteur position
%dl = v/data_cam.freq; % optical displacement step (cm)
pos = [round(size(image3D,1)/2) round(size(image3D,2)/2)]; % position du pixel central pour trouver le ZPD
N_th = round(2/res/v*data_cam.freq); % theoritical number of frame
if mod(N_th,2)
    N_th = N_th+1; % make N_th even
end


% find the ZPD and the mirror position
ZPD = find(image3D(pos(1),pos(2),:) == max(image3D(pos(1),pos(2),:)),1); % find ZPD

m_pos = linspace(-1/res,1/res,N_th)';  % build the position vector for all the images
image3D_aligned = zeros(size(image3D,1),size(image3D,2),N_th); %prealocating

%check if there is enough images in the interferogram and replace the data
if size(image3D,3) < N_th
    disp('Not enough image in the raw data, consider reducing the spectral resolution')
    if ZPD + N_th/2 > size(image3D,3) %case where not enougth image at the end
        image3D_aligned(:,:,1:N_th/2) = image3D(:,:,ZPD-N_th/2+1:ZPD);
        image3D_aligned(:,:,N_th/2+1:N_th/2+size(image3D(:,:,ZPD+1:end),3)) = image3D(:,:,ZPD+1:end);
    else ZPD - N_th/2 < 0 %case where not enougth image at the beginning
        image3D_aligned(:,:,N_th/2+1:end) = image3D(:,:,ZPD+1:ZPD+N_th/2);
        image3D_aligned(:,:,N_th/2-size(image3D(:,:,1:ZPD)+1,3):N_th/2) = image3D(:,:,1:ZPD);
    end
else % case where everything is ok
    image3D_aligned(:,:,1:N_th/2) = image3D(:,:,ZPD-N_th/2+1:ZPD);
    image3D_aligned(:,:,N_th/2+1:end) = image3D(:,:,ZPD+1:ZPD+N_th/2);
end


id_aligned = find(m_pos<1/res & m_pos>-1/res); % find the interesting position
%image3D_aligned(:,:,N_th-length(id_aligned)+1:N_th) = image3D(:,:,id_aligned); % select only the interesting data
%l = linspace(-1/res,1/res,N_th)'; % creation of the aligned position vector

%% check the mirror position
if length(id_aligned)-N_th >= -1
    disp('Mirror aligned, well done !')
elseif length(id_aligned)-N_th > -10
    disp('Warning the mirror is sligly unaligned')
elseif length(id_aligned)-N_th > -100
    disp('Warning the mirror is significantly unaligned')
elseif length(id_aligned)-N_th > -1000
    disp('Warning the mirror is highly unaligned, some data are replaced with zeros')    
    %id_replaced = squeeze(find(image3D_aligned(1,1,:)==0));
    %image3D_aligned(:,:,id_replaced)=image3D_aligned(:,:,end:-1:end-length(id_replaced)+1);
    figure(2);clf;plot(squeeze(image3D_aligned(1,1,:)))
else
    disp('Warning, something wrong in the mirror alignment, processing stop')
    return
end
end

