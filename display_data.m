function display_data(px,x,y,fullimage,Smean,im_therm,interfero,inter_apo,l,nub)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

freq = round(length(nub)/2); % indice de la fréquence

figure(1)
clf
subplot(2,3,1)
imagesc(fullimage)
hold on
rectangle('Position',[x(1) y(1) x(end)-x(1) y(end)-y(1)])
hold off
daspect([1 1 1])
colorbar
title('Intensité en DL')

subplot(2,3,2)
imagesc(Smean(:,:,freq))
hold on
plot(px(1),px(2),'sk')
title(['Fréquence : ',num2str(nub(freq)),' cm-1'])
daspect([1 1 1])
colorbar

subplot(2,3,3)
imagesc(im_therm)
title(['Average thermal image (DL)'])
daspect([1 1 1])
colorbar
colormap('hot')



subplot(2,3,4)
hold on
for n = 1:size(interfero,2)
    imageplot = interfero{n};
    plot(l,squeeze(imageplot(px(2),px(1),:)))
end
hold off
xlabel('Retard optique en cm')
ylabel('Intensité en DL')
title('interfero')

subplot(2,3,5)
plot(l,squeeze(inter_apo))
xlabel('Retard optique en cm')
ylabel('Intensité en DL')
title('Apodization')

subplot(2,3,6)
set(gca, 'Xdir', 'reverse','Xscale','log');
hold on
plot(nub,squeeze(Smean(px(2),px(1),:)),'r');%xlim([1500 4000])
%plot(nub0,squeeze(mean(mean(Smean))));%xlim([1500 4000])
grid on
xlabel('Nombre d''onde en cm-1')
ylabel('Intensité en DL/cm-1')
title('Spectre')

drawnow;
end

