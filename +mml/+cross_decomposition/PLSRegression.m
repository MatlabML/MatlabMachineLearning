classdef PLSRegression < mml.base.BaseEstimator & mml.base.BaseRegressor
    properties
        nComp
        xMean_
        xStd_
        yMean_
        yStd_
        coef_
        weight_
        xLoading_
        yLoading_
        xScore_
    end
    methods
        function self = PLSRegression(nComp)
            if ~exist('nComp', 'var'), nComp = 2; end
            self.nComp = nComp;
        end
        function self = fit(self, x, y)
            [xSc, self.xMean_, self.xStd_] = zscore(x);
            [ySc, self.yMean_, self.yStd_] = zscore(y);
            [betaInit_, self.weight_, self.xScore_, self.xLoading_, self.yLoading_] = ...
                self.nipals(xSc, ySc);
            beta_ = self.yStd_* (betaInit_./repmat(self.xStd_,self.nComp,1)');
            beta0_ = self.yMean_ - self.xMean_ * beta_;%intercept
            self.coef_ = [beta_; beta0_];
            self.coef_ = self.coef_(:, self.nComp);%post-processing
        end
        function yPred = predict(self, data)
            yPred = data * self.coef_(1:(end-1)) + self.coef_(end);
        end
        function scoreVal = score(self, data, y, func)
            if ~exist('func', 'var'), func = @(y,yp)mml.metrics.r2score(y,yp); end
            scoreVal = func(y, self.predict(data));
        end
        function tScore = transform(self, data, y)
            if~exist('y', 'var'),y=[];end
            tScore = (data - self.xMean_)./self.xStd_ * self.xLoading_;
        end
        %% Model evaluation
        function self = fullModel(self, xSc, ySc)
            [betaInit_, self.weight_, self.xScore_, self.xLoading_, self.yLoading_] = ...
                self.nipals(xSc, ySc, self.nComp);
        end
        function t2 = tSquare(self, data)
            if ~exist('data', 'var'), data=[]; end
            lambdas_ = var(self.xScore_);
            nSample = size(data, 1);
            %data -> T
            t2Values = data*self.xLoading_.^2 ./ repmat(lambdas_, nSample, 1);
            t2 = sum(t2Values, 2);
        end
        function q = qStats(self, dataSc)
            [nSample, nFeature] = size(dataSc);
            err = dataSc * (eye(nFeature)-self.xLoading_*self.xLoading_');
            q = cellfun(@norm,mat2cell(err,ones(1,nSample),nFeature));
        end
        %% Inner function
        function [B, W, T, P, Q] = nipals(self, xtrain, ytrain, nComp)
            if ~exist('nComp', 'var'), nComp = self.nComp; end
            % NIPALS algorithm is a kind of SVD
            [nSample, nDim] = size(xtrain);
            B = zeros(nDim, nComp);
            W = zeros(nDim, nComp);
            T = zeros(nSample, nComp);
            P = zeros(nDim, nComp);
            Q = zeros(1, nComp);
            x = xtrain; y = ytrain;
            for iComp = 1 : nComp
                w = x'*y./norm(x'*y);
                t = x*w;
                p = x'*t/(t'*t);
                q = y'*t/(t'*t);

                W(:,iComp) = w;
                P(:,iComp) = p;
                Q(:,iComp) = q;
                T(:,iComp) = t;
                B(:,iComp) = W(:,1:iComp)/(P(:,1:iComp)'*W(:,1:iComp))*Q(:,1:iComp)';

                x = x-t*p';
                y = y-t.*q;
            end
        end
    end
end