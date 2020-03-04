classdef ParamGrid
    %% ParamGrid
    % ParamGrid(paramsStructure)
    % Obtain grids
    %
    % >> params = struct();
    % >> params.svm__C = 1:10;
    % >> params.svm__gamma = 1:10;
    % >> pg = ParamGrid(params);
    % >> length(pg.grids)
    % ans =
    %    100
    properties(GetAccess='public', SetAccess='private')
        grids
    end
    methods
        function self = ParamGrid(paramsFields)
            if nargin > 0
                ub = prod(structfun(@numel, paramsFields));
                gridParamsCell = cell(1, ub);
                fieldNameCell  = fieldnames(paramsFields)';
                nField         = length(fieldNameCell);
                valueCell      = cell(1, nField);
                for iField = 1 : nField
                    valueCell{iField} = paramsFields.(fieldNameCell{iField});
                end
                for cnt = 1 : ub
                    [~, ~, paramValue] = mml.model_selection.ParamGrid.calcCombination(valueCell, cnt-1);
                    gridParamsCell{cnt} = mml.model_selection.ParamGrid.setValues(paramValue, fieldNameCell);
                end
            else
                gridParamsCell = [];
            end
            self.grids = gridParamsCell;
        end
    end
    methods(Static)
        function field = setValues(values, fieldNameCell)
            nField = length(fieldNameCell);
            for iField = 1 : nField
                fieldName = fieldNameCell(cellfun(@(x)strcmp(x, fieldNameCell{iField}), fieldNameCell));
                field.(fieldName{1}) = values(iField);
            end
        end
        function decimal = calcDecimal(C)
            if isstruct(C)
                decimal = prod(structfun(@numel, C));
            else
                decimal = prod(cellfun(@numel, C));
            end
        end

        function [combc, comb, ret] = calcCombination(candidates, cnt)
            m = mml.model_selection.ParamGrid.calcDecimal(candidates);
            if cnt <= m
                len = length(candidates);
                c   = zeros(1, len);
                for i = 1:len
                    c(i) = length(candidates{i});
                end
                combc = cell(1, len);
                comb  = zeros(1, len);
                ret   = zeros(1, len);
                for i = 1:len
                    p = 1;
                    if i~=len
                        for j = i+1:len
                            p = p * c(j);
                        end
                    end
                    combc{i} = floor((cnt - mod(cnt, p))/p);
                    comb(i)  = floor((cnt - mod(cnt, p))/p);
                    ret(i)   = candidates{i}(comb(i) + 1);
                    cnt = cnt - combc{i} * p;
                end
            end
        end

    end
end
