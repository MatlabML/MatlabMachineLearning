classdef(Abstract) BaseEstimator < handle
    methods
        fit
        function self = setParams(self, params)
            for fname = fieldnames(params)'
                self.(fname{1}) = params.(fname{1});
            end
        end
    end
end