function variable = checkExistence(variable, defaultValue)
%% mml.utils.checkExistence
% check whether a variable exists. If not exists, return a blank matrix [].
% input
% -----
% variable: matrix
% defaultValue: whatever defaultValue. The default of itself is `[]`.
% 
% return
% ------
% variable: original one or `defaultValue`
if ~exist('defaultValue', 'var'), defaultValue = []; end
if ~exist('variable', 'var'), variable = defaultValue; end

