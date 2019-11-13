function [S,nub,inter_apo] = I2S(inter,l,res,a)
    % [S,nub] = I2S(inter,l,res,a)
    % Transforme l'int�ro en spectre avec une appodization de type
    % gaussienne : exp(-(sigma*(l)*res).^2)
    % inter_appo : renvoi le spectre appodiz� au pixel Ni,Nj (option)
    %
    % inter : interf�rogramme (matrice ou vecteur)
    % l : position du miroir en cm
    % res : r�solution
    % a : param�tre d'appodization (a = 0 si pas d'appodization, a = 10-15
    % sinon)

    sizes = size(inter); %taille de la matrice    
    Ni = sizes(2);
    Nj = sizes(1);
    Nk = sizes(3);
    
    % coef apodization
    sigma = a*Nk/4113; %4113 est une valeur de r�f�rence pour res = 4 cm-1
    
    % distance between two frames
    dl = l(2)-l(1);   

    % On reshape pour gagner en temps de calcul    
    inter_reshaped = reshape(inter,Ni*Nj,Nk);
    S_reshaped = zeros(Ni*Nj,(Nk-1)/2);
    
    % execution de la fft
    for j = 1:Nj*Ni    
        [S_reshaped(j,:),~,nub] = mpfft(inter_reshaped(j,:).*exp(-(sigma*(l)*res).^2)',l); % FFT
    end
    
    disp('Calcul fft termin�')
    
    if nargout == 3
        inter_apo = inter_reshaped(Ni*Nj,:)'.*exp(-(sigma*(l)*res).^2);
    end
    S = reshape(S_reshaped,Nj,Ni,size(S_reshaped,2));
end

