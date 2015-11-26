function S = GenStroke(im, ks, width, dirNum)
% ==============================================
%   Compute the stroke structure 'S'
%  
%   Paras:
%   @im        : input image ranging value from 0 to 1.
%   @ks        : kernel size.
%   @width     : width of the strocke
%   @dirNum    : number of directions.
%
    
    %% Initialization
    [H, W, ~] = size(im);
    
    %% Smoothing
    im = medfilt2(im, [3 3]);
    
    %% Image gradient
    imX = [abs(im(:,1:(end-1)) - im(:,2:end)),zeros(H,1)];
    imY = [abs(im(1:(end-1),:) - im(2:end,:));zeros(1,W)];  
    imEdge = imX + imY;

    %% Convolution kernel with horizontal direction 
    kerRef = zeros(ks*2+1);
    kerRef(ks+1,:) = 1;

    %% Classification 
    response = zeros(H,W,dirNum);
    for n = 1 : dirNum
        ker = imrotate(kerRef, (n-1)*180/dirNum, 'bilinear', 'crop');
        response(:,:,n) = conv2(imEdge, ker, 'same');
    end

    [~, index] = max(response,[], 3); 

    %% Create the stroke
    C = zeros(H, W, dirNum);
    for n = 1 : dirNum
        C(:,:,n) = imEdge .* (index == n);
    end

    kerRef = zeros(ks*2+1);
    kerRef(ks+1,:) = 1;
    for n = 1 : width
        if (ks+1-n) > 0
            kerRef(ks+1-n,:) = 1;
        end
        if (ks+1+n) < (ks*2+1)
            kerRef(ks+1+n,:) = 1;
        end
    end
    
    Spn = zeros(H, W, dirNum);
    for n = 1 : dirNum
        ker = imrotate(kerRef, (n-1)*180/dirNum, 'bilinear', 'crop');
        Spn(:,:,n) = conv2(C(:,:,n), ker, 'same');
    end

    Sp = sum(Spn, 3);
    Sp = (Sp - min(Sp(:))) / (max(Sp(:)) - min(Sp(:)));
    S = 1 - Sp;
end