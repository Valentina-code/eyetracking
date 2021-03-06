%sites
cellRec{1}{1} = 'P:\Montijn\DataNeuropixels\Exp2019-11-20\20191120_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{2} = 'P:\Montijn\DataNeuropixels\Exp2019-11-21\20191121_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{3} = 'P:\Montijn\DataNeuropixels\Exp2019-11-22\20191122_MP2_RunDriftingGratingsR01_g0';
cellRec{1}{4} = 'P:\Montijn\DataNeuropixels\Exp2019-11-22\20191122_MP2_R02_RunDriftingGratingsR01_g0';
cellRec{2}{1} = 'P:\Montijn\DataNeuropixels\Exp2019-12-10\20191210_MP3_RunDriftingGratingsR01_g0';%(might have missed onset first stim with eye tracker)
cellRec{2}{2} = 'P:\Montijn\DataNeuropixels\Exp2019-12-11\20191211_MP3_RunDriftingGratingsR01_g0';
cellRec{2}{3} = 'P:\Montijn\DataNeuropixels\Exp2019-12-12\20191212_MP3_RunNaturalMovieR01_g0';
cellRec{2}{4} = 'P:\Montijn\DataNeuropixels\Exp2019-12-13\20191213_MP3_RunDriftingGratingsR01_g0';
cellRec{2}{5} = 'P:\Montijn\DataNeuropixels\Exp2019-12-16\20191216_MP3_RunNaturalMovieR01_g0';
cellRec{2}{6} = 'P:\Montijn\DataNeuropixels\Exp2019-12-17\20191217_MP3_RunDriftingGratingsR01_g0';
cellRec{3}{1} = 'P:\Montijn\DataNeuropixels\Exp2020-01-15\20200115_MP4_RunDriftingGratingsR01_g0';%eye-tracking bad at end
cellRec{3}{2} = 'P:\Montijn\DataNeuropixels\Exp2020-01-16\20200116_MP4_RunDriftingGratingsR01_g0';
cellRec{3}{3} = 'P:\Montijn\DataNeuropixels\Exp2020-01-16\20200116_MP4_RunDriftingGratingsR02_g0';

matRunPre = [...
	1 3;...
	2 2;...
	2 5;...
	3 1;...
	3 2;...
	3 3;...
	1 4;...
	2 1;...
	2 3;...
	2 4;...
	2 6;...
	];

for intRunPrePro=1:size(matRunPre,1)
%% clear variables and select session to preprocess
clearvars -except cellRec matRunPre intRunPrePro
runPreGLX = matRunPre(intRunPrePro,:);
fprintf('Starting pre-processing of "%s" [%s]\n',cellRec{runPreGLX(1)}{runPreGLX(2)},getTime);

%% path definitions
strThisPath = mfilename('fullpath');
strThisPath = strThisPath(1:(end-numel(mfilename)));
addpath(genpath('C:\Code\Acquisition\Kilosort2')); % path to kilosort folder
addpath('C:\Code\Acquisition\npy-matlab'); % for converting to Phy
rootZ = cellRec{runPreGLX(1)}{runPreGLX(2)}; % the raw data binary file is in this folder
strTempDirDefault = 'E:\_TempData'; % path to temporary binary file (same size as data, should be on fast SSD)
strPathToConfigFile = strcat(strThisPath,'subfunctionsPP',filesep); % take from Github folder and put it somewhere else (together with the master_file)
chanMapFile = 'neuropixPhase3B2_kilosortChanMap.mat';

%% check which temp folder to use & clear data
sTempFiles = dir(fullfile(strTempDirDefault,'*.dat'));
for intTempFile=1:numel(sTempFiles)
	boolDir = sTempFiles(intTempFile).isdir;
	strFile = sTempFiles(intTempFile).name;
	if ~boolDir
		delete(fullfile(strTempDirDefault,strFile));
		fprintf('Deleted "%s" from temporary path "%s" [%s]\n',strFile,strTempDirDefault,getTime);
	end
