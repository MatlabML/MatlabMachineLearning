function t2 = t2score(data, model)
%% T2 score
if isprop(model, 'xScore_')
    variances = var(model.xScore_, 1);
elseif isprop(model, 'explainedVariances')
    variances = model.explainedVariances;
end

T = model.transform(data);
scoresWhitenSquare = T.^2 ./ variances(1:model.nComp);
t2 = sum(scoresWhitenSquare, 2);
