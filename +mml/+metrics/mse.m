function mseVal = mse(yObs, yPred)
%% mse(yObs, yPred)
% mean squared error.
% 
square = @(x) x.^2;
mseVal = mean(square(yObs - yPred), 1);

end