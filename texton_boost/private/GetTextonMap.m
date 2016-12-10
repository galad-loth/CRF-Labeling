function textonMap=GetTextonMap(modeltexton,imgPath,imgList)
numImg=length(imgList);
textonMap=cell(1,numImg);
cform=makecform('srgb2lab');
for kk=1:numImg
    disp(['Processing the ', num2str(kk),'-th image.']);
    imgFile=imgList{kk};
    img=imread([imgPath,imgFile]);
    img=applycform(img,cform);
    img=double(img);
    [nr,nc,nd]=size(img);
    featTemp=TextonFiltering(img,modeltexton.filters);
    featTemp=bsxfun(@minus,featTemp,modeltexton.normMean);
    featTemp=bsxfun(@times,featTemp,1./(modeltexton.normVar));
    featTemp=featTemp*modeltexton.matWhitten;
    matDist=pdist2(featTemp,modeltexton.textonMean);
    [~,textonLabel]=min(matDist,[],2);
    textonLabel=reshape(textonLabel,[nr nc]);
    textonMap{kk}=textonLabel;    
end

