function [LL] = razvert(Im)
angle=0:1:360;
N=length(angle);
Siz=size(Im);

I_zh=zeros(Siz(1),2);
Im=[I_zh Im I_zh];

Siz=size(Im);
I_zw=zeros(2,Siz(2));
Im=[I_zw; Im; I_zw];

S2=bwconncomp(Im);
cent=struct2cell(regionprops(S2,'centroid'));
G = ceil(cent{1});

if Im(G(2),G(1))>0

for a = 1:N
I=imrotate(Im,angle(a));

I=I>0;
S = bwconncomp(I);
B=struct2cell(regionprops(S,'BoundingBox'));
I= imcrop(I,[B{1}(1) B{1}(2) B{1}(3) B{1}(4)]);
Ss = bwconncomp(I);
I2 = zeros(Ss.ImageSize);
s1 = struct2cell(regionprops(Ss,'centroid'));
g1=round(s1{1});
cort=g1(1);
while I(g1(2),cort)~=0
    cort=cort+1;
end
I2(g1(2),cort)= 2;
I=I+I2;
distanse=g1(1):cort;
L(a)=length(distanse);
for i=1:L(a)
    I(g1(2),distanse(i))=3;
end
% figure (1)
% imagesc(I);
end

[p,s]=max(L);

Dmin=L(1:s-1); Dmax=L(s:361);

L=[Dmax Dmin]/p;

LL=L;
 for i = 2:1:length(L)-2
     LL(i)=(L(i)+L(i-1)+L(i+1))./3;
 end
 
else
    LL=zeros(1,361);
end
end

