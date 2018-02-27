function [Y] = binFilter(X)
%BINFILTER  2-D digital filtering.
%
%Syntax
%
%   Y = BINFILTER(X)
%
%Description
%
%   Y = BINFILTER(X) returns the binomial filtered image Y of the input
%   image X. X and Y have the same size. Symmetric boundary conditions are
%   used.
%
%Examples
%
%   X = peaks(128);
%   figure; imshow(X);
%   X = imnoise(X,'gaussian');
%   figure; imshow(X);
%   X = BINFILTER(X);
%   figure; imshow(X);
%
%References
%
%   [1] Jaehne, B. (2005). Digital Image Processing. Springer. 306-318.
%
%=========================================================================

% B^2 binomial filter (see [1]). For more smoothing: apply several times
% or compute higher order filter mask with Pascal's triangle [1].
% BF = 1/4 .* [1 2 1];
% BF = BF' * BF;

% B^8 binomial filter (see [1]).
BF = 1/256 .* [1 8 28 56 70 56 28 8 1];
BF = BF' * BF;

Y = imfilter(X,BF,'symmetric');

end

