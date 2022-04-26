%Quanify fluorescence intensity of cells and size of object
%Output is area of object (pixels squared) and intensity of PHA. Camera
%pixel size is 6.5/40x µm. For this dataset, have eGFP-labeled cells.
clear all;
close all;
current_directory='/Users/j/Desktop/';
cd(current_directory)
filePattern_G = fullfile(current_directory, '*w2FITC.TIF'); 
filePattern_Tx = fullfile(current_directory, '*w1TxRd.TIF'); 
theFiles = dir(filePattern_G);
for h = 1:length(theFiles)
    h
    clear labels labels2
    names=[];
    Areacells_total=[];
    Intensitycells_totalG=[];
    Intensitycells_totalR=[];
    FileName = theFiles(h).name;
    replicate=FileName(9);
    baseFileName = FileName(1:end-11);
    GFP='_w2FITC';
    mk='_w1TxRd';
    ending='.tif';
    GFPfile=strcat(baseFileName,GFP,ending);
    GFPfile=fullfile(current_directory,GFPfile);
    mKfile=strcat(baseFileName,mk,ending)
    mkfile=fullfile(current_directory,mKfile);
    fullFileName = fullfile(current_directory, FileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    eGFP = double(imread(GFPfile)); 
    eGFP=imgradient(eGFP);
%     eGFP = double((eGFP-min(min(eGFP))));
    maskG=double(eGFP>2.5*mean2(eGFP));
    maskG=imfill(maskG,'holes');
%     maskG = bwlabel(maskG);
    signalG=eGFP.*maskG;
    
    mKate = double(imread(mKfile)); 
    signalR=imgradient(mKate);
    maskR = double(signalR>4.*mean2(signalR)); 
    maskR=imfill(maskR,'holes');
%     maskR = bwlabel(maskR);
    signalR=mKate.*maskR;

    maskb=maskG;
    labels = bwlabel(maskb);
        stats= regionprops(labels,'MinorAxisLength','Area'); 
            for s = 1:length(stats);
                junk=stats(s);
                if junk.Area <150;
                    labels(labels==s)=0;
                end
            end
    labels2=bwlabel(labels>0);
    
    %quantify area of objects and eGFP/mKate intensity for each
    statsG=[];
    Areacells=[];
    IntensitycellsG=[];
    statsG= regionprops(labels2,signalG,'Area','MeanIntensity'); 
%     statsG= regionprops(labels2,eGFP,'Area','MeanIntensity'); 
       for j = 1:length(statsG);
            junk2=statsG(j);
            Areacells(j) = junk2.Area;
            IntensitycellsG(j)=junk2.MeanIntensity;
       end
    Areacells_total=[Areacells_total Areacells];
    Intensitycells_totalG=[Intensitycells_totalG IntensitycellsG];
    
    statsR=[];
    IntensitycellsR=[];
    statsR= regionprops(labels2,signalR,'Area','MeanIntensity'); 
%     statsR= regionprops(labels2,mKate,'Area','MeanIntensity');
       for j = 1:length(statsG);
            junk3=statsR(j);
            IntensitycellsR(j)=junk3.MeanIntensity;
       end
    Intensitycells_totalR=[Intensitycells_totalR IntensitycellsR];
%write area and intensity to a file for each image
data_name=strcat(baseFileName,replicate);
data_end='mask.csv';
filename=strcat(data_name,data_end);
titles = {'Total_Area','mKate_signal','eGFP_signal'};
data = table(Areacells_total',Intensitycells_totalR',Intensitycells_totalG','VariableNames',titles);
writetable(data,filename);  
end

