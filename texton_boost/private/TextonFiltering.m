function resFeat=TextonFiltering(img,filters)
[filterHeight,filterWidth,filterNum]=size(filters);
[nr,nc,nd]=size(img);
dimFeat=17;
resFeat=zeros(nr*nc,dimFeat);
padWidth=ceil(max(filterHeight/2,filterWidth/2));
imgPad=padarray(img,[padWidth,padWidth,0],'symmetric','both');
idxFeatDim=1;
for ii=1:3
    imgTmp=imgPad(:,:,ii);
    for jj=1:3
        imgFilt=conv2(imgTmp,filters(:,:,jj),'same');
        imgFilt=imgFilt(padWidth+1:padWidth+nr,padWidth+1:padWidth+nc);
        resFeat(:,idxFeatDim)=imgFilt(:);
        idxFeatDim=idxFeatDim+1;
    end
end
for jj=4:filterNum
     imgFilt=conv2(imgPad(:,:,1),filters(:,:,jj),'same');
     imgFilt=imgFilt(padWidth+1:padWidth+nr,padWidth+1:padWidth+nc);
     resFeat(:,idxFeatDim)=imgFilt(:);
     idxFeatDim=idxFeatDim+1;
end


% dimFeat=nd*filterNum;
% resFeat=zeros(nr*nc,dimFeat);
% padWidth=ceil(max(filterHeight/2,filterWidth/2));
% if nd==1   
%     imgPad=padarray(img,[padWidth,padWidth],'symmetric','both');
% else
%     imgPad=padarray(img,[padWidth,padWidth,0],'symmetric','both');
% end
% 
% for ii=1:nd
%     imgTmp=imgPad(:,:,ii);
%     for jj=1:filterNum
%         imgFilt=conv2(imgTmp,filters(:,:,jj),'same');
%         imgFilt=imgFilt(padWidth+1:padWidth+nr,padWidth+1:padWidth+nc);
%         resFeat(:,(ii-1)*filterNum+jj)=imgFilt(:);
%     end
% end