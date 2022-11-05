function H = computeHomography(siftFeatureLeft,siftFeatureRight,matches,error,numIters)
    numMatches = size(matches,2);
    
    nPoints = 4;
    A = zeros(2 * nPoints, 8);
    b = zeros(2 * nPoints, 1);

    H = zeros(3,3);
    maxnInliners = -Inf;

% Number of iterations to calculate the  homography with maximum number of
% inliners

for ind = 1 : numIters
%   Selecting 4 SIFT features randomly
    randSample = randperm(numMatches, nPoints);
    n = 1;
    for j = 1 : nPoints
        matchInd = randSample(j);
        
        d1Index = matches(1, matchInd);
        d2Index  = matches(2, matchInd);
    
        x1 = siftFeatureLeft(1, d1Index); 
        y1 = siftFeatureLeft(2, d1Index);

        x2  = siftFeatureRight(1, d2Index);
        y2  = siftFeatureRight(2, d2Index);
        
        A(n, :) = [x1 y1 1  0 0 0  -x1*x2 -y1*x2];
        b(n) = x2;
        n = n + 1;
      
        A(n, :) = [0 0 0  x1 y1 1  -x1*y2 -y1*y2];
        b(n) = y2;
        n = n + 1; 
    
    end
    
    X = A\b;
   
    tempHomography = [X(1) X(2) X(3); X(4) X(5) X(6); X(7) X(8) 1];
    nInliners = 0;

% Measuring the distance b/w the actual features and projected features coordinates
    for matchIndex = 1:numMatches
        d1Index = matches(1, matchIndex);
        d2Index  = matches(2, matchIndex);
        
        x1 = siftFeatureLeft(1, d1Index); 
        y1 = siftFeatureLeft(2, d1Index);

        x2  = siftFeatureRight(1, d2Index); 
        y2  = siftFeatureRight(2, d2Index);
    
        P1 = [x1; y1; 1];
        P2 = [x2; y2; 1];
        
        Projected = tempHomography*P1;
        Projected = Projected ./ Projected(3);

        err = norm((Projected - P2),2);
        if err <= error
            nInliners = nInliners + 1;
        end
    end
 
% Keeping the homography with most number of inliners
    if nInliners > maxnInliners
       H = tempHomography;
       maxnInliners = nInliners;
    end

end