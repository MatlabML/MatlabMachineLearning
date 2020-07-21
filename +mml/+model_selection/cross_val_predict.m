function yCv = cross_val_predict(estimator, X, y, cv)
%% yCv = cross_val_predict(estimator, X, y, cv)
%
% predict the objective values 
% in the manner of cross-validation.

kfold = mml.model_selection.KFold(cv);
[trainIdx, testIdx] = kfold.split(X);
yCv = zeros(size(y));
for iFold = 1 : cv
    estimator.fit(X(trainIdx{iFold}, :), y(trainIdx{iFold}, :));
    yCv(testIdx{iFold}, :) = ...
        estimator.predict(X(testIdx{iFold}, :));
end
