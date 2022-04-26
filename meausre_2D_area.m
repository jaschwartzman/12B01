%This script is used to process transmitted light images of 12B01
%aggregates and extract the area of aggregate cross-sections.
clear all;
close all;
current_directory='YOUR FULL DIRECTORY PATH HERE';
cd(current_directory)
filePattern = fullfile(current_directory, 'measure_2D_area_example.tif'); 
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
    filtersignal = imgaussfilt(double(signal),5);
    maskb =double(filtersignal<0.9.*mean2(filtersignal));
    labels = bwlabel(maskb);
    labels = imfill(labels, 'holes');
    stats= regionprops(labels,'MinorAxisLength','Circularity','Centroid'); 
            for s = 1:length(stats);
                junk=stats(s);
                if junk.MinorAxisLength <50;
                    labels(labels==s)=0;
                end
                if junk.Circularity <0.1;
                    labels(labels==s)=0;
                end
                if junk.Centroid(1)<100
                    labels(labels==s)=0;
                end
                if junk.Centroid(2)<100
                    labels(labels==s)=0;
                end
                if junk.Centroid(1)>1900
                    labels(labels==s)=0;
                end
                if junk.Centroid(2)>1900
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
data_end='output.csv';
output = [Areacells_total'];
export(dataset(output),'file',data_end,'Delimiter',',')
