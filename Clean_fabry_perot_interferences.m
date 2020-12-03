function [S_clean] = Clean_fabry_perot_interferences(S,nub,res,f_inter,display)
% Clean the image from the fabry pérot interference
% [S_clean] = Clean_fabry_perot_interferences(S,nub,res,f_inter,display)
% S : 3D matrix containing the spectra in each pixel
% nub : the wavenumber of the IR spectra
% res : spectroscopic resolution
% display : 0 no, 1 yes. display the after/before and the fft of the IR
% spectrum.

disp(['Netoyage des interférences de Fabry Pérot un filtre basse bas de fréquence de coupure f = '...
    ,num2str(f_inter),' cm.'])

% creating the windows to low pass the spectrum
pas = round(f_inter/(2/res/(length(nub)-1)));
porte = zeros(size(S,3),1);
porte(round(size(S,3)/2)-pas:round(size(S,3)/2)+pas)=1;

% reshape the matrix
S_reshape = reshape(S,[size(S,1)*size(S,2) size(S,3)]);

S_clean = zeros(size(S,1)*size(S,2),size(S,3));

%%
% low pass the IR spectrum
n = size(S,3);
S_clean=ifft(ifftshift(fftshift(fft(S_reshape,n,2),2).*repmat(porte',[size(S,1)*size(S,2) 1]),2),n,2);
%%
% reshape to get S_clean
S_clean = abs(reshape(S_clean,[size(S,1) size(S,2) size(S,3)]));

% display
if display == 1
    px = round([size(S,1) size(S,2)]/2); % traget the middle pxiel of the image
    figure(10)
    clf
    subplot(211)
    set(gca, 'Xdir', 'reverse','Xscale','log');
    hold on
    plot(nub,[squeeze(S(px(1),px(2),:)) squeeze(S_clean(px(1),px(2),:))])
    ylabel('IR intensity (DL/cm-1)')
    xlabel('Wavenumber (cm-1)')
    legend('before cleanning','after fabry pérot interference removing')
    
    subplot(212)
    f = linspace(0,2/res,size(S,3))-1/res;
    S_plot = abs(squeeze(fftshift(fft(S(px(1),px(2),:)))));
    plot(f*100,[S_plot/max(S_plot) porte])
    ylabel('Normalized spectrum of the IR spectrum')
    xlabel('Wavelength (µm)')
end

end

