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
    dl = l(2)-l(1);
    
    if  length(sizes) == 3
        Ni = sizes(2);
        Nj = sizes(1);
        sigma = a/10000*sizes(3);
    else
        Ni = 1;
        Nj= 1;
        sigma = a/10000*sizes(1);
    end
    
    for i = 1:Ni
        if ~isempty(find(i == 1:round(Ni/9):Ni))
            disp(['Calcul fait.... � ',num2str(round(i/Ni*100)),'%'])
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
    disp('Calcul fft termin�')
    
    if nargout == 3
        inter_apo = inter_temp.*exp(-(sigma*(l)*res).^2);
    end
end

