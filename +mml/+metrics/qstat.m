function q = qstat(data, model)
%% Q statistic
%
% Let X = TP'
%
% Q_n = \Sigma || x_n - t_nP' ||^2
xHat = model.inverseTransform(model.transform(data));
q = sum((data - xHat).^2., 2);