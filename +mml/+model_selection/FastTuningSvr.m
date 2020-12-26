classdef FastTuningSvr < mml.base.BaseEstimator
    properties
        estimator
        params
        bestEstimator
        bestParams
        nFold
        scores
    end
    methods
        function self = FastTuningSvr(estimator, params, cv)
            %% mml.model_selection.GridSearchCV
            % model = GridSearchCV(estimator, params, cv)
            if ~exist('cv', 'var'), cv=5; end
            self.estimator = estimator;
            self.params = params;
            self.nFold = cv;
        end
        function self = fit(self, x, y)
            import mml.model_selection.GridSearchCV
            %% initialize C and gamma
            cInit = self.initC(y);
            gammaInit = self.initGamma(x, 2.^self.params.gamma);
            self.estimator.setParams(struct('cost',cInit));
            self.estimator.setParams(struct('gamma',gammaInit));
            %% optimize epsilon -> C -> gamma
            listParams={'epsilon' 'cost' 'gamma'};
            for target = {'epsilon' 'cost' 'gamma'}
                elimElem = listParams(~strcmp(listParams, target));
                opt = GridSearchCV(self.estimator, ...
                    rmfield(self.params, elimElem), self.nFold);
                opt.fit(x, y);
                self.scores = opt.scores;
                self.estimator.setParams(opt.bestParams);
            end
            self.estimator.fit(x,y);
            self.bestEstimator = self.estimator;
            for nameParam = listParams
                self.bestParams.(nameParam{1}) = self.estimator.(nameParam{1});
            end
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
    methods(Static)
        function c = initC(yt)
            yMean = mean(yt); yStd = std(yt);
            c = max(abs([yMean-3*yStd, yMean+3*yStd]));
        end
        function gamma = initGamma(x, gammaRange)
            % maximize gamma
            expand=@(a)a(:);
            computeVar = @(gamma) var( expand(nu.gaussKernel(x, gamma)) );
            options = optimoptions('fmincon','Display','off');%,'Algorithm','sqp');
            gamma = fmincon(@(g)-computeVar(g), 1, [],[],[],[],...
                min(gammaRange), max(gammaRange),[], options);
        end
    end
end
