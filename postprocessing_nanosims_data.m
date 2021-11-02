%%
%**************************************************************************
%     NANOSIMS IMAGE ANALYSIS
% 
%**************************************************************************
%*   Author: Ali Ebrahimi                                                 *
%*   MIT                                                                  *
%*  email:  alieb@mit.edu                                                 *
%*                                                                        *
%*   Version 1                                                            *
%*   Copyright (c) MIT 2021. All rights reserved.                         *
%*                                                                        *
%*   License to copy and use this software purposes is granted provided   *
%*   that appropriate credit is given to both MIT and the author.         *
%*   License is also granted to make and use derivative works provided    *
%*   that appropriate credit is given to both MIT and the author.         *
%*                                                                        *
%*   ETHZ makes no representations concerning either the merchantability  *
%*   of this software or the suitability of this software for any         *
%*   particular purpose.  It is provided "as is" without express or       *
%*   implied warranty of any kind.                                        *
%*                                                                        *
%*   These notices MUST BE retained in any copies of any part of          *
%*   this code.                                                           *
%**************************************************************************
%**************************************************************************
%   See also subfunctions


%%
clear
close all
% load input 15N image
load('15N12C.mat')
ns_image = IM;
% title
image_title='medium speed, 2hrs, R1 part3';
% normalize nanosims image
ns_image = (ns_image)-min(min(ns_image));
% maximum pixel value on nanosims image; used for setting the axis range
% for colorbar
max_pixel_ns_image=max(max((ns_image)));
ns_image_15N=ns_image;
figure(1)
subplot_number=1;
subplot(1,4,subplot_number);
imagesc(ns_image)
title('15N')
axis('equal') 
axis([0 512 0 512])
set(gca,'XTick',[], 'YTick', [])
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
colorbar
% load 14N image
load('14N12C.mat')
ns_image_14N=IM;
ns_image = (ns_image_14N)-min(min(ns_image_14N));
max_pixel_ns_image=max(max((ns_image)));
figure(1)
subplot(1,4,subplot_number+1);
imagesc(ns_image)
title('14N')
axis('equal') 
axis([0 512 0 512])
set(gca,'XTick',[], 'YTick', [])
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
colorbar
% ratio of 15N to 14N
ratio_15N_14N=ns_image_15N./(+ns_image_14N);
ratio_15N_14N_binary= bwareaopen(ratio_15N_14N, 100);
%filter the radio image (15N/14N)
ratio_15N_14N=ratio_15N_14N.*ratio_15N_14N_binary;
[n h]=hist(ratio_15N_14N(find(ratio_15N_14N)),100);
p = cumsum(n./sum(n));
p(p>0.99)=0;
h_max=h(nnz(p));
ratio_15N_14N(ratio_15N_14N>h_max)=h_max;
% apply Adaptive Histogram Equalization for 14N image
ns_image_14N = (ns_image_14N)-min(min(ns_image_14N));
ns_image_14N=ns_image_14N./(max(max(ns_image_14N)));
ns_image_14N_adp = adapthisteq(ns_image_14N);
ns_image_14N_adp=ns_image_14N_adp./max(max(ns_image_14N_adp));
% plot filtered 15N/14N image
figure(1)
subplot(1,4,subplot_number+2)
imagesc(ns_image_14N_adp.*ratio_15N_14N)
title('15N/14N:filtered')
axis('equal') 
axis([0 512 0 512])
set(gca,'XTick',[], 'YTick', [])
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
colorbar
max_pixel_ns_image=max(max((ns_image_14N_adp.*ratio_15N_14N)));
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
% plot original 15N/14N ratio image
figure(1)
subplot(1,4,subplot_number+3)
% threshold pixel value to remove background is set to 0.13 from histogram 
% analysis
ns_image_14N_adp(ns_image_14N_adp<0.13)=0;
ns_image_14N_adp(ns_image_14N_adp>=0.13)=1;
imagesc(ns_image_14N_adp.*ratio_15N_14N)
title('15N:14N')
axis('equal') 
axis([0 512 0 512])
set(gca,'XTick',[], 'YTick', [])
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
colorbar
max_pixel_ns_image=max(max((ns_image_14N_adp.*ratio_15N_14N)));
caxis([0.05*max_pixel_ns_image 0.9*max_pixel_ns_image])
[ax4,h3]=suplabel(image_title  ,'t');
set(h3,'FontSize',15)
h=gcf;
set(h,'PaperUnits','normalized');
set(h,'Units', 'Inches','PaperUnits', 'Inches','PaperSize', [15 4]);
set(h,'PaperPosition', [0 0 15 4]);
set(gca,'XTick',[], 'YTick', [])
print(gcf, '-dpdf', image_title);

