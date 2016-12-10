clear; clc;close all;
map=int32(round(rand(64,8)*10));
ntexton=max(map(:))+1;
region=int32([-1,1,-1,1;-4,-2,-1,1;2,4,-1,1]);

feat_gt=zeros(ntexton*size(region,1),size(map,1)*size(map,2));
wmap=ones(size(map));
for kk=1:size(region,1)    
    hf=max(abs(region(kk,1:2)));
    wf=max(abs(region(kk,3:4)));
    filter=zeros(hf*2+1,wf*2+1);
    filter((hf+1+region(kk,1)):(hf+1+region(kk,2)),(wf+1+region(kk,3)):(wf+1+region(kk,4)))=1;
    filter=fliplr(flipud(filter));
    for ll=1:ntexton
        smap=double(map==ll-1);
        rf1=conv2(smap, filter, 'same');
        rf2=conv2(wmap, filter, 'same');
        feat_gt((kk-1)*ntexton+ll,:)=reshape(rf1./(rf2+1e-6),[1 size(feat_gt,2)]);
    end
end

feat_mex=MexGetTextonLayout(map, ntexton, region);

