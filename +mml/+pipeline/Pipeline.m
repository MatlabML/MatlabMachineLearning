classdef Pipeline < mml.base.BaseEstimator
    properties(GetAccess=public, SetAccess=protected)
        steps
        namedSteps
        X
        y
    end
    methods
        function self = Pipeline(structSteps)
            self.namedSteps = structSteps;
            self.initStep();
        end
        function self = initStep(self)
            self.steps = {};
            for name = fieldnames(self.namedSteps)'
                self.steps = {self.steps{:} self.namedSteps.(name{1})};
            end
        end
        function self = fit(self, x, y)
            self.X=x; self.y=y;
            xTr = x; yTr = y;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTr = self.steps{iStep}.fitTransform(xTr);
            end
            if ismethod(self.steps{end}, 'fitTransform')
                self.steps{end}.fit(xTr);
            elseif ismethod(self.steps{end}, 'predict') 
                self.steps{end}.fit(xTr, yTr);
            end
        end
        function xTr = transform(self, x, ~)
            xTr = x;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTr = self.steps{iStep}.transform(xTr);
            end
            if ismethod(self.steps{end}, 'transform')
                self.steps{end}.transform(xTr);
            end
        end
        function x = inverseTransform(self, xTr)
            % >> x = model.inverseTransform(xTr);
            assert(true, 'PLEASE implement mml.pipeline.Pipeline');
            if ismethod(self.steps{end}, 'inverseTransform')
                nEstimator = 1;
            else
                nEstimator = 0;
            end
            x = xTr;
            for transformer = self.steps((end-nEstimator):-1:1)
                x = transformer{1}.inverseTransform(x);
            end
        end
        function yPred = predict(self, data)
            xTr = self.transform(data);
            yPred = self.steps{end}.predict(xTr);
        end
        function xTr = fitTransform(self, x, y)
            if ~exist('y', 'var'), y=[]; end
            xTr = x;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTr = self.steps{iStep}.fit(xTr).transform(xTr);
            end
            if ismethod(self.steps{end}, 'fitTransform')
                xTr = self.steps{end}.fitTransform(xTr, y);
            end
        end
        function val = get(self, methodName, data)
            xTr = self.transform(data);
            val = self.steps{end}.(methodName)(xTr);
        end
        function scoreVal = score(self, data, y)
            xTc = self.transform(data);
            scoreVal = self.steps{end}.score(xTc, y);
        end
        function self = setParams(self, structure)
            for fieldname = fieldnames(structure)'
                ret = split(fieldname{1}, '__');
                module=ret{1};
                paramName=ret{2};
                self.namedSteps.(module).setParams(...
                    struct(paramName, structure.(fieldname{1})));
            end
        end
    end
end
