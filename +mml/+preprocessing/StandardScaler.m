classdef StandardScaler < mml.base.BaseEstimator & mml.base.TransformerMixin
    %% mml.preprocessing.StandardScaler
    % 
    % scaler = mml.preprocessing.StandardScaler();
    % Xsc = scaler.fitTransform(X, y);

    properties(SetAccess=private, GetAccess=public)
        meanX_
        stdX_
        withMean
        withStd
    end
    methods(Access=public)
        function self = StandardScaler(withMean, withStd)
            if ~exist('withMean', 'var'), withMean=true; end
            if ~exist('withStd', 'var'), withStd=true; end
            self.withMean = withMean;
            self.withStd = withStd;
        end
        function self = fit(self, X, ~)
            if self.withMean, self.meanX_ = mean(X, 1);end
            if self.withStd, self.stdX_ = std(X, 1); end
        end
        function Xsc = transform(self, X, ~)
            Xsc = X;
            if ~isempty(self.meanX_)
                Xsc = Xsc - self.meanX_;
            end
            if ~isempty(self.stdX_)
                Xsc = Xsc ./ self.stdX_;
            end
        end
    end
end