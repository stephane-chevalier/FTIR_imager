function [Scorrected] = fft_with_Mertz(inter_reshaped,f_apo,Ni,Nj)
% Excute the fft with the phase correction of Mertz
% Input : Image in 1D
% Output : the corrected modulus of the interfegramm

Scorrected = zeros(Ni*Nj,round(length(f_apo)/2)-1);

    for j = 1:Nj*Ni    

        S_uncorrected = fft(inter_reshaped(j,:).*f_apo');

        R = real(S_uncorrected);
        I = imag(S_uncorrected);
        teta = atan2(I,R);
        S_temp = 2*(R.*cos(teta)+I.*sin(teta))/length(f_apo); %Modulus with Mertz correction

        S_temp(round(length(S_temp)/2):end) = []; % on ne prend que la moitié du spectre
        Scorrected(j,:) = S_temp; 
    end
    
end

