function [Scorrected] = fft_with_Mertz(inter_reshaped,f_apo,Ni,Nj)
% Excute the fft with the phase correction of Mertz
% Input : Image in 1D
% Output : the corrected modulus of the interfegramm

S_uncorrected = fft(inter_reshaped.*repmat(f_apo',[Ni*Nj 1]),length(f_apo),2);

S_uncorrected = S_uncorrected(:,2:round(length(f_apo)/2)); % on ne prend que la moitié du spectre

% calcul avec correction de Mertz
R = real(S_uncorrected);
I = imag(S_uncorrected);
teta = atan2(I,R);
Scorrected = 2*(R.*cos(teta)+I.*sin(teta))/length(f_apo); %Modulus with Mertz correction
    
end

