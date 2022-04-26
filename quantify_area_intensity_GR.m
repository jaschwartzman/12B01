%Quanify fluorescence intensity of cells and size of object
%Output is area of object (pixels squared) and intensity of mKate2 label or
%eGFP in the object. Camera pixel size is 6.5 µm
clear all;
close all;
current_directory='PATH/TOP/YOUR/DIRECTORY/HERE';
cd(current_directory)
filePattern_GFP = fullfile(current_directory, '*G*.tif'); 
filePattern_Tx = fullfile(current_directory, '*TR*.tif'); 
filePattern_Brightfield = fullfile(current_directory, '*BF*.tif');
theFiles = dir(filePattern_Brightfield);

for h = 1:length(theFiles)
    h
    clear labels labels2
    names=[];
    Areacells_total=[];
    Intensitycells_totalG=[];
    Intensitycells_totalR=[];
    FileName = theFiles(h).name;
    replicate=FileName(9);
    baseFileName = FileName(1:end-8);
    GFP='G_';
    mK='TR_';
    ending='.tif';
    GFPfile=strcat(baseFileName,GFP,replicate,ending);
    GFPfile=fullfile(current_directory,GFPfile);
    mKfile=strcat(baseFileName,mK,replicate,ending)
    mkfile=fullfile(current_directory,mKfile);
    fullFileName = fullfile(current_directory, FileName);
    fprintf(1, 'Now reading %s\n', fullFileName);
    
    eGFP = double(imread(GFPfile)); 
    signalG=imgradient(eGFP);
    maskG=double(signalG>4.*mean2(signalG)); 
    maskG=imfill(maskG,'holes');
%     maskG = bwlabel(maskG);
    signalG=eGFP.*maskG;
    
    mKate = double(imread(mKfile)); 
    signalR=imgradient(mKate);
    maskR = double(signalR>4.*mean2(signalR)); 
    maskR=imfill(maskR,'holes');
%     maskR = bwlabel(maskR);
    signalR=mKate.*maskR;

    maskb=maskG+maskR;
    labels = bwlabel(maskb);
        stats= regionprops(labels,'MinorAxisLength','Area'); 
            for s = 1:length(stats);
                junk=stats(s);
                if junk.Area <10;
                    labels(labels==s)=0;
                end
            end
    labels2=bwlabel(labels>0);
    
    %quantify area of objects and eGFP/mKate intensity for each
    statsG=[];
    Areacells=[];
    IntensitycellsG=[];
    statsG= regionprops(labels2,signalG,'Area','MeanIntensity'); 
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

