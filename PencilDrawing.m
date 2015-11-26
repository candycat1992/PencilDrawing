function I = PencilDrawing(im, ks, width, dirNum, gammaS, gammaI)
% ==============================================
%   Generate the pencil drawing I based on the method described in
%   "Combining Sketch and Tone for Pencil Drawing Production" Cewu Lu, Li Xu, Jiaya Jia 
%   International Symposium on Non-Photorealistic Animation and Rendering (NPAR 2012), June, 2012
%  
%   Paras:
%   @im        : the input image.
%   @ks        : the length of convolution line.
%   @width     : the width of the stroke.
%   @dirNum    : the number of directions.
%   @gammaS    : the darkness of the stroke.
%   @gammaI    : the darkness of the resulted image.
%

    %% Read the image
    im = im2double(im);
    [H, W, sc] = size(im);

    %% Convert from rgb to yuv when nessesary
    if (sc == 3)
        yuvIm = rgb2ycbcr(im);
        lumIm = yuvIm(:,:,1);
    else
        lumIm = im;
    end

    %% Generate the stroke map
    S = GenStroke(lumIm, ks, width, dirNum) .^ gammaS; % darken the result by gamma
%     figure, imshow(S)

    %% Generate the tone map
    J = GenToneMap(lumIm) .^ gammaI; % darken the result by gamma
%     figure, imshow(J)

    %% Read the pencil texture
    P = im2double(imread('pencils/pencil0.jpg'));
    P = rgb2gray(P);

    %% Generate the pencil map
    T = GenPencil(lumIm, P, J);
%     figure, imshow(T)

    %% Compute the result
    lumIm = S .* T;

    if (sc == 3)
        yuvIm(:,:,1) = lumIm;
    %     resultIm = lumIm;
        I = ycbcr2rgb(yuvIm);
    else
        I = lumIm;
    end
end

