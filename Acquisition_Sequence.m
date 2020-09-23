
function [t,T]=Acquisition_Sequence(nomfich,s)
%Nomfich    : CHemin et nom du fichier à ouvrir
%s          : Les infos contenus dans le fichier .ptw, Ti, fréquence....
%seq        : (Ndeb,pas,Nfin) Le début (Ndeb), le pas (pas) et la fin (Nfin) de la séquence d'images à charger

%Boucle sur le nombre d'images
fid=fopen(nomfich,'r');
%Saut du header principal
fseek (fid, s.m_MainHeaderSize,'bof');
for i=1:s.m_nframes
    %récupération du temps
    fseek(fid,80,'cof');
    a=fread(fid,[1 4],'uint8=>char')';
    fseek(fid,76,'cof');
    b=fread(fid,[1 2],'uint8=>char')';
    t=[a(2) a(1) a(4) a(3) b(1) b(2)];
    t0(i)=t(1)*3600+t(2)*60+t(3)+t(4)/100+t(5)/1000+t(6)/1000000;
    %Récupération des images
    fseek (fid, s.m_MainHeaderSize+i*s.m_FrameHeaderSize+(i-1)*s.m_FrameSize*2,'bof'); %skip frame header
    a=fread(fid, [s.m_cols, s.m_rows],'uint16');
    T(:,:,i)=a';
end
fclose(fid); %close file
% Ar=reshape(A,s.m_cols,s.m_rows,s.m_nframes);
t=t0-t0(1);

end






