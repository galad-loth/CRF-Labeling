function filters=MakeTextonFilters()
sizeFilter=49;
filters=zeros(sizeFilter,sizeFilter,11);
r=1;
idxFilter=1;
for kk=1:3
    filters(:,:,idxFilter)=GetGaussianFilter(sizeFilter,r);
    r=r*2;
    idxFilter=idxFilter+1;
end
r=1;
for kk=1:4
    filters(:,:,idxFilter)=GetLoGFilter(sizeFilter,r);
    r=r*2;
    idxFilter=idxFilter+1;
end
r=2;
for kk=1:2
    filters(:,:,idxFilter)=GetPDoGFilter(sizeFilter,r);
    filters(:,:,idxFilter+1)=filters(:,:,idxFilter)';
    r=r*2;
    idxFilter=idxFilter+2;
end

function filt=GetGaussianFilter(size,r)
center=(size+1)/2;
range=(1:size)-center;
[xx,yy]=meshgrid(range,range);
filt=exp(-(xx.^2+yy.^2)/2/r/r)/(2*pi*r*r);

function filt=GetLoGFilter(size,r)
center=(size+1)/2;
range=(1:size)-center;
[xx,yy]=meshgrid(range,range);
filt=exp(-(xx.^2+yy.^2)/2/r/r)/(2*pi*r*r);
filt=filt.*(xx.^2+yy.^2-2*r*r)/(r^4);

function filt=GetPDoGFilter(size,r)
center=(size+1)/2;
range=(1:size)-center;
[xx,yy]=meshgrid(range,range);
filt=-exp(-(xx.^2+yy.^2)/2/r/r).*xx/(2*pi*r^4);










