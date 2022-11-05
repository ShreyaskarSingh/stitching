function mosaic = stitch2Images(leftImage,rightImage,H)
    
    [nrowsLeft, ncolLeft, ~] = size(leftImage);
    [nrowsRight, ncolRight, ~] = size(rightImage);

%   Border position under Homography
    border_M = [
        1  ncolRight ncolRight  1 ;
        1  1           nrowsRight  nrowsRight ;
        1  1           1            1       
    ] ;
    
    border_M_ = zeros(3,4);
    border_M_ = inv(H) * border_M ;

    %normalize border position
    border_M_(1,:) = border_M_(1,:) ./ border_M_(3,:) ;
    border_M_(2,:) = border_M_(2,:) ./ border_M_(3,:) ;
    
    xmin = min([1 border_M_(1,:)]):max([size(leftImage,2) border_M_(1,:)]) ;
    ymin = min([1 border_M_(2,:)]):max([size(leftImage,1) border_M_(2,:)]) ;

    [x,y] = meshgrid(xmin,ymin) ;
    im1_ = vl_imwbackward(im2double(leftImage),x,y) ;

    z_ = H(3,1) * x + H(3,2) * y + H(3,3) ;
    x_ = (H(1,1) * x + H(1,2) * y + H(1,3)) ./ z_ ;
    y_ = (H(2,1) * x + H(2,2) * y + H(2,3)) ./ z_ ;
    im2_ = vl_imwbackward(im2double(rightImage),x_,y_) ;

    mass = ~isnan(im1_) + ~isnan(im2_) ;
    im1_(isnan(im1_)) = 0 ;
    im2_(isnan(im2_)) = 0 ;
    mosaic = (im1_ + im2_) ./ mass ;
end