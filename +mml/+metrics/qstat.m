function q = qstat(data, model)
%% Q statistic 
xHat = model.transform(data) * model.xLoading_'...
          .* model.xStd_ + model.xMean_;
q = sum((data - xHat).^2., 2);