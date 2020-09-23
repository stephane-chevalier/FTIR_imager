function [inter_ac] = high_pass_filtering(inter,sizes)
% High pass filter for the signal to remove the contineous component
%  [inter_ac] = high_pass_filtering(inter,sizes)
%   inter : interferograms reshaped in one vector
%   sizes : sizes of the 3D matrices contining the interferograms


Ni = sizes(2);
Nj = sizes(1);
Nk = sizes(3);
inter_ac = zeros(Ni*Nj,Nk);
porte = ones(Nk,1);
porte([1:3 Nk-3:Nk],1)=0;


for j = 1:Nj*Ni
    inter_ac(j,:) = real(ifft(fft(inter(j,:)).*porte'));
end

figure(20);
clf
plot(1:Nk,squeeze([inter(round(Ni*Nj/2),:); inter_ac(round(Ni*Nj/2),:)]'))
legend('before filtering','after filtering')
end




