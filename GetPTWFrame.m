%
%                       GETPTWFRAME
% 
% SYNATX:     [data, fileinfo] = GetPTWFrame (filename, frameindex)
%
% loads frame number "frameindex" from a PTW file "filename"
%
% result:
%
% data      contains imagedata on succes, 0 otherwise
% fileinfo      is a structure with information about the ptw file
%
% documentation: see manuelrf.doc by CEDIP
%
%   Copyright (c) Alexander Dillenz 2001


function [t,data, fileinfo] = GetPTWFrame (filename, frameindex)
warning off
data = 0;
s.m_filename = filename;
s = sIdent (s);
fileinfo = s;

if(s.m_format~='cedip')
    disp('Error: file format is not supported');
    result = -1;
else
    s = sCedipFileInfo (s);
    if(frameindex <= s.m_lastframe & frameindex>0) % ok
        
        s.m_framepointer = frameindex;
        s = sloadcedip(s);
        data = s.m_data';
        t=s.m_time;
        clear s;
    else                            % frameindex exceeds no of frames
        disp('Error: cannot load frame. Frameindex exceeds sequence length.');
    end;
    
end;

