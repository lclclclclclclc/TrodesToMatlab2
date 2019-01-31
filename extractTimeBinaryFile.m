function extractTimeBinaryFile(fileNameMask, newConfig, reconfigSuffix)
%
%extractTimeBinaryFile(fileNameMask)
%
%Extracts and saves time information from a .rec file. The extracted file
%is saved in a new subfolder in the same directory as the .rec file.
%
%fileNameMask:  this is the name of the rec file without the .rec
%extention (example: 'myfile' for myfile.rec). If multiple .rec files need
%to be stitched together, you can use the part of the filename that all
%files have in common, assuming the first part is the same (example:
%'myfile' for myfile_part1.rec and myfile_part2.rec).  The files will be
%stiched together sorted by the time when the files were created. 
%

% modified to allow reconfiguration
% github.com/lclclclclclclc/TrodesToMatlab2.git

%% Set -output and -reconfig options for executable call
if nargin > 4
    error('extractTimeBinaryFile:TooManyInputs', ...
        'requires at most 3 optional inputs');
end
if nargin > 1
    reconfig = true;
else
    reconfig = false;
end


if reconfig
    if nargin == 2 % no new output suffix specified by user
        timestr = datestr(datetime(), 'yyyymmdd_HHMMss');
        reconfigSuffix = ['_reconfig', newConfig, '_', timestr];
    end
    
    newConfigFileName = [newConfig, '.trodesconf'];
    reconfigString = [' -reconfig ', newConfigFileName];
    
else
    reconfigSuffix = '';
    reconfigString = '';
end

outputString = [' -output ', fileNameMask, reconfigSuffix];

%% Original loop over recording files
% unused by EG so i>1 not tested
recFiles = dir([fileNameMask,'*.rec']);

recFileString = [];
recFileDates = [];
for i=1:length(recFiles)
    recFileDates = [recFileDates;recFiles(i).datenum];
end
[s, sind] = sort(recFileDates);
for i=1:length(sind)
    recFileString = [recFileString ' -rec ' recFiles(sind(i)).name];
end

%% Create call to executable program
%Find the path to the extraction programs
trodesPath = which('trodes_path_placeholder.m');
trodesPath = fileparts(trodesPath);

disp([fullfile(trodesPath,'exporttime'), recFileString, outputString, reconfigString]);

%Beacuse the path may have spaces in it, we deal with it differently in
%windows vs mac/linux

if ispc
    eval(['!',fullfile(trodesPath,'exporttime'), recFileString, outputString, reconfigString]);
else
    escapeChar = '\ ';
    trodesPath = strrep(trodesPath, ' ', escapeChar);
    eval(['!',fullfile(trodesPath,'exporttime'), recFileString, outputString, reconfigString]);
end




