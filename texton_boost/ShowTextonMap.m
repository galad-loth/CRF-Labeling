function ShowTextonMap()
dataInfo=SetMSRC21DataInfo();
load textonMapTrain
load('data\modelTexton.mat')

numImg=length(dataInfo.trainImgList);
figure(1);set(gcf,'position',[200 400 1300 400])
for kk=1:numImg
    img=imread([dataInfo.imgPath,dataInfo.trainImgList{kk}]);
    subplot(1,2,1);imagesc(img)
    classmap=GetClassMap(textonMapTrain{kk}-1,modelTexton.colormap);
    subplot(1,2,2);imagesc(classmap);
    pause    
end
