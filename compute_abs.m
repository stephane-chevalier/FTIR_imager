function Abs = compute_abs(Smean,path_bkg)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

disp('Computing the absorbance matrix');


data_bkg = load([path_bkg,'pt/data.mat']);
S_bkg = data_bkg.Spectre;

S_bkg_reshape = reshape(S_bkg,[size(S_bkg,1)*size(S_bkg,2) size(S_bkg,3)]);
Smean_reshape = reshape(Smean,[size(S_bkg,1)*size(S_bkg,2) size(S_bkg,3)]);


for i = 1:size(S_bkg,3)
    Abs_reshape = Smean_reshape./S_bkg_reshape;
end

Abs = -log10(reshape(Abs_reshape,[size(S_bkg,1) size(S_bkg,2) size(S_bkg,3)]));


end

