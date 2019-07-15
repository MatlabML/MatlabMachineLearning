classdef FeatureUnion < mml.base.BaseEstimator
    properties(GetAccess=public,SetAccess=protected)
        transformerList = struct();
        transformerWeights = struct();
    end
    methods
        function self = FeatureUnion(transformerList, transformerWeights)
            assert(isstruct(transformerList),...
                'the input `transformerList` must be structure');
            self.transformerList = transformerList;
            if ~exist('transformerWeights','var')
                % initialize weight as 1.
                temp = struct();
                for name = fieldnames(self.transformerList)'
                    temp.(name{1})= 1.;
                end
                self.transformerWeights = temp;
            else
                assert(isstruct(transformerWeights),...
                    'the input `transformerWeights` must be cell structure');
                self.transformerWeights = transformerWeights;
            end
        end
        function self = fit(self, x, ~)
            for name = fieldnames(self.transformerList)'
                n = name{1};
                self.transformerList.(n).fit(x);
            end
        end
        function xTr = transform(self, x, ~)
            cellRet = struct2cell(structfun(@(tr)tr.transform( x ), ...
                self.transformerList,'UniformOutput',false))';
            xTr = cell2mat(cellfun(@(xTemp,frac)xTemp*frac, cellRet,...
                struct2cell(self.transformerWeights)','UniformOutput',false));
        end
        function xTr = fitTransform(self, x, ~)
            cellRet = struct2cell(structfun(@(tr)tr.fitTransform( x ), ...
                self.transformerList,'UniformOutput',false))';
            xTr = cell2mat(cellfun(@(xTemp,frac)xTemp*frac, cellRet,...
                struct2cell(self.transformerWeights)','UniformOutput',false));
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
                self.transformerList.(module).setParams(...
                    struct(paramName, structure.(fieldname{1})));
            end
        end
    end
end