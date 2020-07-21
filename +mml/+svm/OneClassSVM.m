classdef OneClassSVM < mml.base.BaseEstimator & mml.base.BaseRegressor
    properties
        cost
        nu
        kernel = 'gaussian'
        model
    end
    methods
        function self = OneClassSVM(kernel, nu)
            if~exist('kernel','var'),kernel='gaussian';end
            if~exist('nu','var'),nu=0.05;end
            self.kernel = kernel;
            self.nu = nu;
        end
        function self = fit(self, X, labels)
            self.model = fitcsvm(X,labels,...
                'KernelScale','auto',...
                'Standardize',true,...
                'KernelFunction', self.kernel,...
                'OutlierFraction', self.nu);
        end
        function [labels, score] = predict(self, data)
            %
            % Returns
            % ===
            % labels: predicted labels
            % score: likelihood
            [labels, score] = predict(self.model, data);
        end
        function self = set.kernel(self, kernel)
            assert(any(strcmp(kernel, {'linear' 'rbf' 'gaussian' 'polynomial'})),...
                'kernel is either of linear, rbf, gaussian or polynomial');
            self.kernel = kernel;
        end
    end
end