function TestFBS()
img=imread('E:\DevProj\Datasets\MiscData\124084.jpg');

cform=makecform('srgb2lab');
imgLAB=applycform(img,cform);
imgLAB=double(imgLAB);
imgDbl=double(imgLAB);
[nr,nc,nd]=size(img);

figure(1);set(gcf,'position',[200 200 1200 750])
subplot(2,2,1);imagesc(img);title('Original Image')
pause(0.05)

% Superpixel segmentation
disp('Generating Superpixels...')
spLabel=mexSLIC(imgDbl,3000,2500,3);
imgEdge=GetLabelEdge(img,spLabel);
figure(1);subplot(2,2,2);
imagesc(imgEdge);title('SLIC Result')
pause(0.05)

%Get train data interactively
[trainLabel,trainSpFlag]=SetTrainData(img, spLabel);
imgMark=reshape(img, [nr*nc nd]);
idx=trainLabel==1;
imgMark(idx,1)=255;
imgMark(idx,2)=0;
imgMark(idx,3)=0;
idx=trainLabel==2;
imgMark(idx,1)=0;
imgMark(idx,2)=255;
imgMark(idx,3)=0;
imgMark=reshape(imgMark,[nr nc nd]);
figure(1);subplot(2,2,3);
imagesc(imgMark);title('Marker Image');
pause(0.05)
%
disp('CRF inference...')
[dataCost, neighborWeights]=GetRAGCost2(imgDbl,spLabel,trainSpFlag);
smoothCost=(ones(2, 2)-eye(2));

objGCO = GCO_Create(size(dataCost,2), size(dataCost,1));  
GCO_SetDataCost(objGCO, dataCost);
GCO_SetSmoothCost(objGCO, smoothCost);
GCO_SetNeighbors(objGCO, neighborWeights);
GCO_Expansion(objGCO);
spRegionLabel=GCO_GetLabeling(objGCO);

segLabel=RecoverPixelLabel(spRegionLabel, spLabel);
imgEdge=GetLabelEdge(img,segLabel);
subplot(2,2,4);imagesc(imgEdge);title('Segmentation Result')


function [trainLabel,trainSpFlag]=SetTrainData(img, spLabel)
global hdlFigMarker;
global markerImg;
hdlFigMarker=figure(1001);set(gcf,'position',[400 300 800 600])
imagesc(img);
set(hdlFigMarker, 'WindowButtonUpFcn',@MouseUpAction, ...
    'WindowButtonMotionFcn',@MouseMotionAction);
[nr,nc,~]=size(img);
trainLabel=zeros(nr,nc);
maxSpIdx=max(spLabel(:))+1;
trainSpFlag=zeros(1, maxSpIdx);

markerImg=zeros(nr,nc);
SetMarker(1);
bwMarkerImg=markerImg>0;
bwMarkerImg=bwmorph(bwMarkerImg,'dilate',3);
trainLabel(bwMarkerImg)=1;
trainSpFlag(spLabel(bwMarkerImg)+1)=1;
SetMarker(2);
bwMarkerImg=markerImg>0;
bwMarkerImg=bwmorph(bwMarkerImg,'dilate',3);
trainLabel(bwMarkerImg)=2;
trainSpFlag(spLabel(bwMarkerImg)+1)=2;
close(hdlFigMarker);
pause(0.05)


function SetMarker(regionFlag)
global hdlFigMarker;
global markerImg;
global mouseDownFlag;
global markerColor;

markerImg=markerImg*0;
if (regionFlag==1)
    markerColor=[1,0,0];
    figure(1001), title('Please set marker for foreground region');
elseif (regionFlag==2)
    markerColor=[0,1,0];
    figure(1001), title('Please set marker for background region');
end

mouseDownFlag=0;
while(mouseDownFlag~=2)
    pressFlag = waitforbuttonpress;
    if pressFlag==0
        mousePressType=get(hdlFigMarker,'SelectionType');
        MouseDownAction(mousePressType);
    elseif pressFlag==1
        disp('please use mouse to manipulate!');
        continue;
    end
end

function MouseDownAction(mousePressType)
global mouseDownFlag;
global ptLast;
if strcmp(mousePressType,'normal')
    mouseDownFlag=1;
    ptLast=get(gca,'CurrentPoint');
elseif strcmp(mousePressType, 'open')
    mouseDownFlag=2;
end

function MouseUpAction(varargin)
global mouseDownFlag;
mouseDownFlag=0;
return;

function MouseMotionAction(varargin)
global mouseDownFlag;
global ptLast;
global markerColor;
global markerImg;
[nr,nc,~]=size(markerImg);
if mouseDownFlag~=1
    return;
end
ptCurrent=get(gca,'CurrentPoint');
hold on; plot([ptLast(1,1),ptCurrent(1,1)],[ptLast(1,2),ptCurrent(1,2)], ...
    'color',markerColor,'Linewidth',5)
mousePathPts=GetLinePts(ptLast(1,[2,1]),ptCurrent(1,[2,1]));
for kk=1:size(mousePathPts,1)
    pr=round(mousePathPts(kk,1));
    pc=round(mousePathPts(kk,2));
    if (pc>0 && pc<nc && pr>0 && pr<nr)
        markerImg(pr,pc)=255;
    end
end
ptLast=ptCurrent;
return;

function linePts=GetLinePts(pt1, pt2)
dr=pt1(1)-pt2(1);
dc=pt1(2)-pt2(2);
if (abs(dr)<1 && abs(dc)<1)
    linePts=round(pt1);
    return;
elseif (abs(dr)<=abs(dc))
    numPts=ceil(abs(dc));
    linePts=zeros(numPts,2);
    linePts(:,1)=round(linspace(pt1(1),pt2(1),numPts));
    linePts(:,2)=round(linspace(pt1(2),pt2(2),numPts));
else
   numPts=ceil(abs(dr));
    linePts=zeros(numPts,2);
    linePts(:,1)=round(linspace(pt1(1),pt2(1),numPts));
    linePts(:,2)=round(linspace(pt1(2),pt2(2),numPts)); 
end







