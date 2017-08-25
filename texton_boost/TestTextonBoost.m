function TestTextonBoost()
dataInfo=SetMSRC21DataInfo();
load('data\textonMapTest.mat');


testIdx=43;
% TextonBoostPredict(textonMapTest{testIdx}-1, dataInfo);
imgFile=dataInfo.testImgList{testIdx};
img=imread([dataInfo.imgPath,imgFile]);
gtImgFile=GetGtImgFile(imgFile, dataInfo.dataset);
gtImg=imread([dataInfo.gtPath,gtImgFile]);
figure(1);set(gcf, 'position',[200 100 1400 600])
subplot(2,3,1);imagesc(img);title('Color image')
subplot(2,3,2);imagesc(gtImg);title('Ground Truth')

gtLabel=InvClassMap(gtImg,int32(dataInfo.colormap), dataInfo.numClass);
[nr,nc]=size(gtLabel);
gtLabel=reshape(gtLabel,[nr*nc 1]);

load('data\modelLocation.mat');
load('data\modelColor.mat');
load('data\LightGBM_predict_result.txt');
[predProb, predClass]=max(LightGBM_predict_result,[],2);
predClass=reshape(predClass,[nr nc]);
classMap=GetClassMap(predClass-1,dataInfo.colormap);
subplot(2,3,3);imagesc(classMap);title('PredClass by TextonBoost')




function TextonBoostPredict(map,dataInfo)
featTextureLayout=MexGetTextonLayout(int32(map),dataInfo.numTexton,dataInfo.regionLayout);
fid=fopen('data\testFeatTextureLayout.csv','w');
for ic=1:nc
        for ir=1:nr
            ip=(ic-1)*nr+ir;
            fprintf(fid, '%d,', gtLabel(ip));
            fprintf(fid, '%f,', featTextureLayout(:, ip)');
            fprintf(fid,'\n');
        end
end
fclose(fid);

cd('data')
system('lightgbm.exe config=LightGBM_predict.conf')
cd ..

