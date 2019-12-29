function varargout = loadShootout(returnXy, dataMode)
%% loadShootout
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
% >> [X, y, xaxis] = mml.datasets.loadShootout(true);
% >> [X, y, xaxis] = mml.datasets.loadShootout(true, 'test');
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
if ~exist('dataMode', 'var'), dataMode='calibrate'; end
switch dataMode
    case {'calibrate' 'test' 'validate'}
        dataName = dataMode;
        postfix = 1;
    case {'calibrate2' 'test2' 'validate2'}
        dataName = dataMode(1:(end-1));
        postfix = 2;
    otherwise
        error('Invalid second input: `dataMode`.');
end

try
    load('+mml\+datasets\nir_shootout_2002.mat');
catch
    warning('There is no nir_shootout_2002.mat file, so now downloading the file from eigenvector site.');
    url='http://www.eigenvector.com/data/tablets/nir_shootout_2002.mat';
    [A, cURL_out] = system(['curl ' url '> +mml/+datasets/nir_shootout_2002.mat']);
    load('+mml\+datasets\nir_shootout_2002.mat');
end


if returnXy
    varargout{1} = eval([dataName sprintf('_%d.data', postfix)]);
    varargout{2} = eval([dataName '_Y.data']);
    varargout{3} = eval([dataName sprintf('_%d.axisscale{2,1}', postfix)]);
else
    % load all data.
    names = {
        'calibrate_1'
        'calibrate_2'
        'calibrate_Y'
        'validate_1'
        'validate_2'
        'validate_Y'
        'test_1'
        'test_2'
        'test_Y'
        };
    for cnt = 1 : length(names)
        varargout{1}.(names{cnt}) = eval(names{cnt});
    end
end