function [Istina,IstinaS,IstinaP,IstinaAll,Col,raz1,SF1,SF2,C] = uistina_v1_4(Im,razni,coef1,S_min,P_max,s1,s2,LL)
%% Програмный модуль позволяющий реализовать многопороговый алгоритм
T_max = 255;	T_step = 1; [L,D]=size(coef1);
mov=VideoWriter('ships.mp4');
open(mov)

Col=0;
for T=1:T_step:T_max
    colP=0;colS=0;colC=0;
    
    I_T = (Im >= T);
    Il=uint8(I_T*255);
    writeVideo(mov,Il);
    imshow (I_T)
    
    I_T = bwareaopen(I_T,30);
    S{T} = bwconncomp(I_T);
    
    I = zeros(S{T}.ImageSize);
    Istruct = zeros(S{T}.ImageSize);
    raz{T} = NaN(S{T}.NumObjects,1);
    
    disp(T);
    I_P{T} = zeros(S{T}.ImageSize);
    II=zeros(S{T}.ImageSize);
    I1 = zeros(S{T}.ImageSize);
    Ii{T} = zeros(S{T}.ImageSize);
    if T==1
    Istina=zeros(S{T}.ImageSize);
    IstinaS=zeros(S{T}.ImageSize);
    IstinaP=zeros(S{T}.ImageSize);
    IstinaAll=zeros(S{T}.ImageSize);
    I_z=zeros(S{T}.ImageSize);
    end
    cnt_obj = 0;
    size_obj = [];
    
    Cno(T)=S{T}.NumObjects;
    
    for i=1:S{T}.NumObjects
        IstinaAll(S{T}.PixelIdxList{i})=T;
        if (length(S{T}.PixelIdxList{i}) > S_min)
        IstinaS(S{T}.PixelIdxList{i})=T;
        I_z=zeros(S{T}.ImageSize);
        I1(S{T}.PixelIdxList{i})=1;
        Sis=bwconncomp(I1);
        P=struct2array(regionprops(Sis,'Perimeter'));
             colS=colS+1;
        if P<P_max
            colP=colP+1;
            IstinaP(S{T}.PixelIdxList{i})=T;
        s = regionprops(I1,'centroid');
        
        g1=0;
        g1 = ceil(s.Centroid);
        Ii{T}(g1(2),g1(1))= 1;
        Ss=bwconncomp(Ii{T});
        ctr=Ss.PixelIdxList{1};
        
        [SF] = shapefactor_object1(I1,ctr);
        
        SF1{T}(i)=SF(s1);SF2{T}(i)=SF(s2);
        
        t_n1=[SF(s1) SF(s2)];
        razp=pdist2(t_n1,coef1);
        
        raz1{T}(i)=mean(razp);
        
        
        if (raz1{T}(i) < razni)
                Col=Col+1;
                colC=colC+1;
                Istina(S{T}.PixelIdxList{i})=T;
        end
        end
        end
        I1 = zeros(S{T}.ImageSize);
        end
        C1(T)=colS;
        C2(T)=colP;
        C3(T)=colC;
end
    C=[Cno;C1; C2; C3];
    close(mov);
end


