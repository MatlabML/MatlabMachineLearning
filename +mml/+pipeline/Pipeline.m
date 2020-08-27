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
            if~exist('y','var'),y=[];end
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
        function xTr = transform(self, x, y)
            if~exist('y', 'var'), y=[]; end
            xTr = x;
            yTr = y;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTr = self.steps{iStep}.transform(xTr);
            end
            if ismethod(self.steps{end}, 'transform')
                xTr = self.steps{end}.transform(xTr);
            end
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
            xTr = data;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTr = self.steps{iStep}.transform(xTr);
            end
            yPred = self.steps{end}.predict(xTr);
        end
        function val = get(self, methodName, data)
            xTr = self.transform(data);
            val = self.steps{end}.(methodName)(xTr);
        end
        function scoreVal = score(self, data, y)
            xTc = data;
            nSteps = length(self.steps);
            for iStep = 1 : (nSteps - 1)
                xTc = self.steps{iStep}.transform(xTc);
            end
            scoreVal = self.steps{end}.score(xTc, y);
        end
        function self = setParams(self, structure)
            for fieldname = fieldnames(structure)'
                ret = split(fieldname{1}, '__');
                module=ret{1};
                if length(ret)==2
                    paramName=ret{2};
                elseif length(ret) > 2
                    paramName=join(ret(2:end),'__');
                    paramName=paramName{1};
                end
                self.namedSteps.(module).setParams(...
                    struct(paramName, structure.(fieldname{1})));
            end
        end
    end
end
