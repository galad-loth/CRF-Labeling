function label=InvClassMap(classMap,cmap, numClass)
[nr,nc,nd]=size(classMap);
classMap=reshape(classMap,[nr*nc nd]);
label=zeros(nr,nc);
for cc=1:numClass
        idx=(classMap(:,1)==cmap(cc,1))&(classMap(:,2)==cmap(cc,2)) ...
            &(classMap(:,3)==cmap(cc,3));
        label(idx)=cc;
end


