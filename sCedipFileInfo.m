function s = sCedipFileInfo(s)
% SEQUENCE :: SCEDIPFILEINFO
%   Copyright (c) Alexander Dillenz 2000-2001
%
% for documentation see manuelrf.doc

fid=fopen(s.m_filename,'r');
if fid==-1
    error('fileopen');
end; %if

fseek(fid, 11, 'bof');
s.m_MainHeaderSize=fread(fid,1,'int32');
s.m_FrameHeaderSize=fread(fid,1,'int32');
fseek(fid, 27, 'bof');
s.m_nframes=fread(fid,1,'int32');


fseek(fid, 245, 'bof');
s.m_minlut=fread(fid,1,'int16');
s.m_maxlut=fread(fid,1,'int16');
if(s.m_maxlut==-1)
    s.m_maxlut=2^16-1;
end; %if
fseek(fid, 277, 'bof');
s.m_specialscale=fread(fid,1,'uint16'); % Special scale (Echelle Speciale)
scaleunit=fread(fid,10,'char');
s.m_scalevalue=fread(fid,17,'float');
if(s.m_specialscale==0)
    s.m_unit='dl';                           % [dl T rad]
   
else
    s.m_unit=scaleunit;                   % [dl T rad]
 
end; %if

fseek(fid, 377, 'bof');
s.m_cols=fread(fid,1,'uint16'); % Columns
s.m_rows=fread(fid,1,'uint16'); % Rows
if s.m_rows==0 
   s.m_rows=128;
end;%if
if s.m_cols==0 
   s.m_cols=128;
end;%if
s.m_bitres=fread(fid,1,'uint16'); % bit resolution
fseek(fid, 403, 'bof');
s.m_frameperiode = fread(fid,1,'float'); % frame rate
s.m_integration =  fread(fid,1,'float'); % integration time

fseek(fid, 563, 'bof');
s.m_comment=fread(fid,1000,'char');

fseek(fid, 1563, 'bof');
s.m_calibration=fread(fid,100,'char'); % calibration file name

fseek(fid,s.m_MainHeaderSize,'bof'); %skip main header
fseek(fid,s.m_FrameHeaderSize,'cof'); %skip frame header
firstline = fread(fid, [s.m_cols, 1], 'uint16'); %read one line
% look if first line contains lockin information
if(firstline(1:4)==[1220,3907,1204,2382]')
    s.m_cedip_lockin=1;
    s.m_rows=s.m_rows-1;
else
    s.m_cedip_lockin=0;
end; %if
s.m_framepointer=1;
s.m_firstframe=1;
s.m_cliprect=[0 0 s.m_cols-1 s.m_rows-1];
s.m_lastframe=s.m_nframes;
s.m_FrameSize = s.m_FrameHeaderSize + s.m_cols * s.m_rows * 2;

fclose(fid); %close file
clear fid firstline scaleunit;
return;