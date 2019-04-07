classdef GridSearchCV < mml.base.BaseEstimator
    properties
        estimator
        params
        bestEstimator
        bestParams
        scores = [];
        scoring
        nFold
    end
    methods
        function self = GridSearchCV(estimator, params, cv, scoring)
            %% mml.model_selection.GridSearchCV
            % model = GridSearchCV(estimator, params, cv, scoring)
            if ~exist('cv', 'var'), cv=5; end
            if ~exist('scoring', 'var'), scoring='mean'; end
            self.estimator = estimator;
            self.params = params;
            self.nFold = cv;
            self.scoring = scoring;
        end
        function self = fit(self, x, y)
            % Grid Search
            grids = mml.model_selection.ParamGrid(self.params).grids;
            nGrids = length(grids);
            self.scores = zeros(1, nGrids);

            kfold = mml.model_selection.KFold(self.nFold);
            [trainIdx, testIdx] = kfold.split(x);
            for iGrid = 1 : nGrids
                self.estimator.setParams(grids{iGrid});
                if strmatch(self.scoring, 'mean')
                    localScore = zeros(1,self.nFold);
                else
                    yCv = zeros(size(y));
                end
                for iFold = 1 : self.nFold
                    self.estimator.fit(x(trainIdx{iFold},:), ...
                        y(trainIdx{iFold},:));
                    if strmatch(self.scoring, 'mean')
                        localScore(iFold)=...
                            self.estimator.score(x(testIdx{iFold},:),...
                            y(testIdx{iFold},:));
                    else
                        yCv(testIdx{iFold}) = self.estimator.predict(x(testIdx{iFold},:));
                    end
                end
                if strmatch(self.scoring, 'mean')
                    self.scores(iGrid) = mean(localScore);
                else
                    self.scores(iGrid) = mml.metrics.r2score(y, yCv);
                end
            end
            indexMaxScore = find(self.scores==max(self.scores), 1);
            self.bestEstimator = self.estimator.setParams(grids{indexMaxScore});
            self.bestEstimator.fit(x, y);
            self.bestParams = grids{indexMaxScore};
        end
        function scoreVal = score(self, data, y)
            % TODO: r2score can be replaced.
            scorefun = @(y, ypred) mml.metrics.r2score(y, ypred);
            scoreVal = scorefun(y, self.bestEstimator.predict(data));
        end
        function yPred = predict(self, data)
            yPred = self.bestEstimator.predict(data);
        end
    end
end
