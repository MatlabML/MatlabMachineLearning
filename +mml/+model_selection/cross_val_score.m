function scores = cross_val_score(estimator, X, y, cv)
%% scores = cross_val_score(estimator, X, y, cv)
%
% calculate scores for the subsets
% in the manner of cross-validation.

kfold = mml.model_selection.KFold(cv);
[trainIdx, testIdx] = kfold.split(X);
yCv = zeros(size(y));
func = @(yo, yp) mml.metrics.r2score(yo, yp);
scores = zeros(1, cv);
for iFold = 1 : cv
    estimator.fit(X(trainIdx{iFold}, :), y(trainIdx{iFold}, :));
    yCv(testIdx{iFold}, :) = ...
        estimator.predict(X(testIdx{iFold}, :));
    scores(iFold) = func(y(testIdx{iFold}, :), yCv(testIdx{iFold}, :));
end
