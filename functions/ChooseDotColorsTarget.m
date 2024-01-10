function dotcol = ChooseDotColorsTarget(ndots,stereocue);
% Choose cheerful colors for displaying the dots. NB assumes normalised
% colour range.
dotcol = rand(3,ndots);%%Colour dots
% ndots=29;
%dotcol = randi(255,3,ndots);
dotcol(1,:)=rand(1,1,ndots);
dotcol(2,:)=rand(1,1,ndots)*(1-stereocue);
dotcol(3,:)=rand(1,1,ndots)*(1-stereocue);

%dotcol(1,:)=randi(255,1,ndots);
%dotcol(2,:)=randi(255,1,ndots)*(1-stereocue);
%dotcol(3,:)=randi(255,1,ndots)*(1-stereocue);
%dotcol = ones(3,ndots);%%%White dots

dotcol(4,:) = 0; % transparency