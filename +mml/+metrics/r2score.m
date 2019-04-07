function rSquare = r2score(yObs, yPred)
%% r2score(yObs, yPred)
% $R^2$ score.
% Definition: 1 - (ypred - yobs).^2 ./ (yobs - mean(yobs,1).^2)
rSquare = 1 - sum(( yPred - yObs ).^2, 1) ./ sum(( yObs - mean(yObs,1) ).^2, 1);

end