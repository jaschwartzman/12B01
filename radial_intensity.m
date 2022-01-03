%%% Code to calculate the average radial intensity profiles for multiple
%%% circular objects in a single image. Used to measure intensity of
%%% fluorescent proteins expressed in cells, or signal from fluorescent
%%% dyes
% 3-16-2020 J. Schwartzman

clear all
close all
current_directory='/Users/j/Desktop/PHA/10x';
cd(current_directory);
filePattern = fullfile(current_directory, '*FITC.tif'); 
theFiles = dir(filePattern);
for h = 1:length(theFiles)
h
FileName = theFiles(h).name;
baseFileName = FileName(1:end-8);
Tx=('Tx.tif');
Txname=strcat(baseFileName,Tx);
fullFileName_Tx = fullfile(current_directory,Txname);
fullFileName = fullfile(current_directory,FileName);
fprintf(1, 'Now reading %s\n', fullFileName);
fname = fullFileName;
signal = double(imread(fullFileName)); 
Txsignal=double(imread(fullFileName_Tx)); 
%this section of the code finds the aggregates and defines centroids and
%radii for each
SE = strel('sphere',5);
filter=imerode(signal,SE);
filter=imdilate(filter,SE);
filter=imerode(signal,SE);
filter=imdilate(filter,SE);
% [centers,radii] = imfindcircles(filter,[100 500]);
%for 10x images use this:
[centers,radii] = imfindcircles(filter,[20 100]);
cx=[];
cy=[];
cx=(centers(:,1));
cy=(centers(:,2));
AllProfiles=[];
AllProfilesTx=[];
%this part of the code finds the radial average for each aggregate
for z=1:length(cx)
radius=radii(z);
ycentroid=cy(z);
xcentroid=cx(z);
maxDistance=round(2*radii(z));

profileSums = zeros(1, maxDistance);
profileSumsTx = zeros(1, maxDistance);
profileCounts = zeros(1, maxDistance);
Y=0;
X=0;
% Scan the original image getting gray level, and scan edtImage getting distance.
% Then add those values to the profile.
for Y = round(ycentroid-radius) : (round(ycentroid+radius))
	for X = round(xcentroid-radius) : round(xcentroid+radius)
		if Y<size(signal,1) && X<size(signal,2) && Y>0 && X>0
            thisDistance = round(sqrt(((X-xcentroid)^2) + ((Y-ycentroid)^2)));
		if thisDistance <= 0
			continue;
		end
		profileSums(thisDistance) = profileSums(thisDistance) + double(signal(Y, X));
        profileSumsTx(thisDistance) = profileSumsTx(thisDistance) + double(Txsignal(Y, X));
		profileCounts(thisDistance) = profileCounts(thisDistance) + 1;
        end
	end
end
averageRadialProfileGR = profileSums ./ profileCounts;
averageRadialProfileTx = profileSumsTx ./ profileCounts;
AllProfiles{z}=averageRadialProfileGR(1:floor(radius));
AllProfilesTx{z}=averageRadialProfileTx(1:floor(radius));
end

% Divide the sums by the counts at each distance to get the average profile
% baseFileName=baseFileName(1:end-4);
ending='profiles.png';
profileimage=append(FileName,ending);

for i = 1:length(AllProfiles)
    plot(AllProfiles{i},'g');hold on
    plot(AllProfilesTx{i},'r');hold on
    output=AllProfiles{i};
    output_Tx=AllProfilesTx{i};
    data_end='.csv';
    index=num2str(i);
    title=strcat(baseFileName,index,data_end);
    headers = {'eGFP_signal','Pflp_mKate_signal'};
    data=table(output',output_Tx','Variablenames',headers);
    writetable(data,title);
end
    saveas(gcf,profileimage);
    close all
end