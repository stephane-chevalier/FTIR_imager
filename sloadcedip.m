function s = sloadcedip(s)
% SEQUENCE :: SLOADCEDIP
% loadcedip reads a Cedip-PTW file into matrix result
%   Copyright (c) Alexander Dillenz 2000-2001
% for documentation see manuelrf.doc

% check filename
if (isempty(s.m_filename))
    error('file not assigned');
end; %if

% open file
fid=fopen(s.m_filename,'r');
if fid==-1
    error('file open');
end; %if

% skip main header
fseek (fid, s.m_MainHeaderSize,'bof'); 

if(s.m_cedip_lockin) % lockin -> skip first line
   fseek (fid, (s.m_framepointer-1) * (s.m_FrameSize + 2*s.m_cols), 'cof');  
else
   fseek (fid, (s.m_framepointer-1) * (s.m_FrameSize), 'cof');
end; %if

fseek(fid,s.m_FrameHeaderSize,'cof'); %skip frame header

s.m_data = fread(fid, [s.m_cols, s.m_rows],'uint16'); %read one frame
% if a special scale is given then transform the data
if(s.m_specialscale)
    low = min(s.m_scalevalue);
    high = max(s.m_scalevalue);
    s.m_data = s.m_data .* (high-low)./ 2^16 + low; 
    clear low high;
end; %if
if(s.m_cedip_lockin) % lockin -> skip first line
    s.m_cliprect = [0 1 s.m_cols-1 s.m_rows];
end; %if
s.m_minval = min(min(s.m_data(1:s.m_cols,2:s.m_rows)));
s.m_maxval = max(max(s.m_data(1:s.m_cols,2:s.m_rows)));
%récupération du temps
fseek (fid, s.m_MainHeaderSize,'bof');
fseek (fid, (s.m_framepointer-1) * (s.m_FrameSize), 'cof');
fseek(fid,80,'cof');
a=fread(fid,[1 4],'uint8=>char')';
fseek(fid,76,'cof');
b=fread(fid,[1 2],'uint8=>char')';
t=[a(2) a(1) a(4) a(3) b(1) b(2)];
s.m_time=t(1)*3600+t(2)*60+t(3)+t(4)/100+t(5)/1000+t(6)/1000000;
fclose(fid); %close file
return;




















