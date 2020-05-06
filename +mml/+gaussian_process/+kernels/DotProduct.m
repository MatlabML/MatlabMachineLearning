classdef DotProduct  < mml.gaussian_process.kernels.Kernel
    properties
        sigma0
    end
    methods
        function self = DotProduct(sigma0)
            if nargin > 0
                if~exist('sigma0','var'),sigma0 = 1;end
                self.sigma0 = sigma0;
            end
        end
        function varargout = subsref(self, s)
            if length({s.type})==2 && isequal({s.type}, {'.' '()'})
                % k.kernel(X, Y) 
                % s.subs 
                %   => 'kernel'
                %   => {X, Y}
                [name,XY]=s.subs;
                X=XY{1};
                if length(XY)==2,Y=XY{end};end
                varargout = {self.(name)(X,Y)};
                return
            end
            switch s.type
                case '()'
                    if length(s.subs)==1
                        X = s.subs{1};
                        K = squareform(pdist(X, @self.kernel));
                        nSamples = size(K,1);
                        K = K + diag(arrayfun(@(i)X(i,:)*X(i,:)',1:nSamples));
                        varargout = { K };
                    elseif length(s.subs)==2
                        [X,Y] = s.subs{:};
                        varargout = {self.kernel(X,Y)};
                    else
                        error('the number of input: %d',length(s.subs));
                    end
                case '.' 
                    if ischar(s.subs)
                        varargout = {self.(s.subs)};
                    else
                        varargout = {self.kernel(self.(s.subs{:}))};
                    end
            end
        end
        function ret = kernel(self,x,y)
            ret = y * x' + self.sigma0 ^2;
        end
    end
end