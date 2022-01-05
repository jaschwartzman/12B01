%This script is used to process transmitted light images of 12B01
%aggregates and extract the area of aggregate cross-sections.
clear all;
close all;


current_directory='YOUR DIRECTORY HERE';
current_directory=strcat(current_directory,start);
cd(current_directory)
filePattern = fullfile(current_directory, '*.tif'); 
theFiles = dir(filePattern);
names=[];
Areacells_total=[];
for h = 1:length(theFiles)
    h
    baseFileName = theFiles(h).name;
    fullFileName = fullfile(current_directory, baseFileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    fname = fullFileName;
    signal = double(imread(fullFileName)); 
    T = adaptthresh(signal, 0.3);
    BW = imbinarize(signal,T);
    se = strel('disk',5);
    maskb = imerode(maskb,se);
    maskb = double(imdilate(maskb,se)); 
    labels = bwlabel(maskb);
    stats= regionprops(labels,'MinorAxisLength','Circularity'); 
            for s = 1:length(stats);
                junk=stats(s);
                if junk.MinorAxisLength <50;
                    labels(labels==s)=0;
                end
                if junk.Circularity <0.4;
                    labels(labels==s)=0;
                end
            end
    labels2=bwlabel(labels>0);
    stats2=[];
    Areacells=[];
    stats2= regionprops(labels2,'Area'); 
       for j = 1:length(stats2);
            junk2=stats2(j);
            Areacells(j) = junk2.Area;
       end
Areacells_total=[Areacells_total Areacells];
mask=double(labels2>0);
mask(mask==0)=2^16;
baseFileName=baseFileName(1:end-4);
ending='mask.tiff';
filename=append(baseFileName,ending);
%save an image of the segmented areas that were quantified.
imwrite(uint16(signal.*mask),filename,'Tiff');
end
%write areas to individual files for each image
data_end='.csv';
title=strcat(start,data_end);
output = [Areacells_total'];
export(dataset(output),'file',title,'Delimiter',',')
