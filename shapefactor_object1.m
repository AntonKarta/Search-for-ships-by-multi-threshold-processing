function SF = shapefactor_object1(I_T,coord)

S = bwconncomp(I_T);
SF = NaN(10,1);

if S.NumObjects
    A = regionprops(S,'Area');
    C = regionprops(S,'Circularity');
    MaxD = regionprops(S,'MaxFeretProperties');
    MinD = regionprops(S,'MinFeretProperties');
    E = regionprops(S,'Eccentricity');
    P = regionprops(S,'Perimeter');

    for i=1:S.NumObjects
        if sum(S.PixelIdxList{i}==coord) > 0
            break;
        end
    end
    
        SF(1,1) = A(i).Area / (MaxD(i).MaxFeretDiameter * MinD(i).MinFeretDiameter);
        SF(2,1) = MaxD(i).MaxFeretDiameter / MinD(i).MinFeretDiameter;
        SF(3,1) = P(i).Perimeter / (A(i).Area);
        SF(4,1) = C(i).Circularity;
        SF(5,1) = MaxD(i).MaxFeretDiameter - MinD(i).MinFeretDiameter;
        SF(6,1) = E(i).Eccentricity;
        SF(7,1) = 1 - SF(2,1);
        SF(8,1) = 4 * A(i).Area / (MaxD(i).MaxFeretDiameter.^2);
        SF(9,1) = MaxD(i).MaxFeretDiameter / A(i).Area;
        
        i_p = S.PixelIdxList{i}(1);                                         % Get first object point (always at the edge)
        col = ceil(i_p./size(I_T,1));                                       % Convert from pointer to Cartesian 
        row = i_p-(col-1).*size(I_T,1);
        contour = bwtraceboundary(I_T,[row col],'W');                       % Trace object boundary (get contour coordinates)
        dif_contour = diff(contour);                                        % First differences of the contour (get directions)
        angle = atan2(dif_contour(:,1),dif_contour(:,2));                   % Convert directions from Cartesian to Polar
        route = [angle(1)-angle(end); diff(angle)];                         % First differences of directions (navigator instructions)
        route(route==315) = -45;
        route(route==-315) = 45;
        SF(10,1) = sum(abs(route))./length(contour);                        % Calculate total squared rotation angle

end