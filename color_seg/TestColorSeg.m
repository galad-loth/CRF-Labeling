clear; close all;clc
img=imread('E:\DevProj\Datasets\MiscData\BSD241004_C.png');
figure(1);set(gcf,'position',[200 200 1200 750])
subplot(2,2,1);imagesc(img);title('Original Image')
pause(0.05)

%%
disp('Generating Superpixels...')
spLabel=mexSLIC(double(img),800,2500,3);
imgEdge=GetLabelEdge(img,spLabel);
subplot(2,2,2);imagesc(imgEdge);title('SLIC Result')
pause(0.05)

%%
numRegion=5;
[nr,nc,nd]=size(img);
imgTrainLabel=zeros(nr,nc);
vecMeanColor=zeros(numRegion, nd);
figure(1); subplot(2,2,3);imagesc(img)
figure(1001);set(gcf,'position',[400 300 800 600])
imagesc(img);title('Please select training samples for each region.')

for ii=1:numRegion
    roiMask=roipoly();
    imgTrainLabel(roiMask)=ii;    
    vecMeanColor(ii,:)=mean(VectorIndexing3D(img,roiMask),1);
    figure(1); subplot(2,2,3);
    hold on; contour(double(roiMask)-0.5,[0 0],'r','Linewidth',2);
    figure(1001); hold on; contour(double(roiMask)-0.5,[0 0],'r','Linewidth',2)    
end
close(1001);

%%
disp('CRF inference...')
[dataCost, neighborWeights]=GetCRFCost(double(img),spLabel,vecMeanColor);
smoothCost=(ones(numRegion, numRegion)-eye(numRegion));

%%
objGCO = GCO_Create(size(dataCost,2), size(dataCost,1));  
GCO_SetDataCost(objGCO, dataCost);
GCO_SetSmoothCost(objGCO, smoothCost);
GCO_SetNeighbors(objGCO, neighborWeights);
GCO_Expansion(objGCO);
spRegionLabel=GCO_GetLabeling(objGCO);

segLabel=RecoverPixelLabel(spRegionLabel, spLabel);
colormap=[0,0,0;vecMeanColor];
classMap=GetClassMap(segLabel,colormap);

subplot(2,2,4);imagesc(classMap);title('Segmentation Result')

