classdef SimplePLS < mml.base.BaseEstimator & mml.base.BaseRegressor
    % E. Zhu, R.M. Barnes, A simple iteration algorithm for PLS regression, J. Chemom. (1995). 
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
        function self = SimplePLS(nComp)
            if ~exist('nComp', 'var'), nComp = 2; end
            self.nComp = nComp;
        end
        function self = fit(self, x, y)
            [xSc, self.xMean_, self.xStd_] = zscore(x);
            [ySc, self.yMean_, self.yStd_] = zscore(y);
            [betaInit_, self.weight_, self.xScore_, self.xLoading_, self.yLoading_] = ...
                self.simplePls(xSc, ySc);
%             nObjs = length(self.yStd_);
            beta_ = self.yStd_* (betaInit_./repmat(self.xStd_,self.nComp, 1)');
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
        %% Model evaluation
        function self = fullModel(self, xSc, ySc)
            [betaInit_, self.weight_, self.xScore_, self.xLoading_, self.yLoading_] = ...
                self.simplePls(xSc, ySc, self.nComp);
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
        function [B, W, T, P, Q] = simplePls(self, xtrain, ytrain, nComp)
            if ~exist('nComp', 'var'), nComp = self.nComp; end
            [nSample, nDim] = size(xtrain);
            x = xtrain; y = ytrain;
            XX = x'*x;
            YX = y'*x;
            C = YX'*YX;
            nDim = size(x,2);
            nYDim = size(y,2);
            E = eye(nDim);
            P = zeros(nDim, nComp);
            Q = zeros(nYDim, nComp);
            W = zeros(nDim, nComp);
            for iIter = 1 : nComp
                [V, D] = eig(C);
                d=diag(D);
                ix = find(d==max(d));
                W(:,iIter) = V(:,ix) / norm(V(:,ix),2);
                P(:,iIter) = XX * W(:,iIter);
                Q(:,iIter) = YX * W(:,iIter) / (W(:,iIter)'*XX*W(:,iIter));
                a = E * P(:,iIter);
                E = E - a * a' / (a'*a);
                C = C - a * a' * C/ (a' * a);
            end
            B = W * Q';
            T = x * P;
        end
    end
end
