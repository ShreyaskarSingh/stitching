function [intialImages] = input_images(imagesDirectory)
    pictures = dir(imagesDirectory);
    nImages = (length(pictures)-2);  
    intialImages = {};
    counter = 1;
    for i = 1:nImages
        name = pictures(i+2).name;
        if name ~= ".DS_Store"
            intialImages{counter} = im2single(imread(strcat(imagesDirectory,'/',name))); 
            counter = counter + 1;
        end
    end
 end
