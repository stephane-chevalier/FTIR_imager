function save_data(Smean,x,y,data_cam,coef_apo,noms,v,res,nub,im_therm,path)
% save the data from the interfero processing

%% Sauvegarde
data = struct;
data.Spectre =Smean;
data.ROI_x=x;
data.ROI_y=y;
data.TI=data_cam.TI;
data.coef_apo=coef_apo;
data.filename=noms;
data.v_miroir=v;
data.f_acq=data_cam.freq;
data.resolution=res;
data.nub = nub;
data.im_therm = im_therm;



% inter = struct;
% inter.interogrammes=interfero;
% inter.position_miroir = l;


disp('Saving....')

mkdir([path,'pt'])
save([path,'pt/data.mat'],'-struct','data')
%save([path,'pt/interferos.mat'],'-struct','inter')
save2pdf([path,'pt/figure.pdf'],gcf,300)

disp('Fin du traitement des interféros')

end

