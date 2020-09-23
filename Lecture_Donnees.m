function [s]=Lecture_Donnees(nomfich)

fid=fopen(nomfich,'r');

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
fclose(fid); %close file

end

