function rmseVal = rmse(yObs, yPred)
%% rmse(yObs, yPred)
% root mean squared error.
% 
square = @(x) x.^2;
rmseVal = sqrt(mean(square(yObs - yPred), 1));

end