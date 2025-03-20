function out=scramble(in)
% function out = scramble(in)
% Returns the elements of array in a random order.
%
% Example: 
% scramble([1 2 3 4 5 6 7 8 9]) might give you [4     3     6     2     1     5     8     9     7]
%
% Jenny Read 2/4/2003

% Generate a random array
tmp = rand(1,length(in));
% and sort it. This gives you the indices arranged in a random order
[tmp,k] = sort(tmp);
out = in(k);
