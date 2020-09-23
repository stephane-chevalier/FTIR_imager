function [image3D,data_cam,im_therm,temps,fullimage] = chargement_PTW(nom,therm,N_therm,x,y)
    % [image3D,temps] = chargement_PTW(nom,x,y)
    % La sortie temps est optionnelle ainsi que les entrée x et y.
    %
    % Charge des stacks d'image PTW en matrice 3D (x,y,t)
    % Le ROI est défini par un vecteur x et y
    % Si on souhaite toute l'image ne pas indiquer de x et y
    % fullimage = renvoi l'image entière (optionel)


    
    if isempty(nom)
     disp('Le fichier n''existe pas, vérifier le nom')
     return
    end
    
    
    disp(['Chargement de ',nom,' en cours'])
    [temps,image3D,fileinfo,fullimage] = chargement_ptw_sans_interface(nom,x,y);
    
    data_cam = struct('freq',round(1./fileinfo.m_frameperiode),...
        'TI',fileinfo.m_integration/1e-6); % load camera settings   
    
    % extrait la thermique et la soustrait  
     if therm == 1 % on enlève la thermique ici
        im_therm = mean(image3D(:,:,end-N_therm:end),3);
        image3D = image3D - im_therm(:,:);
        disp('Thermique soustraite')
     else 
         im_therm = [];
     end
    
    
end

