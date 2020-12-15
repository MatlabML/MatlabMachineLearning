classdef KernelPLS < mml.base.BaseEstimator & mml.base.BaseRegressor
    %< matlab.mixin.Copyable
    %
    % Reference
    %  R. Rosipal, L.J. Trejo, N. Cristianini, J. Shawe-Taylor,
    % B. Williamson, Kernel Partial Least Squares Regression in
    % Reproducing Kernel Hilbert Space, J. Mach. Learn. Res. 2
    % (2001) 97–123.
    properties
        nComp
        gamma
        dualCoef % regression coefficient for the kernel PLS
        kernelType
        scaleY
        xTrain
        yTrain
        yMean_
        yStd_
        K0
        T % PLS x-scores
        U % PLS y-scores
    end
    methods
        function self = KernelPLS(nComp, gamma, kernelType, scaleY)
            if~exist('nComp','var'),nComp=2;end
            if~exist('gamma','var'),gamma=1;end
            if~exist('kernelType','var'),kernelType='rbf';end
            if~exist('scaleY','var'),scaleY='normal';end
            assert(any(strcmp(kernelType,{'linear','rbf'})),...
                ['Either of `linear` or `rbf` kernel is accepted' ...
                    'your input is ' kernelType]);
            assert(any(strcmp(scaleY, {'normal','dirichlet','both','none'})),...
                ['Correct to either of `normal` `dirichlet` `both` or `none`. ' ...
                    'your input is ' scaleY]);
            self.nComp=nComp;
            self.gamma=gamma;
            self.kernelType=kernelType;
            self.scaleY=scaleY;
        end
        function self = fit(self, x, y)
            [nSamples, ~] = size(x);% nTargets = size(y, 2);
            self.xTrain = x;
            %self.yTrain = y;
            [self.yTrain, self.yMean_, self.yStd_] = self.scalingY(y);

            K = self.kernel(x, 'rbf');
            self.K0 = K;
            K = self.centering(K);
            Kl= self.kernel(y, self.kernelType);
%             Kl = self.centering(Kl);
            self.T = zeros(nSamples, self.nComp);% PLS x-scores
            self.U = zeros(nSamples, self.nComp);% PLS y-scores
            for iComp = 1 : self.nComp
                [V,D] = eig(K*Kl);
                ixMax=find(diag(D)==max(diag(D)),1,'first');
                t = V(:,ixMax);
                u = Kl * t;
                % store the score vector
                self.T(:,iComp) = t;
                self.U(:,iComp) = u;
                % update
                K = (eye(nSamples)-t*t') * K * (eye(nSamples)-t*t');
                Kl = (eye(nSamples)-t*t') * Kl * (eye(nSamples)-t*t');
            end
            K0 = self.centering(self.kernel(x, 'rbf'));%#ok
            self.dualCoef = self.U * inv(self.T'*K0*self.U)*self.T'*y;%#ok
        end
        function yPred = predict(self, data)
            Kc = self.kernel(data, self.xTrain, 'rbf');
            if all(size(Kc)==size(self.K0)) && all(all(Kc==self.K0))
                yPred = self.centering(Kc) * self.dualCoef;
            else
                yPred = self.centeringTest(Kc, self.K0) * self.dualCoef;
            end
            yPred = yPred .* self.yStd_ + self.yMean_;
        end
        function [yTr, yMean, yStd] = scalingY(self, y)
            switch self.scaleY
                %'normal','dirichlet','both'
                case 'normal'
                    %normal
                    yMean = mean(y, 1);
                    yStd = ones(1, size(y, 2));
                    yTr = y;
                case 'dirichlet'
                    %dirichlet normal
                    yMean = dirichletMean(y);
                    yTr = y-yMean;
                    yStd = ones(1, size(y, 2));
                case 'both'
                    %dirichlet normal
                    yMean = dirichletMean(y);
                    yDir = y-yMean;
                    yMean = yMean + mean(yDir, 1);
                    yTr = yDir-mean(yDir, 1);
                    yStd = ones(1, size(y, 2));
                case 'none'
                    yTr = y;
                    yMean = zeros(1, size(y, 2));
                    yStd = ones(1, size(y, 2));
                otherwise
                    error(['The wrong scaleY: ' self.scaleY]);
            end
        end
        function K=kernel(varargin)
            self = varargin{1};
            kernelType = varargin{end};%#ok
            if strcmp(kernelType,'linear')%#ok
                kernelFunc=@(a,b)self.linearKernel(a,b);
            elseif strcmp(kernelType,'rbf')%#ok
                kernelFunc=@(a,b)self.rbfKernel(a,b,self.gamma);
            end
            if nargin == 3
                D = varargin{2};
                K = squareform(pdist(D,@(a,b)kernelFunc(a,b)));
                K = K + eye(size(K));% diagnal elements
            elseif nargin == 4
                D1 = varargin{2}; D2 = varargin{3};
                K = cell2mat(arrayfun(@(ix)kernelFunc(D1(ix,:), D2), ...
                    1:size(D1,1), 'un', 0))';
            else
                error('sth is wrong');
            end
        end
        function scoreVal = score(self, data, y, func)
            if~exist('func','var'),func=@(y,yp)mml.metrics.r2score(y,yp);end
            scoreVal = func(y, self.predict(data));
        end
    end
    methods(Static)
        function Dcnt = centering(D)
            nTraining = size(D, 2);
            In = (eye(nTraining)-ones(nTraining))/nTraining;
            Dcnt = In * D * In;
        end
        function Kcnt = centeringTest(Kt, Kn)
            nTrains = size(Kn, 1);
            nTests = size(Kt, 1);
            %case 3
            left = Kt - (ones(nTests, nTrains) / nTrains) * Kn;
            right = eye(nTrains) - (ones(nTrains) / nTrains);
            Kcnt = left * right;
            %case 2
%             left = Kt - (ones(nTests, nTrains) / nTrains);
%             right = eye(nTrains) - ones(nTrains) / nTrains;
%             Kcnt = left * Kn * right;
            %case 1
%             left = Kt - (ones(nTests, nTrains) / nTrains) * Kn;
%             right = eye(nTrains) - ones(nTrains) / nTrains;
%             Kcnt = left * right;
        end
        function D2=rbfKernel(XI, XJ, gamma)
            %% kernel function for pdist
            % https://www.mathworks.com/help/stats/pdist.html
            %
            % >> squareform(pdist(X,@(a,b)rbfKernel(a,b,1)))
            D2 = exp(-gamma.*sum((XI-XJ).^2,2));
        end
        function D2=linearKernel(XI, XJ)
            %% kernel function for pdist
            % https://www.mathworks.com/help/stats/pdist.html
            %
            % >> squareform(pdist(X,@(a,b)rbfKernel(a,b,1)))
            D2 = XI*XJ';
        end
    end% end methods
end
