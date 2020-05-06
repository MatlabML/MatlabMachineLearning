classdef PairwiseKernel < mml.gaussian_process.kernels.Kernel
    methods
        function self = PairwiseKernel(kernel)
            if~exist('kernel','var'),kernel = @(x,y) x'*y;end
            self.kernel = kernel;
        end
    end
end