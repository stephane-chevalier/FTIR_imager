function [S,nub,inter_apo] = I2S(inter,l,res,a,lmax)
    % [S,nub] = I2S(inter,l,res,a)
    % Transforme l'intéro en spectre avec une appodization de type
    % gaussienne : exp(-(sigma*(l)*res).^2)
    % inter_appo : renvoi le spectre appodizé au pixel Ni,Nj (option)
    %
    % inter : interférogramme (matrice ou vecteur)
    % l : retard optique en cm
    % res : résolution
    % a : paramètre d'appodization (a = 0 si pas d'appodization, a = 10-15
    % sinon)
    % S : spectrum in the inetresting band (low frequencies are left over)
    disp('Exécution de la fft avec appodisation')
    
    sizes = size(inter); % taille de la matrice    
    Ni = sizes(2);
    Nj = sizes(1);
    Nk = sizes(3);
    
    % coef apodization
    sigma = a*Nk/4111; %4111 est une valeur de référence pour res = 4 cm-1
    f_apo = exp(-(sigma*l*res).^2);
    
    % distance between two frames
    dl = l(2)-l(1);   

    % On reshape pour gagner en temps de calcul    
    inter_reshaped = reshape(inter,Ni*Nj,Nk);
        
    % compute the fft with the phase correction based on Mertz methods
    S_reshaped = fft_with_Mertz(inter_reshaped,f_apo,Ni,Nj);
    
    % build the frequency vector
    nub = linspace(0,1/dl,length(l));
    nub(round(length(nub)/2):length(nub))=[];  
    
    disp('Calcul fft terminé')
    
    if nargout == 3
        inter_apo = inter_reshaped(Ni*Nj,:)'.*f_apo;%exp(-(sigma*(l)*res).^2);
    end
    
    S = reshape(S_reshaped,Nj,Ni,size(S_reshaped,2));
    
    % on ne garde que la bande spectrale utile entre f2 et f1
    S = S(:,:,nub>10000/lmax);
    nub = nub(:,nub>10000/lmax)';
end

