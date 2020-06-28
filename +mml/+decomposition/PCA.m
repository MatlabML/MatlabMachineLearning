classdef PCA < mml.base.BaseEstimator & mml.base.TransformerMixin
    %
    % scikit-learn-like PCA Implementation.
    % built-in `eig` function in matlab calculates 
    % the definite solution of a eigenvalue problem.
    %
    % Example)
    % >> pcamodel = mml.decomposition.PCA(2, false);
    % >> T = pcamodel.fitTransform(X);
    properties
        mean_% mean
        std_% standard deviation of variables
        nComps
        scaling
        loadings
        explainedVariances
        explainedVariancesRatio
    end
    methods
        function self = PCA(nComps, scaling)
            if~exist('nComps','var'),nComps=2;end
            if~exist('scaling','var'),scaling=true;end
            self.nComps = nComps;
            self.scaling = scaling;
        end
        function self = fit(self, x, ~)
            self.mean_ = mean(x, 1);
            Xstd = (x - self.mean_);
            if self.scaling
                self.std_ = std(x, 1);
                Xstd = Xstd ./ self.std_;
            end
            [self.loadings, D] = eig(Xstd' * Xstd);%, self.nComps
            lambda_ = diag(D);
            lambda_ = lambda_(end:-1:1);
            self.explainedVariances = lambda_;
            self.explainedVariancesRatio = lambda_ ./ sum(lambda_);
        end
        function xTr = transform(self, data)
            xTr = self.autoscaling(data) * self.loadings;
        end
    end
    methods(Access=private)
        function xScale = autoscaling(self, rawData)
            if self.scaling
                xScale = rawData - self.mean_ ./ self.std_;
            else
                xScale = (rawData - self.mean_);
            end
        end
    end
end