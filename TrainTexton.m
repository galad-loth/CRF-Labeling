function modelTexton=TrainTexton(dataInfo)
filters=makeLMfilters;
numTrainImg=min(64,length(dataInfo.trainImgList));
idxTraingImg=randperm(length(dataInfo.trainImgList));
idxTraingImg=idxTraingImg(1:numTrainImg);

numSampleFeatureOneImg=1000;
numSampleFeature=numTrainImg*numSampleFeatureOneImg;
sampleFeature=zeros(numSampleFeature,size(filters,3)*3);
for kk=1:numTrainImg
    disp(['Processing the ', num2str(kk),'-th image.']);
    imgFile=dataInfo.trainImgList{idxTraingImg(kk)};
    img=imread([dataInfo.imgPath,imgFile]);
    img=double(img);
    [nr,nc,nd]=size(img);
    featTemp=TextonFiltering(img,filters);
    sampleFeature(((kk-1)*numSampleFeatureOneImg+1):kk*numSampleFeatureOneImg,:)= ...
            featTemp(round(linspace(1,nr*nc,numSampleFeatureOneImg)),:);
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
[~,clusterMean]=kmeans(sampleFeatureWhitten, dataInfo.numTexton,'MaxIter', 150);

modelTexton.filters=filters;
modelTexton.normMean=meanFeat;
modelTexton.normVar=stdFeat;
modelTexton.matWhitten=matWhitten;
modelTexton.textonMean=clusterMean;