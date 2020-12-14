classdef SVM < mml.base.BaseEstimator & mml.base.BaseRegressor
    properties(SetAccess=public, GetAccess=public)
        cost
        gamma
        kernel = 'gaussian'
        model
    end
    methods(Access=public)
        function self = SVM(cost, gamma, kernel)
            %% mml.svm.SVM(cost, gamma, kernel)
            %
            % cost: regularization coefficients
            % gamma: Gaussian kernel
            % kernel: type of kernel function
            %     gaussian, rbf, linear, polynomial
            if ~exist('cost', 'var'),cost=2;end
            if ~exist('gamma', 'var'),gamma=2;end
            if ~exist('kernel', 'var'), kernel='gaussian';end
            assert(any(strcmp(kernel, {'gaussian', 'rbf', 'linear', 'polynomial'})),...
                'Kernel function must be either gaussian, rbf, linear, or polynomial')
            self.cost = cost;
            self.gamma = gamma;
            kernel = lower(kernel);
        end
        function self = fit(self, x, y)
            self.model = fitrsvm(x,y,'Standardize',true,...
                'KernelFunction', self.kernel,...
                'BoxConstraint', self.cost,...
                'KernelScale',1/sqrt(self.gamma));
        end
        function y = predict(self, x)
            y = predict(self.model, x);
        end
        function proba = predictProba(self, x)
          [~, score] = predict(self.model, x);
          proba = score(:, 2);
        end
        function val = score(self, x, y)
            val = mml.metrics.r2score(y, self.model.predict(x));
        end
    end
end
