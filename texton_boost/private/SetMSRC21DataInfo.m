function dataInfo=SetMSRC21DataInfo()
imagePath='E:\DevProj\Datasets\MSRC21\MSRC_ObjCategImageDatabase_v2\Images\';
gtPath='E:\DevProj\Datasets\MSRC21\MSRC_ObjCategImageDatabase_v2\GroundTruth\';
fileid=fopen('E:\DevProj\Datasets\MSRC21\Train.txt','r');
trainImgList=textscan(fileid,'%s');
trainImgList=trainImgList{1,1};
fclose(fileid);
fileid=fopen('E:\DevProj\Datasets\MSRC21\Test.txt','r');
testImgList=textscan(fileid,'%s');
testImgList=testImgList{1,1};
fclose(fileid);
[colormap, className]=GetMSRC21Colormap();

dataInfo.dataset='MSRC21';
dataInfo.imgPath=imagePath;
dataInfo.gtPath=gtPath;
dataInfo.trainImgList=trainImgList;
dataInfo.testImgList=testImgList;
dataInfo.numClass=23;
dataInfo.colormap=colormap;
dataInfo.className=className;
dataInfo.normSize=512;
dataInfo.numColorCluster=96;
dataInfo.numTexton=128;

function [colormap, className]=GetMSRC21Colormap()
colormap=[
    128,0,0;
    0,128,0;
    128,128,0;
    0,0,128;
    128,0,128;
    0,128,128;
    128,128,128;
    64,0,0;
    192,0,0;
    64,128,0;
    192,128,0;
    64,0,128;
    192,0,128;
    64,128,128;
    192,128,128;
    0,64,0;
    128,64,0;
    0,192,0;
    128,64,128;
    0,192,128;
    128,192,128;
    64,64,0;
    192,64,0];
    %     0,0,0;];
className={
    'biulding','grass','tree','cow','horse','sheep','sky', 'mountain',...
   'aeroplane','water','face','car','bicycle','flower', 'sign','bird', ...
   'book','chair','road','cat','dog','body','boat'%,'void'
    };

% fileid=fopen('Colormap.csv','w');
% for kk=1:24
%     fprintf(fileid,'%d,%d,%d,%d,%s\n',kk,colormap(kk,1), ...
%         colormap(kk,2),colormap(kk,3),className{kk});
% end
% fclose(fileid);