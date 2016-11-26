function [modelLocation, modelColor]=TrainColorLocation(dataInfo)
if isempty(dataInfo.trainImgList)
    error('The train image list is empty');
end
numClass=dataInfo.numClass;
normSize=dataInfo.normSize;
modelLocation=zeros(normSize*normSize,numClass);
colormap=dataInfo.colormap;
numTrainImg=length(dataInfo.trainImgList);
numColorData=200000;
colorData=zeros(numColorData,3);
numColorSample=floor(numColorData/numTrainImg);
numColorData=numColorSample*numTrainImg;
for kk=1:numTrainImg
    disp(kk)
    imgFile=dataInfo.trainImgList{kk};
    gtImgFile=GetGtImgFile(imgFile, dataInfo.dataset);
    img=imread([dataInfo.imgPath,imgFile]);   
    gtImg=imread([dataInfo.gtPath,gtImgFile]);
    [nr,nc,nd]=size(img);
    [nrGt,ncGt,ndGt]=size(gtImg);
    imgData=double(reshape(img,[nr*nc nd]));
    colorData(((kk-1)*numColorSample+1):kk*numColorSample,:)= ...
            imgData(round(linspace(1,nr*nc,numColorSample)),:)/100.0;
    prNorm=round(linspace(1,nrGt,normSize));
    pcNorm=round(linspace(1,ncGt,normSize));
    ppNorm=repmat(prNorm',[1 normSize])+(repmat(pcNorm-1,[normSize 1]))*nrGt;
    gtImg=reshape(gtImg,[nrGt*ncGt, ndGt]);
    gtImgNorm=gtImg(ppNorm,:);
    for cc=1:numClass
        idx=(gtImgNorm(:,1)==colormap(cc,1))&(gtImgNorm(:,2)==colormap(cc,2)) ...
            &(gtImgNorm(:,3)==colormap(cc,3));
        modelLocation(idx,cc)=modelLocation(idx,cc)+1;
    end
end
colorData=colorData(1:numColorData,:);
[colorClusterIdx, colorClusterMean]=kmeans(colorData, dataInfo.numColorCluster, ...
    'MaxIter', 150);
modelColor=cell(1,dataInfo.numColorCluster);
for kk=1:dataInfo.numColorCluster
    modelColor{kk}.mu=100*colorClusterMean(kk,:);
    modelColor{kk}.sigma=cov(100*colorData(colorClusterIdx==kk,:));
end
modelLocation=modelLocation/numTrainImg;
modelLocation=reshape(modelLocation,[normSize normSize numClass]);
