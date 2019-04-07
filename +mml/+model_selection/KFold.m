classdef KFold
    properties
        nFold
    end
    methods
        function self = KFold(nFold)
            self.nFold = nFold;
        end
        function [indexTrain, indexTest] = split(self, X)
            nSample = size(X, 1);
            indexTrain = cell(1, self.nFold);
            indexTest = cell(1, self.nFold);
            rng(42, 'twister');
            indexSample = mod(randperm(nSample), self.nFold);
            for iFold = 1 : self.nFold
                indexTrain{iFold} = find(indexSample~=(iFold-1));
                indexTest{iFold} = find(indexSample==(iFold-1));
            end
        end
        %{
                function [xTrain, xTest] = split(self, X)
            nSample = size(X, 1);
            xTrain = cell(1, self.nFold);
            xTest = cell(1, self.nFold);
            rng(42, 'twister');
            indexSample = mod(randperm(nSample), self.nFold);
            for iFold = 1 : self.nFold
                xTrain{iFold} = X(indexSample~=(iFold-1), :);%find(indexSample~=(iFold-1));
                xTest{iFold} = X(indexSample==(iFold-1), :);%find(indexSample==(iFold-1));
            end
        end
%}
    end
end