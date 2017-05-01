function TrainTextonBoost()
dataInfo=SetMSRC21DataInfo();

%Training color-location model
% disp('Training color-location model...')
% [modelLocation, modelColor]=TrainColorLocation(dataInfo);
% save('data\modelLocation.mat','modelLocation');
% save('data\modelColor.mat', 'modelColor');
% 
% figure(1);set(gcf,'position',[200,200,500,500]);
% for kk=1:dataInfo.numClass
%     imagesc(modelLocation(:,:,kk));
%     title(dataInfo.className(kk));
%     pause;
% end

%Training texton model
% disp('Training texton model...')
% modelTexton=TrainTexton(dataInfo);
% save('data\modelTexton.mat','modelTexton');

% load('data\modelTexton.mat')
% disp('Extracting texton map...')
% textonMapTrain=GetTextonMap(modelTexton,dataInfo.imgPath,dataInfo.trainImgList);
% save('data\textonMapTrain.mat','textonMapTrain')
% clear textonMapTrain
% textonMapTest=GetTextonMap(modelTexton,dataInfo.imgPath,dataInfo.testImgList);
% save('data\textonMapTest.mat','textonMapTest')

% Get texture-layout feature
disp(' Get texture-layout feature...')
regionLayout=int32([-9,9,-9,9; -15,15,-15,15; -21, 21,-21,21;
    -18,0,-9,9;0,18,-9,9;-9,9,-18,0;-9,9,0,18;
    -18,18,-9,0;-18,18,0,9;-9,0,-18,18;0,9,-18,18;
    -18,-9,-18,-9;-18,-9,9,18;9,18,-18,-9;9,18,9,18]);
subSampleGrid=13;
load('data\textonMapTrain.mat')
fid=fopen('data\featTextureLayout.csv','w');
for kk=1:length(textonMapTrain)
     disp(['Processing the ', num2str(kk),'-th image.']);
    map=textonMapTrain{kk}-1;
    featTextureLayout=MexGetTextonLayout(int32(map),dataInfo.numTexton,regionLayout);
    imgFile=dataInfo.trainImgList{kk};
    gtImgFile=GetGtImgFile(imgFile, dataInfo.dataset);
    gtImg=imread([dataInfo.gtPath,gtImgFile]);
    gtLabel=InvClassMap(gtImg,int32(dataInfo.colormap), dataInfo.numClass);
    [nr,nc]=size(gtLabel);
    gtLabel=reshape(gtLabel,[nr*nc 1]);
    for ic=subSampleGrid:subSampleGrid:nc
        for ir=subSampleGrid:subSampleGrid:nr
            ip=(ic-1)*nr+ir;
             fprintf(fid, '%d,', gtLabel(ip));
            fprintf(fid, '%f,', featTextureLayout(:, ip)');
            fprintf(fid,'\n');
        end
    end
end
fclose(fid);
