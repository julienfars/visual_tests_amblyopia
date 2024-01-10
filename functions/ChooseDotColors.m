function dotcol = ChooseDotColors(ndots);
% Choose cheerful colors for displaying the dots. NB assumes normalised
% colour range.


dotcol = rand(3,ndots);%%Colour dots 
%dotcol = ones(3,ndots);%%%White dots


% must only change this and instead of making random numbers from 0 to 1 
% must randomly generates RGB numbers 


%dotcol = randi(255,3,ndots);
dotcol(4,:) = 0; % transparency

