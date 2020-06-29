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
            if self.scaling
                self.std_ = std(x, 1);
            else
                self.std_ = ones(size(self.mean_));
            end
            Xstd = self.autoscaling(x);
            [P, D] = eig(Xstd' * Xstd);
            EV = diag(D);
            ix=cell2mat(arrayfun(@(c)find(c==EV),sort(EV, 'descend'),'un',0))';
            
            self.loadings = P(:, ix);
            self.explainedVariances = EV;
            self.explainedVariancesRatio = EV ./ sum(EV);
        end
        function tTr = transform(self, data)
            tTr = self.autoscaling(data) * self.loadings(:, 1:self.nComps);
        end
        function xRepro = inverseTransform(self, scores)
            xRotate = scores * self.loadings(:, 1:self.nComps)';
            xRepro  = self.autoscaling_inv(xRotate);
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
        function xRepro = autoscaling_inv(self, data)
            if self.scaling
                xRepro = data * self.std_ + self.mean_;
            else
                xRepro = data + self.mean_;
            end
        end
    end
end