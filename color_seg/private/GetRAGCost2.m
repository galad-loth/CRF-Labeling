function [dataCost, neighborWeights]=GetRAGCost2(img,spLabel,trainSpFlag)
[nr,nc,nd]=size(img);
imgData=reshape(img,[nr*nc nd]);
numSp=max(spLabel(:))+1;
numRegion=2;
dataCost=zeros(numRegion, numSp);
neighborWeights=zeros(numSp,numSp);

spMeanColor=zeros(numSp,nd);
spSize=zeros(numSp,1);
dr=[1,0,0,-1];
dc=[0,1,-1,0];
for pc=1:nc
    for pr=1:nr
        idxPixel=pr+(pc-1)*nr;
        spLabelPixel=spLabel(idxPixel)+1;
        spMeanColor(spLabelPixel,:)=spMeanColor(spLabelPixel,:)+imgData(idxPixel,:);
        spSize(spLabelPixel)=spSize(spLabelPixel)+1;
        for ii=1:4
            pcs=pc+dc(ii);
            prs=pr+dr(ii);
            if (pcs>0 && pcs<nc && prs>0 && prs<nr)
                spLabelNearPixel=spLabel(prs,pcs)+1;
                if (spLabelNearPixel~=spLabelPixel)
                    neighborWeights(spLabelPixel,spLabelNearPixel)=1;
                    neighborWeights(spLabelNearPixel,spLabelPixel)=1;
                end
            end       
        end
    end
end

spMeanColor=spMeanColor./(eps+repmat(spSize,[1 nd]));

vecMeanColorFg=spMeanColor(trainSpFlag==1,:);
numSpFg=size(vecMeanColorFg,1);
vecMeanColorBg=spMeanColor(trainSpFlag==2,:);
numSpBg=size(vecMeanColorBg,1);

for ii=1:numSp
    diffColor=repmat(spMeanColor(ii,:),[numSpFg 1])-vecMeanColorFg;
    diffColor=min(sum(diffColor.^2,2));
    dataCost(1,ii)=1-exp(-diffColor/3000);
    diffColor=repmat(spMeanColor(ii,:),[numSpBg 1])-vecMeanColorBg;
    diffColor=min(sum(diffColor.^2,2));
    dataCost(2,ii)=1-exp(-diffColor/3000);
end

for ii=1:numSp
    for jj=ii+1:numSp
        if neighborWeights(ii,jj)==1
            diffColor=spMeanColor(ii,:)-spMeanColor(jj,:);
            neighborWeights(ii,jj)=1-exp(-sum(diffColor.^2)/5000);
            neighborWeights(jj,ii)=neighborWeights(ii,jj);
        end
    end
end

dataCost=int32(1000*dataCost);
neighborWeights=ceil(500*neighborWeights);
    