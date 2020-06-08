function [Smean,im_therm] = average_data(S_tab,im_therm_tab)
%[Smean,im_therm] = average_data(S_tab,im_therm_tab)
% S_tab : table containing the image spectra
% im_therm : thermal images (3D matrix)

N = size(S_tab,2); % number of spectra
for n = 1:N
    if n == 1
        Smean = S_tab{n}/N;
    else
        Smean = Smean + S_tab{n}/N;
    end
end

im_therm = mean(im_therm_tab,3);

end
