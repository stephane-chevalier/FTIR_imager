function Abs = compute_abs(S,path_bkg)
%Abs = compute_abs(S,path_bkg)
%   S : 3D matrix of a IR spectrum (sample)
% path_back : path to the IR spectrum of the background

disp('Computing the absorbance matrix');


data_bkg = load([path_bkg,'pt/data.mat']);
S_bkg = data_bkg.Spectre;

for i = 1:size(S_bkg,3)
    Abs(:,:,i) = -log10(imdivide(S(:,:,i),S_bkg(:,:,i)));
end

end

