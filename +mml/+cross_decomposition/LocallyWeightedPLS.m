classdef LocallyWeightedPLS < mml.base.BaseEstimator & mml.base.BaseRegressor
    properties
        nComp
        coef_
        weight_
        xLoading_
        yLoading_
        xTrain_
        yTrain_
        simType
        xScore_
    end
    methods
        function self = LocallyWeightedPLS(nComp, varargin)
            if~exist('nComp','var'),nComp=2;end
            if~exist('simType','var'),simType='euclidean';end
            self.nComp=nComp;
            self.simType=simType;
            for input = varargin
                self.(input{1}) = input{1};
            end
        end
        function self = fit(self, X, y)
            self.xTrain_ = X;
            self.yTrain_ = y;
        end
        function yPred = predict(self, xQueries)
            nSamples = size(xQueries, 1);
            yPred = zeros(size(xQueries, 1),...
                          size(self.yTrain_, 2));
            for iSample = 1 : nSamples
                xQuery = xQueries(iSample, :);
                omega_ = diag(self.similarity_(self.xTrain_, xQuery));
                scale=@(xy)sum(omega_* xy,1) / sum(diag(omega_));
                xMean_ = scale(self.xTrain_);
                yMean_ = scale(self.yTrain_);
                beta_ = self.nipals_(xMean_, yMean_, omega_, xQuery);
                yPred(iSample, :) = xQuery * beta_;
            end
        end
        function scoreVal = score(self, data, y, func)
            if ~exist('func', 'var'), func = @(y,yp)mml.metrics.r2score(y,yp); end
            scoreVal = func(y, self.predict(data));
        end
    end
    methods(Access=private)
        function beta_ = nipals_(self, xMean, yMean, Omega, xQuery)
            dimData = size(self.xTrain_,2);
            dimRes = size(self.yTrain_,2);
            xr = self.xTrain_ - xMean;
            yr = self.yTrain_ - yMean;
            P = zeros(dimData, self.nComp);
            q = zeros(dimRes, self.nComp);
            w = zeros(dimData, self.nComp);
            xQr = xQuery - xMean;
            for iComp = 1 : self.nComp
                sf = xr'*Omega*yr*yr'*Omega*xr; % square form
                [wr,~] = eigs(sf,1);
                tr = xr*wr;
                P(:, iComp) = xr'* Omega * tr / (tr' * Omega * tr);
                q(:, iComp) = yr' * Omega * tr / (tr' * Omega * tr);
                tQr = xQr * wr;
                w(:, iComp) = wr;
                xr = xr - tr * P(:, iComp)';
                yr = yr - tr * q(:, iComp)';
                xQr = xQr - tQr * P(:, iComp)';
            end
            beta_ = w * pinv(P' * w) * q';
        end
        function distance = similarity_(self, X, xQuery)
            distance = [];
            if strcmp(self.simType, 'euclidean')
                distance = sqrt(sum((X-xQuery).^2, 2));
            end
        end
    end
end