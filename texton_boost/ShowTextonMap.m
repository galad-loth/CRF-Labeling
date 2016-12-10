function ShowTextonMap()
dataInfo=SetMSRC21DataInfo();
load textonMapTest

numImg=length(dataInfo.trainImgList);
figure(1);set(gcf,'position',[200 400 1300 400])
for kk=1:numImg
    img=imread([dataInfo.imgPath,dataInfo.testImgList{kk}]);
    subplot(1,2,1);imagesc(img)
    subplot(1,2,2);imagesc(textonMapTest{kk},[0 128]);
    pause    
end