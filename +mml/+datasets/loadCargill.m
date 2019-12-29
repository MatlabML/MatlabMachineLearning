function varargout = loadCargill(returnXy, dataMode)
%% loadCargill
% load near infrared (NIR) spectra data, provided for a contenst 'Shootout 2002'.
% The data consist of three types: 'calibration', 'validation', and 'test'.
% Each type has two NIR spectra; therefore, we may try calibration transfer
% methods. The data are still kept in Eigenvector Inc.'s website.
%
% input
% -----
% returnXy (bool): whether to return Xy or structure of datasets
% dataMode (string): mode of datasets
%
% Syntax
% >> [X, y] = mml.datasets.loadShootout(true);
% >> [X, y] = mml.datasets.loadShootout(true, 'test');
% >> data = mml.datasets.loadShootout(false);
% >> data
% data = 
%   ƒtƒB[ƒ‹ƒh‚ð‚à‚Â struct:
%     calibrate_1: [1~1 struct]
%     calibrate_2: [1~1 struct]
%     calibrate_Y: [1~1 struct]
%      validate_1: [1~1 struct]
%      validate_2: [1~1 struct]
%      validate_Y: [1~1 struct]
%          test_1: [1~1 struct]
%          test_2: [1~1 struct]
%          test_Y: [1~1 struct]


warning('off', 'all');% turn off warnings.
if ~exist('returnXy', 'var'), returnXy=true; end

dataPath='+mml\+datasets\corn.mat';
if exist(dataPath) ~= 2
    url='http://www.eigenvector.com/data/Corn/corn.mat';
    [A, cURL_out] = system(['curl ' url ' > ' dataPath]);
end
load(dataPath);


if returnXy
    varargout{1} = m5spec.data;
    varargout{2} = propvals.data;
else
    % load all data.
    names = {
         'information'
        'm5spec'
        'mp5spec'
        'mp6spec'
        'propvals'
        'm5nbs'
        'mp5nbs'
        'mp6nbs'
        };
    for cnt = 1 : length(names)
        varargout{1}.(names{cnt}) = eval(names{cnt});
    end
end