function [ax,h]=suplabel(text,whichLabel,supAxes)
% PLaces text as a title, xlabel, or ylabel on a group of subplots.
% Returns a handle to the label and a handle to the axis.
%  [ax,h]=suplabel(text,whichLabel,supAxes)
% returns handles to both the axis and the label.
%  ax=suplabel(text,whichLabel,supAxes)
% returns a handle to the axis only.
%  suplabel(text) with one input argument assumes whichLabel='x'
%
% whichLabel is any of 'x', 'y', 'yy', or 't', specifying whether the 
% text is to be the xlable, ylabel, right side y-label, 
% or title respectively.
%
% supAxes is an optional argument specifying the Position of the 
%  "super" axes surrounding the subplots. 
%  supAxes defaults to [.08 .08 .84 .84]
%  specify supAxes if labels get chopped or overlay subplots
%
% EXAMPLE:
%  subplot(2,2,1);ylabel('ylabel1');title('title1')
%  subplot(2,2,2);ylabel('ylabel2');title('title2')
%  subplot(2,2,3);ylabel('ylabel3');xlabel('xlabel3')
%  subplot(2,2,4);ylabel('ylabel4');xlabel('xlabel4')
%  [ax1,h1]=suplabel('super X label');
%  [ax2,h2]=suplabel('super Y label','y');
%  [ax3,h2]=suplabel('super Y label (right)','yy');
%  [ax4,h3]=suplabel('super Title'  ,'t');
%  set(h3,'FontSize',30)
%
% SEE ALSO: text, title, xlabel, ylabel, zlabel, subplot,
%           suptitle (Matlab Central)

% Author: Ben Barrowes <barrowes@alum.mit.edu>

%modified 3/16/2010 by IJW to make axis behavior re "zoom" on exit same as
%at beginning. Requires adding tag to the invisible axes
%modified 8/8/2018 to allow cells as text for multiline capability


currax=findobj(gcf,'type','axes','-not','tag','suplabel');

if nargin < 3
 supAxes=[.08 .08 .84 .84];
 ah=findall(gcf,'type','axes');
 if ~isempty(ah)
  supAxes=[inf,inf,0,0];
  leftMin=inf;  bottomMin=inf;  leftMax=0;  bottomMax=0;
  axBuf=.04;
  set(ah,'units','normalized')
  ah=findall(gcf,'type','axes');
  for ii=1:length(ah)
   if strcmp(get(ah(ii),'Visible'),'on')
    thisPos=get(ah(ii),'Position');
    leftMin=min(leftMin,thisPos(1));
    bottomMin=min(bottomMin,thisPos(2));
    leftMax=max(leftMax,thisPos(1)+thisPos(3));
    bottomMax=max(bottomMax,thisPos(2)+thisPos(4));
   end
  end
  supAxes=[leftMin-axBuf,bottomMin-axBuf,leftMax-leftMin+axBuf*2,bottomMax-bottomMin+axBuf*2];
 end
end
if nargin < 2, whichLabel = 'x';  end
if nargin < 1, help(mfilename); return; end

if (~isstr(text) & ~iscellstr(text)) | ~isstr(whichLabel)
  error('text and whichLabel must be strings')
end
whichLabel=lower(whichLabel);

ax=axes('Units','Normal','Position',supAxes,'Visible','off','tag','suplabel');
if strcmp('t',whichLabel)
  set(get(ax,'Title'),'Visible','on')
  title(text);
elseif strcmp('x',whichLabel)
  set(get(ax,'XLabel'),'Visible','on')
  xlabel(text);
elseif strcmp('y',whichLabel)
  set(get(ax,'YLabel'),'Visible','on')
  ylabel(text);
elseif strcmp('yy',whichLabel)
  set(get(ax,'YLabel'),'Visible','on')
  ylabel(text);
  set(ax,'YAxisLocation','right')
end

%for k=1:length(currax), axes(currax(k));end % restore all other axes
for k=1:length(currax), set(gcf,'CurrentAxes',currax(k));end % restore all other axes

if (nargout < 2)
  return
end
if strcmp('t',whichLabel)
  h=get(ax,'Title');
  set(h,'VerticalAlignment','middle')
elseif strcmp('x',whichLabel)
  h=get(ax,'XLabel');
elseif strcmp('y',whichLabel) | strcmp('yy',whichLabel)
  h=get(ax,'YLabel');
end

end