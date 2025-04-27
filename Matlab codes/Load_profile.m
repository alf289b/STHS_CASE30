% ANN LOAD PROFILE
% Add the path to the study case files
% addpath('Path to files')

ndi = 25;   % Initial day number for the forecast
ndf = ndi + 1;   % Final day number

LoadProfile = ANN_365_DAYS_490N((ndi * 24) + 1 : 24 * ndf); % So that the intervals are in 24h
LoadProfile = LoadProfile / max(LoadProfile);
% To ensure our load profile always matches the number of periods (24)

