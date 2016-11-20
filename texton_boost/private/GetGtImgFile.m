function gtImgFile=GetGtImgFile(imgFile, dataset)
if strcmp(dataset,'MSRC21')
    [~, imgName, ~]=fileparts(imgFile);
    gtImgFile=[imgName,'_GT.bmp'];
end




