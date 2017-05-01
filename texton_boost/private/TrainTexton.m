function modelTexton=TrainTexton(dataInfo)
filters=MakeTextonFilters;
cform=makecform('srgb2lab');
numTrainImg=min(96,length(dataInfo.trainImgList));
idxTraingImg=randperm(length(dataInfo.trainImgList));
idxTraingImg=idxTraingImg(1:numTrainImg);

numSampleFeatureOneImg=1000;
numSampleFeature=numTrainImg*numSampleFeatureOneImg;
sampleFeature=zeros(numSampleFeature,17);
sampleColor=zeros(numSampleFeature,3);
for kk=1:numTrainImg
    disp(['Processing the ', num2str(kk),'-th image.']);
    imgFile=dataInfo.trainImgList{idxTraingImg(kk)};
    img=imread([dataInfo.imgPath,imgFile]);
    [nr,nc,nd]=size(img);
    colorData=reshape(img, [nr*nc nd]);
    img=applycform(img,cform);
    img=double(img);     
    featTemp=TextonFiltering(img,filters);
    sampleFeature(((kk-1)*numSampleFeatureOneImg+1):kk*numSampleFeatureOneImg,:)= ...
            featTemp(round(linspace(1,nr*nc,numSampleFeatureOneImg)),:);
    sampleColor(((kk-1)*numSampleFeatureOneImg+1):kk*numSampleFeatureOneImg,:)=...
        colorData(round(linspace(1,nr*nc,numSampleFeatureOneImg)),:);
end

sampleFeature=sampleFeature(1:numSampleFeature,:);
meanFeat=mean(sampleFeature,1);
stdFeat=std(sampleFeature);
stdFeat(stdFeat==0)=10*eps;
sampleFeature=bsxfun(@minus,sampleFeature,meanFeat);
sampleFeature=bsxfun(@times,sampleFeature,1./(stdFeat));

sampleFeatureCov=sampleFeature'*sampleFeature/numSampleFeature;
[eigVecs, eigVals]=eig(sampleFeatureCov);
diagEigVals = diag(1./sqrt(diag(eigVals)+1e-8));
matWhitten=eigVecs*diagEigVals*eigVecs';
sampleFeatureWhitten=sampleFeature*matWhitten;

disp('Perform K-Means clustering...')
[idxCluster,clusterMean]=kmeans(sampleFeatureWhitten, dataInfo.numTexton,'MaxIter', 100);
colormap=zeros(dataInfo.numTexton,nd);
for k=1:dataInfo.numTexton
    colormap(k,:)=mean(sampleColor(idxCluster==k,:),1);
end
modelTexton.filters=filters;
modelTexton.normMean=meanFeat;
modelTexton.normVar=stdFeat;
modelTexton.matWhitten=matWhitten;
modelTexton.textonMean=clusterMean;
modelTexton.colormap=colormap;
