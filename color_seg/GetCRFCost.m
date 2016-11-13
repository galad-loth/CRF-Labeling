function [dataCost, neighborWeights]=GetCRFCost(img,spLabel,vecMeanColor)
[nr,nc,nd]=size(img);
imgData=reshape(img,[nr*nc nd]);
numSp=max(spLabel(:))+1;
numRegion=size(vecMeanColor,1);
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

for ii=1:numSp
    spMeanColor(ii,:)=spMeanColor(ii,:)/(eps+spSize(ii));
    for jj=1:numRegion
        diffColor=spMeanColor(ii,:)-vecMeanColor(jj,:);
        dataCost(jj,ii)=1-exp(-sum(diffColor.^2)/5000);
    end   
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
neighborWeights=ceil(250*neighborWeights);
    