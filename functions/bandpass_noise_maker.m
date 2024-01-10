function  newnoise=noise_maker(noisesize,fc,fontsize);
randguass=randn(noisesize/2,noisesize/2)/2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% produce  a guassion noise  
while 1
    if (max(max((abs(randguass)>1)))); 
    else
        break ;
    end; % a matrix of 0's and 1's, where 1's are the locations 
    m=(abs(randguass)>1) ;
    %of extreme pixels
    rrr=m.*(randn(noisesize/2,noisesize/2)-0.5)/2;
    % rr is a matrix that have [-1 1] random numbers at locations where noise 
    %values are large.
    randguass=rrr+randguass.*(1-m);
    clear m
    clear rrr
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% wn=pixelMag(2,randguass);% copy 1*1 grid to   2*2 as a grid
wn=imresize(randguass,2);

wn=([[wn; rand(1, size(wn,1))] rand(size(wn,2)+1,1)]+1)/2;    % add one row and one column of noise so that the array size is an odd number
clear randguass
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
wnf=fftshift(fft2(wn));%fouier tansform of white noise.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%produce a 1/f function 1/(x^2+y^2);
[xx yy]=meshgrid(-noisesize/2:noisesize/2,-noisesize/2:noisesize/2);
r=sqrt(xx.*xx+yy.*yy);
r(noisesize/2+1,noisesize/2+1)=1;
z=1./r;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%wnf=wnf.*z;% multiple white noise with 1/f
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% A cosin grating which frequency is center frequency needed 
h=noisesize/2;
[x y]=meshgrid(-h:h,-h:h);  % for a 101x101 image
period=fontsize/fc;  % period of a grating in pixels. This is the inverse of frequency.
% The larger the period, the lower the spatial frequency.
% In the frequency domain, a larger period corresponds to peaks that
% are closer to 0-frequency.
g=(1+cos(2*pi*x/period))/2;   % this is a vertical grating between 0 and 1
gf=fftshift(fft2(g));   % the spectrum of the grating. It is a matrix of complex numbers. You can't view an image of it. You can only view the amplitude
% fftshift put the 0-frequecy at the center of the matrix. This matrix is the same size as the original image.
agf=abs(gf);%/*   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create a filter that preserve this frequency of the grating and keep other things out.
% This is a 3-pixel wide ring filter. You can change the width of the band. This is the band-width of filter.
% This way you can preserve the frequency component of your grating.
% noisesize: filter size in pixels. This should be an odd number, for example, 501.
% fontsize: stimulus (letter) size in pixels;
% fc: Peak frequency of the filter in cycles/letter.
f=zeros(size(agf,1),size(agf,2));  
bw=1;
fl=10^(log10(fc)-log10(2*bw)/2);%low frequency of guassion
fh=10^(log10(fc)+log10(2*bw)/2);%high frequency of guassion
dc=noisesize/(fontsize/fc);
dl=noisesize/(fontsize/fl);
dh=noisesize/(fontsize/fh);
f=zeros(noisesize+1,noisesize+1);  
r12=dl*dl;
r22=dh*dh;
noisesize21=floor(noisesize/2)+1;
% use a cosine curve to get the exact bandwidth.
xx=1:3;
dd=dl-floor(dl);
p=2*pi*(2-dd)/acos(0);
dlEdge=fliplr((1+cos(2*pi*xx/p))/2);
if dd<0.3
    dlEdge(1)=0;
end

dd=dh-floor(dh);
p=2*pi*(1+dd)/acos(0);
dhEdge=(1+cos(2*pi*xx/p))/2;
if dd<0.3
    dhEdge(3)=0;
end
tx=zeros(1,noisesize21);
tx(floor(dl):floor(dl+2))=dlEdge;
tx(floor(dh+1):floor(dh+3))=dhEdge;
tx(floor(dl+3):floor(dh))=1;
%tx=fliplr(tx);
for i=1:noisesize+1
    i2=(i-noisesize21)*(i-noisesize21);
    for j=1:noisesize+1
        j2=(j-noisesize21)*(j-noisesize21);
        r=floor(sqrt(i2+j2));
        if r<dh+3 & r>dl-3  % on a circle with a radius of r
            f(i,j)=tx(r);
        end
    end
end
f(noisesize21,noisesize21)=1;
f=f.*z*100;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%fgf=f.*g;    % multiple the filter with the spectrum
%wnf=fftshift(fft2(wn));
fgf=f.*wnf;    % multiple the filter with the white noise
igf=ifft2(fgf);  % do inverse FFT. The result is usually a matrix of complex numbers
aigf=abs(igf);
meanlum=mean(mean(aigf));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
newnoise=(aigf-meanlum)*5;
%newnoise=(aigf-meanlum)*2.4;% scale noise to 0.22 contrast and [-1 1]
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  End %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%