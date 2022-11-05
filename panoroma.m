function panoroma(imagesFolder,error,numIter)
    intialImages = input_images(imagesFolder);
    
    % To remove the warning of Matrix is close to singular or badly scaled 
    warning('off','all')
    figure(1);
    hold
    montage(intialImages);

    grayScaleimages = {};
    
    % Storing the Gray Scale images in dictionary
    for i = 1 : length(intialImages)
        grayScaleimages{i} = im2single(rgb2gray(intialImages{i}));
    end

   %Descriptors of the SIFT Features for each image 
    for j=1:length(grayScaleimages) 
       [fG,dG]= vl_sift(grayScaleimages{j}) ;
       siftFeature{j}=fG; 
       siftDescriptor{j}=dG;
    end

nImages = length(intialImages);
midImageIndex=ceil(nImages/2); 

% Creating the Intial panoroma
left= midImageIndex; 
right=midImageIndex+1;
[matches,~] = vl_ubcmatch(siftDescriptor{left},siftDescriptor{right});
H =computeHomography(siftFeature{left},siftFeature{right},matches,error,numIter);
mosaic = stitch2Images(intialImages{left},intialImages{right},H);  

% Stitching the remaining images 
left = midImageIndex - 1;
right = midImageIndex + 2;
direction = 1;
while (left > 0  && right <= nImages)
    % to stitch the images from left side of the middle mage
    if direction == 1
        [fG,dG] = vl_sift(rgb2gray(im2single(mosaic)));
        [matches,~] = vl_ubcmatch(dG,siftDescriptor{left});
        H =computeHomography(fG,siftFeature{left},matches,error,numIter);
        mosaic = stitch2Images(mosaic,intialImages{left},H);
        direction = direction * -1;
        left = left - 1;
    end
    % to stitch the images to the right size of the middle image
    if direction == -1
        [fG,dG] = vl_sift(rgb2gray(im2single(mosaic)));
        [matches,~] = vl_ubcmatch(dG,siftDescriptor{right});
        H =computeHomography(fG,siftFeature{right},matches,error,numIter);
        mosaic = stitch2Images(mosaic,intialImages{right},H);
        direction = direction * -1;
        right = right + 1;
    end
end

% Displaying the output image
figure(2) ; 
imshow(mosaic) ; 
end 