function [M,P,f] = mpfft(X,t,N)
%
% Decomposition module phase de la FFT
% [Module,Phase,Freq] = mpfft(X,t)
%
dt=t(2)-t(1);
if nargin==3
    M=2*fft(X,N)/length(t); 
    f=linspace(0,1/dt,length(M));
else
    M=2*fft(X,length(t))/length(t); 
    f=linspace(0,1/dt,length(M));
end
P=180/pi*atan2(imag(M),real(M));
f(round(length(f)/2):length(f))=[];    
M=abs(M);
M(round(length(M)/2):end)=[]; % on ne prend que la moitié du spectre
%M(1)=M(1)/2;
P(round(length(P)/2):length(P))=[];


