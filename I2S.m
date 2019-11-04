function [S,nub,inter_apo] = I2S(inter,l,res,a)
    % [S,nub] = I2S(inter,l,res,a)
    % Transforme l'intéro en spectre avec une appodization de type
    % gaussienne : exp(-(sigma*(l)*res).^2)
    % inter_appo : renvoi le spectre appodizé au pixel Ni,Nj (option)
    %
    % inter : interférogramme (matrice ou vecteur)
    % l : position du miroir en cm
    % res : résolution
    % a : paramètre d'appodization (a = 0 si pas d'appodization, a = 10-15
    % sinon)

    sizes = size(inter); %taille de la matrice    
    Ni = sizes(2);
    Nj = sizes(1);
    
    % coef apodization
    sigma = a*sizes(3)/4113;
    
    % distance between two frames
    dl = l(2)-l(1);
    
    for i = 1:Ni
        if ~isempty(find(i == 1:round(Ni/9):Ni))
            disp(['Calcul fait.... à ',num2str(round(i/Ni*100)),'%'])
        end
        for j = 1:Nj
            if  length(sizes) == 3
                inter_temp = squeeze(inter(j,i,:));                
            else 
                inter_temp = inter;
            end
            inter_temp = inter_temp.*exp(-(sigma*(l)*res).^2); % appodization

            [S(j,i,:),~,nub] = mpfft(inter_temp,l); % FFT
        end
    end
    disp('Calcul fft terminé')
    
    if nargout == 3
        inter_apo = inter_temp.*exp(-(sigma*(l)*res).^2);
    end
end