end
fs          = [dir(fullfile(rootZ, '*.bin')) dir(fullfile(rootZ, '*.dat'))];
objFile      = java.io.File('C:\');
dblFreeBytes   = objFile.getFreeSpace;
dblFileSize = fs(1).bytes;
fprintf('Processing "%s" (%.1fGB)\n',fs(1).name,dblFileSize/(1024.^3));
if dblFreeBytes > (dblFileSize*1.05)
	strTempDir = strTempDirDefault;
	fprintf('Using temp dir "%s" (%.1fGB free)\n',strTempDir,dblFreeBytes/(1024.^3));
else
	strTempDir(1) = 'D';
	fprintf('Not enough space on SSD (%.1fGB free). Using temp dir "%s"\n',dblFreeBytes/(1024.^3),strTempDir);
end

%% set params
strExp = 'Exp2019-11-22';
strRec = 'M*_R01*';

%Exp2019-11-21
%Frame 27808 is blink
%Frame 37879 is blink
%Frame 40641 is paw

%% fixed
if ~strcmp(strExp(end),filesep),strExp(end+1) = filesep;end
strMasterPath = 'P:\Montijn\DataNeuropixels\';
strSubPath = 'EyeTracking\';
strSearchFile = ['EyeTrackingRaw*' strRec];
strTempDir = 'C:\_TempData\';
strMiniVidPath = 'D:\Data\Processed\Neuropixels\minivid\';

%find video file
sVidFiles = dir(strcat(strMasterPath,strExp,strSubPath,strSearchFile,'.mp4'));
if numel(sVidFiles) == 1
	strVideoFile = sVidFiles.name;
	strPath = sVidFiles.folder;
else
	error([mfilename ':AmbiguousInput'],'Multiple video files found, please narrow search parameters');
end
if ~strcmp(strPath(end),filesep),strPath(end+1) = filesep;end
if ~strcmp(strTempDir(end),filesep),strTempDir(end+1) = filesep;end

%find params file
sParamsFiles = dir(strcat(strMasterPath,strExp,strSubPath,strSearchFile,'.mat'));
if numel(sParamsFiles) == 1
	strParamsFile = sParamsFiles.name;
else
	error([mfilename ':AmbiguousInput'],'Multiple params files found, please narrow search parameters');
end

%find csv file
sCsvFiles = dir(strcat(strMasterPath,strExp,strSubPath,strSearchFile,'.csv'));
if numel(sCsvFiles) == 1
	strCSVFile = sCsvFiles.name;
else
	error([mfilename ':AmbiguousInput'],'Multiple csv files found, please narrow search parameters');
end

%% copy file to local temp directory
fprintf('Copying "%s" to local path "%s" [%s]\n',strVideoFile,strTempDir,getTime);
[status1,msg1,msgID1] = copyfile([strPath strVideoFile],[strTempDir strVideoFile]);
[status2,msg2,msgID2] = copyfile([strPath strParamsFile],[strTempDir strParamsFile]);
[status3,msg3,msgID3] = copyfile([strPath strCSVFile],[strTempDir strCSVFile]);

%% make figure
fprintf('Processing "%s" [%s]\n',strVideoFile,getTime);
hFig = figure;
ptrAxesMainVideo = subplot(3,3,[1 2 4 5]);
ptrAxesSubVid1 = subplot(3,3,3);
ptrAxesSubVid2 = subplot(3,3,6);
ptrAxesSubVid3 = subplot(3,3,7);
ptrAxesSubVid4 = subplot(3,3,8);
ptrAxesSubVid5 = subplot(3,3,9);

%% load data
sCSV = loadcsv([strTempDir strCSVFile]);
sLoad = load([strTempDir strParamsFile]);
sET = sLoad.sET;
objVid = VideoReader([strTempDir strVideoFile]);

%% get data
intSizeX = objVid.Width;
intSizeY = objVid.Height;
dblTotDur = objVid.Duration;
dblFrameRate = objVid.FrameRate;
intTotFrames = objVid.NumberOfFrames;

%subsample
vecSubY = 1:sET.intSubSample:intSizeY;
vecSubX = 1:sET.intSubSample:intSizeX;

%csv
vecCenterX_CSV = zscore(sCSV.CenterX);
vecCenterY_CSV = zscore(sCSV.CenterY);

%% define variables from parameters
%build structuring elements
intRadStrEl = 2;
objSE = strel('disk',intRadStrEl,4);
%sync threshold luminance
dblThreshSync = sET.dblThreshSync;
intTempAvg = sET.intTempAvg;
%Pupil ROI: [x-from-left y-from-top x-width y-height]
vecRectROI = round(sET.vecRectROI);
vecKeepY = vecRectROI(2):(vecRectROI(2)+vecRectROI(4));
vecKeepX = vecRectROI(1):(vecRectROI(1)+vecRectROI(3));
matMiniVid = zeros(numel(vecKeepY),numel(vecKeepX),intTotFrames,'uint8');

%rebuild ROI
vecPlotRectX = [vecRectROI(1) vecRectROI(1) vecRectROI(1)+vecRectROI(3) vecRectROI(1)+vecRectROI(3) vecRectROI(1)];
vecPlotRectY = [vecRectROI(2) vecRectROI(2)+vecRectROI(4) vecRectROI(2)+vecRectROI(4) vecRectROI(2) vecRectROI(2)];

%Sync ROI: [x-from-left y-from-top x-width y-height]
vecRectSync = round(sET.vecRectSync);
vecSyncY = vecRectSync(2):(vecRectSync(2)+vecRectSync(4));
vecSyncX = vecRectSync(1):(vecRectSync(1)+vecRectSync(3));
%rebuild ROI
vecPlotSyncX = [vecRectSync(1) vecRectSync(1) vecRectSync(1)+vecRectSync(3) vecRectSync(1)+vecRectSync(3) vecRectSync(1)];
vecPlotSyncY = [vecRectSync(2) vecRectSync(2)+vecRectSync(4) vecRectSync(2)+vecRectSync(4) vecRectSync(2) vecRectSync(2)];

%blur width
dblGaussWidth = sET.dblGaussWidth;
if dblGaussWidth == 0
	gMatFilt = gpuArray(single(1));
else
	intGaussSize = ceil(dblGaussWidth*2);
	vecFilt = normpdf(-intGaussSize:intGaussSize,0,dblGaussWidth);
	matFilt = vecFilt' * vecFilt;
	matFilt = matFilt / sum(matFilt(:));
	gMatFilt = gpuArray(single(matFilt));
end
%thresholds
dblThreshReflect = sET.dblThreshReflect;
sglReflT = 200;%single(dblThreshReflect);
dblThreshPupil = sET.dblThreshPupil;
sglPupilT = single(dblThreshPupil);
vecPupilT = (-4:1:1) + sglPupilT;
vecBlinkWindow = round([-0.125 0.125]*dblFrameRate);

%% pre-allocate
%save output
vecPupilTime = nan(1,intTotFrames);
vecPupilVidFrame = nan(1,intTotFrames);
vecPupilSyncLum = nan(1,intTotFrames);
vecPupilSyncPulse = nan(1,intTotFrames);
vecPupilCenterX = nan(1,intTotFrames);
vecPupilCenterY = nan(1,intTotFrames);
vecPupilRadius = nan(1,intTotFrames);
vecPupilEdgeHardness = nan(1,intTotFrames);
vecPupilMeanPupilLum = nan(1,intTotFrames);
vecPupilSdPupilLum = nan(1,intTotFrames);
vecPupilAbsVidLum = nan(1,intTotFrames);
vecPupilRelVidLum = nan(1,intTotFrames);
vecPupilApproxConfidence = nan(1,intTotFrames);
vecPupilApproxRoundness = nan(1,intTotFrames);
vecPupilApproxRadius = nan(1,intTotFrames);
	
%% define color map
matC = ...
	[0 0 0;... %0, nothing
	1 0 0;... %1, reflection
	0 1 0;... %2, potential pupil regions
	1 1 0;... %3, reflection & potential pupil
	0 1 1;... %4, pupil
	1 0 1;... %5, reflection & pupil
	1 1 1;... %6, potential pupil & pupil
	0 0 1;... %7, potential pupil & pupil & reflection
	];

%% perform pupil detection
hTicCompStart = tic;
dblLastShow = -inf;
dblShowInterval = 0.5;
vecPrevLoc = [0;0];
objVid = VideoReader([strTempDir strVideoFile]); %recreate becase of NumberOfFrames... don't ask why...
boolInitDone = false;
intFrame = 0;
intSyncPulse = 0;
boolSyncHigh = false;
while hasFrame(objVid)
	%% read frame and add to buffer
	intFrame = intFrame + 1;
	try
		matVidRaw = readFrame(objVid);
		matVidBuffer = matVidRaw;
	catch
		pause(0.5);
		warning([mfilename ':ReadError'],sprintf('Frame %d/%d (t=%.3s) could not be read',intFrame,intTotFrames,dblCurTime));
	end
	dblCurTime = objVid.CurrentTime;
	
	%select ROI
	dblAbsVidLum = mean(flat(matVidBuffer(:,:,1,:)));
	matVid = imnorm(mean(single(matVidBuffer(:,:,1,:)),4));
	gMatVid = gpuArray(matVid(vecKeepY,vecKeepX));
	matMiniVid(:,:,intFrame) = matVid(vecKeepY,vecKeepX)*255;
	
	%find pupil
	[sPupil,imPupil,imReflection,imBW] = getPupil(gMatVid,gMatFilt,sglReflT,sglPupilT,objSE,vecPrevLoc,vecPupilT);
	%make plotting map
	matPlot = imReflection + imBW*2 + imPupil * 4;
	
	%get synchronization pulse window luminance
	dblSyncLum = mean(flat(matVidBuffer(vecSyncY,vecSyncX,1,end)));
	boolLastSyncHigh = boolSyncHigh;
	boolSyncHigh = dblSyncLum > dblThreshSync;
	if boolSyncHigh && (boolLastSyncHigh ~= boolSyncHigh)
		intSyncPulse = intSyncPulse + 1;
	end
	
	%extract parameters
	vecCentroid = sPupil.vecCentroid; %center in pixel coordinates
	dblRadius = sPupil.dblRadius; %radius in pixels
	dblEdgeHardness = sPupil.dblEdgeHardness; %0 if uniform (no edge), 1 if mask drops from 1 to 0 at exactly the fitted boundary
	dblMeanPupilLum = sPupil.dblMeanPupilLum; %average pupil area intensity
	dblSdPupilLum = sPupil.dblSdPupilLum; %sd of pupil area intensity
	dblApproxConfidence = sPupil.dblApproxConfidence; %confidence of approximated pupil parameters
	dblApproxRoundness = sPupil.dblApproxRoundness; %approximated pupil roundness
	vecApproxCentroid = sPupil.vecApproxCentroid; %approximated pupil centroid
	dblApproxRadius = sPupil.dblApproxRadius; %approximated pupil radius
	
	vecPrevLoc = vecCentroid;
	
	if (dblCurTime - dblLastShow > dblShowInterval) || dblRadius == 0
		%update counter
		dblLastShow = dblCurTime;
		%% video
		%show video with overlays
		imagesc(ptrAxesMainVideo,matVid);
		colormap(ptrAxesMainVideo,'grey');
		hold(ptrAxesMainVideo,'on');
		plot(ptrAxesMainVideo,vecPlotSyncX,vecPlotSyncY,'c--');
		plot(ptrAxesMainVideo,vecPlotRectX,vecPlotRectY,'b--');
		dblX = vecCentroid(1) + vecPlotRectX(1);
		dblY = vecCentroid(2) + vecPlotRectY(1);
		ellipse(ptrAxesMainVideo,dblX,dblY,dblRadius,dblRadius,'Color','r','LineStyle','-','LineWidth',1);
		hold(ptrAxesMainVideo,'off');
		title(ptrAxesMainVideo,sprintf('Frame %d/%d (FR: %.3fs), T=%.3fs/%.3fs, Computation time: %.0fs',intFrame,intTotFrames,dblFrameRate,dblCurTime,dblTotDur,toc(hTicCompStart)));
		
		%regions
		imagesc(ptrAxesSubVid1,matPlot);
		set(ptrAxesSubVid1,'CLim',[0 7]);
		colormap(ptrAxesSubVid1,matC);
		title(ptrAxesSubVid1,strVideoFile,'Interpreter','none');
		
		%blow-up
		imagesc(ptrAxesSubVid2,gMatVid);
		colormap(ptrAxesSubVid2,'grey');
		hold(ptrAxesSubVid2,'on');
		ellipse(ptrAxesSubVid2,vecCentroid(1),vecCentroid(2),dblRadius,dblRadius,'Color','r','LineStyle','-','LineWidth',1);
		axis(ptrAxesSubVid2,'off');
		
		%% curves
		%check which frames to remove due to blinking
		vecBlinkFrames = unique((vecBlinkWindow(1):vecBlinkWindow(end)) + find(abs(nanzscore(vecPupilEdgeHardness)) > 6)');
		vecBlinkFrames(vecBlinkFrames > intFrame) = [];
		vecPlotT = vecPupilTime(1:intFrame);
		
		%get data
		vecPlotPupilX = nanzscore(vecPupilCenterX(1:intFrame));
		vecPlotPupilY = nanzscore(vecPupilCenterY(1:intFrame));
		vecPlotPupilR = nanzscore(vecPupilRadius(1:intFrame));
		
		vecPlotMeanPupLum = nanzscore(vecPupilMeanPupilLum(1:intFrame));
		vecPlotApproxConf = nanzscore(vecPupilApproxConfidence(1:intFrame));
		vecPlotSyncLum = nanzscore(vecPupilSyncLum(1:intFrame));
		
		%remove blinks
		vecPlotPupilX(vecBlinkFrames) = nan;
		vecPlotPupilY(vecBlinkFrames) = nan;
		vecPlotPupilR(vecBlinkFrames) = nan;
		
		vecPlotMeanPupLum(vecBlinkFrames) = nan;
		vecPlotApproxConf(vecBlinkFrames) = nan;
		
		%binkiness
		vecBlinkiness = -nanzscore(vecPupilEdgeHardness(1:intFrame));
		plot(ptrAxesSubVid3,vecPlotT,vecBlinkiness,'r');
		hold(ptrAxesSubVid3,'on');
		plot(ptrAxesSubVid3,vecPlotT,vecPlotSyncLum,'b');
		hold(ptrAxesSubVid3,'off');
		title(ptrAxesSubVid3,'R=Blink likelihood, B=Sync Lum');
		xlabel(ptrAxesSubVid3,'Time (s)');
		ylabel(ptrAxesSubVid3,'Value (z-score)');
		fixfig(ptrAxesSubVid3,0);
		
		%lum
		plot(ptrAxesSubVid4,vecPlotT,vecPlotApproxConf,'b');
		hold(ptrAxesSubVid4,'on');
		plot(ptrAxesSubVid4,vecPlotT,vecPlotMeanPupLum,'r');
		hold(ptrAxesSubVid4,'off');
		title(ptrAxesSubVid4,'R=Pupil Lum, B = Conf');
		xlabel(ptrAxesSubVid4,'Time (s)');
		ylabel(ptrAxesSubVid4,'Value (z-score)');
		fixfig(ptrAxesSubVid4,0);
		
		%x,y,r
		plot(ptrAxesSubVid5,vecPlotT,vecPlotPupilX,'r');
		hold(ptrAxesSubVid5,'on');
		plot(ptrAxesSubVid5,vecPlotT,vecPlotPupilY,'g');
		plot(ptrAxesSubVid5,vecPlotT,vecPlotPupilR,'b');
		hold(ptrAxesSubVid5,'off');
		title(ptrAxesSubVid5,'R=x, G=y, B=Radius');
		xlabel(ptrAxesSubVid5,'Time (s)');
		ylabel(ptrAxesSubVid5,'Value (z-score)');
		fixfig(ptrAxesSubVid5,0);
		drawnow;
		
		
		%check if we should pause
		%if dblCurTime > 4 && dblMajAx == 0
		%	title(ptrAxesSubVid2,'PAUSED')
		%	drawnow;
		%	pause;
		%end
	end
	
	%save output
	vecPupilTime(intFrame) = dblCurTime;
	vecPupilVidFrame(intFrame) = intFrame;
	vecPupilSyncLum(intFrame) = dblSyncLum;
	vecPupilSyncPulse(intFrame) = intSyncPulse;
	vecPupilCenterX(intFrame) = vecCentroid(1);
	vecPupilCenterY(intFrame) = vecCentroid(2);
	vecPupilRadius(intFrame) = dblRadius;
	vecPupilEdgeHardness(intFrame) = dblEdgeHardness;
	vecPupilMeanPupilLum(intFrame) = dblMeanPupilLum;
	vecPupilSdPupilLum(intFrame) = dblSdPupilLum;
	vecPupilAbsVidLum(intFrame) = dblAbsVidLum;
	vecPupilApproxConfidence(intFrame) = dblApproxConfidence;
	vecPupilApproxRoundness(intFrame) = dblApproxRoundness;
	vecPupilApproxRadius(intFrame) = dblApproxRadius;
	
end
%{
%% interpolate detection failures
%initial roundness check
indWrongA = vecPupilApproxConfidence < 1 | vecPupilApproxConfidence > 1.2;
indWrong1 = conv(indWrongA,ones(1,5),'same')>0;
vecAllPoints1 = 1:numel(indWrong1);
vecGoodPoints1 = find(~indWrong1);
vecTempX = interp1(vecGoodPoints1,vecPupilCenterX(~indWrong1),vecAllPoints1);
vecTempY = interp1(vecGoodPoints1,vecPupilCenterY(~indWrong1),vecAllPoints1);
%remove position outliers
indWrongB = abs(nanzscore(vecTempX)) > 4 | abs(nanzscore(vecTempY)) > 4;
%define final removal vector
indWrong = conv(indWrongA | indWrongB,ones(1,5),'same')>0;
vecAllPoints = 1:numel(indWrong);
vecGoodPoints = find(~indWrong);

%fix
vecPupilFixedCenterX = interp1(vecGoodPoints,vecPupilCenterX(~indWrong),vecAllPoints);
vecPupilFixedCenterY = interp1(vecGoodPoints,vecPupilCenterY(~indWrong),vecAllPoints);
vecPupilFixedMajorAxis = interp1(vecGoodPoints,vecPupilRadius(~indWrong),vecAllPoints);
vecPupilFixedMinorAxis = interp1(vecGoodPoints,vecPupilEdgeHardness(~indWrong),vecAllPoints);
vecPupilFixedOrientation = interp1(vecGoodPoints,vecPupilMeanPupilLum(~indWrong),vecAllPoints);
vecPupilFixedEccentricity = interp1(vecGoodPoints,vecPupilSdPupilLum(~indWrong),vecAllPoints);
vecPupilFixedRoundness = interp1(vecGoodPoints,vecPupilApproxConfidence(~indWrong),vecAllPoints);
%}
%% gather data
%check which frames to remove
intLastFrame = find(~(isnan(vecPupilApproxConfidence) | vecPupilApproxConfidence == 0),1,'last');
vecPupilTime = vecPupilTime(1:intLastFrame);
vecPupilVidFrame = vecPupilVidFrame(1:intLastFrame);
vecPupilSyncLum = vecPupilSyncLum(1:intLastFrame);
vecPupilSyncPulse = vecPupilSyncPulse(1:intLastFrame);
vecPupilCenterX = vecPupilCenterX(1:intLastFrame);
vecPupilCenterY = vecPupilCenterY(1:intLastFrame);
vecPupilRadius = vecPupilRadius(1:intLastFrame);
vecPupilEdgeHardness = vecPupilEdgeHardness(1:intLastFrame);
vecPupilMeanPupilLum = vecPupilMeanPupilLum(1:intLastFrame);
vecPupilAbsVidLum = vecPupilAbsVidLum(1:intLastFrame);
vecPupilSdPupilLum = vecPupilSdPupilLum(1:intLastFrame);
vecPupilApproxConfidence = vecPupilApproxConfidence(1:intLastFrame);
vecPupilApproxRoundness = vecPupilApproxRoundness(1:intLastFrame);
vecPupilApproxRadius = vecPupilApproxRadius(1:intLastFrame);
	
%put in struct
sPupil = struct;
sPupil.vecPupilTime = vecPupilTime;
sPupil.vecPupilVidFrame = vecPupilVidFrame;
sPupil.vecPupilSyncLum = vecPupilSyncLum;
sPupil.vecPupilSyncPulse = vecPupilSyncPulse;
%fixed
%{
sPupil.vecPupilIsInterpolated = [];%indWrong;
sPupil.vecPupilCenterX = vecPupilFixedCenterX;
sPupil.vecPupilCenterY = vecPupilFixedCenterY;
sPupil.vecPupilMajorAxis = vecPupilFixedMajorAxis;
sPupil.vecPupilMinorAxis = vecPupilFixedMinorAxis;
sPupil.vecPupilOrientation = vecPupilFixedOrientation;
sPupil.vecPupilEccentricity = vecPupilFixedEccentricity;
sPupil.vecPupilRoundness = vecPupilFixedRoundness;
%}
%raw
sPupil.vecPupilRawCenterX = vecPupilCenterX;
sPupil.vecPupilRawCenterY = vecPupilCenterY;
sPupil.vecPupilRawRadius = vecPupilRadius;
sPupil.vecPupilRawEdgeHardness = vecPupilEdgeHardness;
sPupil.vecPupilRawMeanPupilLum = vecPupilMeanPupilLum;
sPupil.vecPupilRawAbsVidLum = vecPupilAbsVidLum;

sPupil.vecPupilRawSdPupilLum = vecPupilSdPupilLum;
sPupil.vecPupilRawApproxConfidence = vecPupilApproxConfidence;
sPupil.vecPupilRawApproxRoundness = vecPupilApproxRoundness;
sPupil.vecPupilRawApproxRadius = vecPupilApproxRadius;

%create filename
strVideoOut = strrep(strVideoFile,'Raw','Processed');
strVideoOut(find(strVideoOut=='.',1,'last'):end) = [];
strVideoOut = strcat(strVideoOut,'.mat');

%extra info
sPupil.strVideoFile = strVideoFile;
sPupil.sET = sET;
sPupil.strMiniVidPath = strMiniVidPath;
sPupil.strMiniVidFile = strVideoOut;

%% save file
%save
save([strPath strVideoOut],'sPupil');
fprintf('Saved data to %s (source: %s, path: %s) [%s]\n',strVideoOut,strVideoFile,strPath,getTime);

%save mini vid
save([strPath strVideoOut],'matMiniVid');
save([strMiniVidPath strVideoOut],'matMiniVid');
fprintf('Saved data to %s (source: %s, path: %s) [%s]\n',strVideoOut,strVideoFile,strPath,getTime);

%% plot
figure
plot(sPupil.vecPupilTime,sPupil.vecPupilRawCenterX);
hold on
plot(sPupil.vecPupilTime,sPupil.vecPupilCenterX);
hold off
title(sprintf('Pupil x-pos, %s',strVideoFile),'Interpreter','none');
xlabel('Time (s)');
ylabel('Horizontal position (pixels)');
fixfig
end