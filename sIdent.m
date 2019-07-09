% SEQUENCE :: SIDENT
% identify sequence file
%
%   Copyright (c) Alexander Dillenz 2000-2001

function s = sIdent(s)
warning off
if (isempty(s.m_filename))
    error('file not assigned');
end; %if
fid=fopen(s.m_filename,'r');
info=fread(fid,11,'int8');%skip the first 11 bytes
fclose(fid); %close file

switch(char(info(1:3))')
case 'AI0' %AGEMA
    s.m_format='agema';

case 'CED'
    s.m_format='cedip';
    s.m_unit='dl';
    s = sCedipFileInfo(s);
    
otherwise
    s.m_format='unknown';
    
end; %switch
return;
