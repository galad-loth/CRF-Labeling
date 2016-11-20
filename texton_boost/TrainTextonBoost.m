function TrainTextonBoost()
dataInfo=SetMSRC21DataInfo();
[modelLocation, modelColor]=TrainColorLocation(dataInfo);

% figure(1);set(gcf,'position',[200,200,500,500]);
% for kk=1:dataInfo.numClass
%     imagesc(modelLocation(:,:,kk));
%     title(dataInfo.className(kk));
%     pause;
% end
 TrainTextureLayout(dataInfo);
