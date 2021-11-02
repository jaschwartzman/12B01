%**************************************************************************
%     Analysis of Radial Intensity profiles form nanoSIMS data
% 
%**************************************************************************
%*   Author: Julia Schwartzman                                                 *
%*   MIT                                                                  *
%*  email:  julia5@mit.edu                                                 *
%*                                                                        *
%*   Version 1                                                            *
%*   Copyright (c) MIT 2021. All rights reserved.                         *
%*                                                                        *
%*   License to copy and use this software purposes is granted provided   *
%*   that appropriate credit is given to both MIT and the author.         *
%*   License is also granted to make and use derivative works provided    *
%*   that appropriate credit is given to both MIT and the author.         *
%*  
%    MIT makes no representations concerning either the merchantability  *
%*   of this software or the suitability of this software for any         *
%*   particular purpose.  It is provided "as is" without express or       *
%*   implied warranty of any kind.                                        *
%*                                                                        *
%*   These notices MUST BE retained in any copies of any part of          *
%*   this code.                                                           *
%**************************************************************************
%**************************************************************************

close all
%read in fused image and adjust so its in units of 15N/(15N+14N)
map=double(imread('15N14N_S7.tif'));
max_map=double(max(max(map)));
adjust=max_map./0.1577; %adjust for the  max intensity in each stitched image (below)
map_adjust=map./adjust;

%Medium shaking maximum intensity
%1: 0.0726
%2: 0.0870
%3: 0.0846
%4: 0.0801
%5: 0.0799
%6: 0.0891
%7: 0.0835

%Slow shaking maximum intensity
%1: 0.0814
%3: 0.0822
%4: 0.0841
%5: 0.0938
%7: 0.1577
%9: 0.0791

%Define an intensity based threshold and segement out single non-attached cells
mask=double(map_adjust>0.5.*mean2(map_adjust)); 
mask=imfill(mask,'holes');
labels = bwlabel(mask);
stats= regionprops(labels,'Area'); 
for s = 1:length(stats);
    junk=stats(s);
       if junk.Area <5000;
          labels(labels==s)=0;
       end
end
labels2=bwlabel(labels>0);

%Loop through and quanitfy the mean intensity and stdev intensity in a
%border 10 pixels thick around the aggregate, from the outside to the inside
outer=labels2;
ring=[];
std=[];
n=0;
while nansum(nansum(outer))>0
    n=n+1
    SE = strel('sphere',8);
    inner=imerode(outer,SE);
    inner=imerode(inner,SE);
    quantify=(outer-inner);
    quantify=quantify.*map_adjust;
    quantify(quantify==0)=NaN;
    ringtemp=nanmean(nanmean(quantify));
    ring=[ring ringtemp];
    stdtemp=nanstd(nanstd(quantify));
    std=[std stdtemp];
    outer=inner;
end
    
    
    
    
    
    
    
    
 

   