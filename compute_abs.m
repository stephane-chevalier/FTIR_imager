function Abs = compute_abs(S,path_bkg,calibrated,TI)
%Abs = compute_abs(S,path_bkg)
%   S : 3D matrix of a IR spectrum (sample)
% path_back : path to the IR spectrum of the background
% calibrated for calibrated background
% TI : integration time used for the sample

disp('Computing the absorbance matrix');


if calibrated == 0
    data_bkg = load([path_bkg,'pt/data.mat']);
    S_bkg = data_bkg.Spectre;
else
    data_bkg = struct2array(load(path_bkg));
    S_bkg = data_bkg*TI;    
end

for i = 1:size(S_bkg,3)
    Abs(:,:,i) = -log10(imdivide(S(:,:,i),S_bkg(:,:,i)));
end

end

