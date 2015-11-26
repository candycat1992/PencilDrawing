function T = GenPencil(im, P, J)
% ==============================================
%   Compute the pencil map 'T'
%  
%   Paras:
%   @im        : input image ranging value from 0 to 1.
%   @P         : the pencil texture.
%   @J         : the tone map.
%

    %% Parameters
    theta = 0.2;
    
    [H, W, ~] = size(im);

    %% Initialization
    P = imresize(P, [H, W]);
    P = reshape(P, H*W, 1);
    logP = log(P);
    logP = spdiags(logP, 0, H*W, H*W);
    
    J = imresize(J, [H, W]);
    J = reshape(J, H*W, 1);
    logJ = log(J);
    
    e = ones(H*W, 1);
    Dx = spdiags([-e, e], [0, H], H*W, H*W);
    Dy = spdiags([-e, e], [0, 1], H*W, H*W);
    
    %% Compute matrix A and b
    A = theta * (Dx * Dx' + Dy * Dy') + (logP)' * logP;
    b = (logP)' * logJ;
    
    %% Conjugate gradient
    beta = pcg(A, b, 1e-6, 60);
    
    %% Compute the result
    beta = reshape(beta, H, W);
    
    P = reshape(P, H, W);
    
    T = P .^ beta;
end