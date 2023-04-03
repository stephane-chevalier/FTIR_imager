function [A,time] = Chargement_New ( name)


fid=fopen(name,'r');
% fid=fopen('resistance_Socool5.ptw','r');

% -------------------------------------------------------------------------
%                           Données globales
% -------------------------------------------------------------------------

%µµµµµµµµµµµµµµµµµµµµµµµµµµ Tailles images, header.... µµµµµµµµµµµµµµµµµµµµ
fseek(fid, 11, 'bof');
s.m_MainHeaderSize=fread(fid,1,'int32');
fseek(fid, 15, 'bof');
s.m_FrameHeaderSize=fread(fid,1,'int32');
fseek(fid, 19, 'bof');
s.m_Frame_Plus_HeaderSize=fread(fid,1,'int32');
fseek(fid, 23, 'bof');
s.m_FrameSize=fread(fid,1,'int32');

%µµµµµµµµµµµµµµµµµµµµµµµµµµ Tailles images réelle.... µµµµµµµµµµµµµµµµµµµµ
fseek(fid, 27, 'bof');
s.m_nframes=fread(fid,1,'int32');
fseek(fid, 377, 'bof');
s.m_cols=fread(fid,1,'uint16'); % Columns
s.m_rows=fread(fid,1,'uint16'); % Rows
s.m_bitres=fread(fid,1,'uint16'); % bit resolution

%µµµµµµµµµµµµµµµµµµµµµµµµµµ Acquisition.... µµµµµµµµµµµµµµµµµµµµµµµµµµµµµµµ
fseek(fid, 403, 'bof');
s.m_frameperiode = fread(fid,1,'float'); % frame rate
s.m_integration =  fread(fid,1,'float'); % integration time

%Calcul données nécessaires
% s.m_FrameSize = s.m_FrameHeaderSize + s.m_cols * s.m_rows * 2;
s.taille_image=s.m_cols*s.m_rows;
%boucle de récupération des images
fseek (fid, s.m_MainHeaderSize,'bof');
%Boucle sur le nombre d'images
for i=1:s.m_nframes
    %récupération du temps
    fseek(fid,80,'cof');
    a=fread(fid,[1 4],'uint8=>char')';
    fseek(fid,76,'cof');
    b=fread(fid,[1 2],'uint8=>char')';
    t=[a(2) a(1) a(4) a(3) b(1) b(2)];
    time(i)=t(1)*3600+t(2)*60+t(3)+t(4)/100+t(5)/1000+t(6)/1000000;    
    %Récupération des images
    fseek (fid, s.m_MainHeaderSize+i*s.m_FrameHeaderSize+(i-1)*s.m_FrameSize*2,'bof'); %skip frame header
    A(:,:,i)=fread(fid, [s.m_cols, s.m_rows],'uint16')';
    %
end

% Ar=reshape(A,s.m_cols,s.m_rows,s.m_nframes);
% t=time-time(1);
fclose(fid); %close file
% toc

end



% 
% tic;
% info=fread(fid,11,'int8');%skip the first 11 bytes
% toc
% tic;
% fseek(fid,27,'bof');
% toc
% tic;
% fseek(fid,27,'cof');
% toc
% tic;
% s.nbimage=fread(fid,1,'int32')
% toc


