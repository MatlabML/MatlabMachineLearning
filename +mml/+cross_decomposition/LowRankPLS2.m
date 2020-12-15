classdef LowRankPLS2 < matlab.mixin.Copyable
    properties
        nComp
        scale
        xMean_
        yMean_
        xStd_
        yStd_
        xWeights_
        xLoadings_
        yLoadings_
        xScores_
        yScores_
        coef_
    end
    methods
        function self = LowRankPLS2(nComp, scale)
            if~exist('nComp','var'),nComp=2;end 
            if~exist('scale','var'),scale=true;end
            self.nComp = nComp;
            self.scale = scale;
        end
        function self = fit(self, x, y)
            [x, y, self.xMean_, self.yMean_, self.xStd_, self.yStd_] = ...
                centerScaleXy(x, y, self.scale);
            [nSamples, nDims] = size(x);
            nTargets = size(y, 2);
            XXt = x*x'; YYt = y*y';
            K = XXt*YYt;% kernel 
            H = eye(nSamples);
            self.xLoadings_ = zeros(nDims, self.nComp);
            self.yLoadings_ = zeros(nTargets, self.nComp);
            self.xScores_ = zeros(nSamples, self.nComp);
            self.yScores_ = zeros(nSamples, self.nComp);
            self.xWeights_ = zeros(nDims, self.nComp);
            for iComp = 1 : self.nComp
                [t, ~] = eigs(H*K, 1);
                %disp(norm(t));
                self.xScores_(:, iComp) = t;
                self.xWeights_(:, iComp) = x'*H'*YYt*t / norm(t);% R
                self.yLoadings_(:, iComp) = (y'*t) / (t'*t);% Q
                a = H * XXt * t;
                b = H' * t;
                %H = H - (H * XXt * t*t'*H)/(t'*H*XXt*t);
                K = K - (a*b'*K) /(a'*b);
                H = H - a*b'/(a'*b);
            end
            self.coef_ = self.xWeights_ * self.yLoadings_';% B=R*Q'
        end
        function yPred = predict(self, data)
            x = (data - self.xMean_)./self.xStd_;
            y = (x * self.coef_);
            yPred = y .* self.yStd_ + self.yMean_;
        end
    end
end
function [X, Y, xmean, ymean, xstd, ystd] = centerScaleXy(X, Y, scale)
    xmean = mean(X, 1);
    ymean = mean(Y, 1);
    X = X - xmean;
    Y = Y - ymean;
    if scale
        xstd = std(X, 1);
        ystd = std(Y, 1);
        X = X ./ xstd;
        Y = Y ./ ystd;
    else
        xstd = ones(1, size(X,2));
        ystd = ones(1, size(Y,2));
    end
end