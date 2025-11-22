    
close all;
clc;
clearvars
startup;
pIn = '/Users/sunny/Desktop/Data/20251027_v35_m3/image/merged/'; %% input file folder
pOut = '/Users/sunny/Desktop/Data/20251027_v35_m3/image/processed/'; %% the folder for output results. Note that it ends with \.


%% Ask the user for ds and Fs
ds = input('Enter downsample factor (ds): ');
msPerFrame = input('Enter frame duration in milliseconds (msPerFrame): ');

Fs = 1000 / msPerFrame;  % Convert to frames per second
windowLength = round(Fs);

%% Load files
files_tif  = dir(fullfile(pIn, '*.tif'));
files_tiff = dir(fullfile(pIn, '*.tiff'));
files = [files_tif; files_tiff];
fprintf('Found %d files.\n', numel(files));

for iFile = 1:numel(files)
    fname = files(iFile).name;
    fprintf('\nProcessing: %s\n', fname);

    %% LOAD TIFF INTO 3-D ARRAY
    info = imfinfo(fullfile(pIn, fname));
    nFrames = numel(info);
    datOrg1 = zeros([info(1).Height, info(1).Width, nFrames], 'like', imread(fullfile(pIn,fname),1));
    
    for k = 1:nFrames
        datOrg1(:,:,k) = imread(fullfile(pIn,fname), k);
    end
    
    % smoothing by rolling average
    datOrg1 = movmean(double(datOrg1), windowLength, 3);
    
    %downsample
    dat_down = datOrg1(:,:,1:ds:end);

%% CUSTOM FUNCTION: This corrects for any baseline trends such as photobleaching or changes in the video brightness for some reason.
    % It is quick and dirty and uses the median value for the whole FOV.    
    avg = reshape(median(dat_down,[1 2]),1,1,[]);
    dat_down = dat_down ./ avg * avg(:,:,1);

    
%% save output as tiff
    outName = fullfile(pOut, strrep(fname, 'merged', 'processed'));
    for k = 1:size(dat_down,3)
        if k == 1
            imwrite(uint16(dat_down(:,:,k)), outName, 'tif', 'Compression','none');
        else
            imwrite(uint16(dat_down(:,:,k)), outName, 'tif', 'WriteMode','append', 'Compression','none');
        end
    end
end

fprintf('\nAll TIFF files processed.\n');
