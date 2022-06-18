% данный програмный модуль позволяет выявить где находятся корабли
% на морской взволнованной поверхности
clear all;  close all;  clc;   colc=0;

%% Загрузка предварительно посчитанных данных
SF=open('S_factor_all.mat');
LL=SF.LL;
SSF1=SF.SSF1;
L_dist=open('Dist.mat');
%% Реализация локационных картин
% i1=randi([1,4]); i2=randi([1,8]);
i1=4; i2=3;

name1=[num2str(i1) '_sh.jpg'];
I_sh=imread(name1);
I_sh=rgb2gray(I_sh);
Iraz= fspecial('gaussian', [10 10],2);
I_sh = imfilter(I_sh,Iraz,'same');
I_sh=I_sh-100;

name2=[num2str(i2) '.jpg'];
I1=imread(name2);
I1=max(I1(:))-I1;
I1=rgb2gray(I1)+5;
bomb=imread('mins.jpg');
bomb=rgb2gray(bomb);
I_st=I_sh+I1;

figure (2)
imshow(I_st);
%% Выявление кораблей
s1=8; s2=6; % номера факторов формы объектов
m1=(SSF1(:,s1));  m2=(SSF1(:,s2));
coef=[m1 m2];

d=0.009;  S_min = 100; P_max =250;% пороговые значения

[Istina,IS,IP,IA,Col,Raz,S1,S2,C] = uistina_v1_4(I_st,d,coef,S_min,...
    P_max,s1,s2,LL);% функция поиска кораблей на морской поверхности

%% Расчет коэффициентов Жаккарда
% j1=jaccard(IS,IA);
% j2=jaccard(IP,IA); 
% j3=jaccard(Istina,IA);

%% Вывод промежуточных результатов
figure (1)
title ('Пороговые значения'); imagesc(Istina); colorbar('eastoutside')

figure (11); imagesc(IA); colorbar('eastoutside')

figure (12); imagesc(IS); colorbar('eastoutside')

figure (13); imagesc(IP); colorbar('eastoutside')

%% Показывает, где находятся корабли
Istina=Istina>0;
S=bwconncomp(Istina);
Nobj=S.NumObjects;
B=struct2cell(regionprops(S,'BoundingBox'));
s=size(B);

figure (2)
Naiming=['Количество найденных кораблей : ', num2str(Nobj)];

rgbImage = ind2rgb(I_st, colormap(summer));
imshow(rgbImage)
title (Naiming)

hold on
for i=1:s(2)
rectangle('Position',ceil(B{i}),'EdgeColor','r')
text((ceil(B{i}(1))),(ceil(B{i}(2)-5)),'\downarrow Корабль');
end

%% Построение зависимости признаков формы
for i=1:length(S1)
    figure (3)
    hold on 
    grid on
    plot (S1{i},S2{i},'.')
    Ploting=figure (3)
     ylim([0.6,1]);
end
plot (m1,m2,'*','Color','g')
Ploting=figure (3)
xlabel('Закругленность');ylabel('Эксцентриситет');

%% Построение зависимости количества объектов от порога
 figure (4)
 for i=1:4
    hold on 
    grid on
    area(C(i,:))
    xlabel('Пороги');ylabel('Количество найденых объектов');
 end
 legend('Не использованы признаки формы','Использована только площадь',...
     'Использованы периметр и площадь','Испольвание всех выбранных признаков')
%% Проверка на истиность
close all

S = bwconncomp(Istina);
for i=1:S.NumObjects
    I = zeros(S.ImageSize);
    I(S.PixelIdxList{i}) = 255;
    if i==1
        [LL] = razvert(I);
        S_d=LL;
    else
       [LL] = razvert(I);
        S_d=[S_d; LL];
    end
end

I=zeros(S.ImageSize);

[x,~]=size(S_d);
for i=1:x
R(i)=corr2(LL,S_d(i,:));
if R(i)>0.88
    I(S.PixelIdxList{i})=1;
end
end
figure (21); imagesc(I); colorbar('eastoutside')

%% Истинное нахождение кораблей
S=bwconncomp(I);
Nobj=S.NumObjects;
B=struct2cell(regionprops(S,'BoundingBox'));
s=size(B);

figure (2)
Naiming=['Количество найденных кораблей : ', num2str(Nobj)];

rgbImage = ind2rgb(I_st, colormap(summer));
imshow(rgbImage)
title (Naiming)

hold on
for i=1:s(2)
rectangle('Position',ceil(B{i}),'EdgeColor','r')
text((ceil(B{i}(1))),(ceil(B{i}(2)-5)),'\downarrow Корабль');
end

