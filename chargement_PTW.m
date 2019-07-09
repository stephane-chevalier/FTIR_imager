function [image3D,temps,fullimage] = chargement_PTW(nom,x,y)
    % [image3D,temps] = chargement_PTW(nom,x,y)
    % La sortie temps est optionnelle ainsi que les entrée x et y.
    %
    % Charge des stacks d'image PTW en matrice 3D (x,y,t)
    % Le ROI est défini par un vecteur x et y
    % Si on souhaite toute l'image ne pas indiquer de x et y
    % fullimage = renvoi l'image entière (optionel)


    
    if isempty(nom)
     disp('Le fichier n''existe pas,, vérifier le nom')
     return
    end
    
    
    disp(['Chargement de ',nom,' en cours'])
    [t0,~,fileinfo] = GetPTWFrame(nom,1);
    N=fileinfo.m_nframes;

    for ii = 1:N
        [t_temp,temp0,~] = GetPTWFrame(nom,ii);
        
        
        if nargout > 1
            temps(ii,1) = t_temp-t0; % temps lu dans les images            
        end
        
        if ~isempty(find(ii == 1:round(N/9):N))
            disp(['Chargement.... à ',num2str(round(ii/N*100)),'%'])
        end
        
        if nargin > 1
            image3D(:,:,ii) = temp0(y,x);
        else
            image3D(:,:,ii) = temp0;
        end
    end
    
    if nargout == 3 %renvoi l'image entière
       fullimage = temp0;
    end
    
end

