function t2 = t2score(data, model)
%% T2 score 
variances = var(model.xScore_, 1);
scoresWhitenSquare = model.transform(data).^2 ./ variances;
t2 = sum(scoresWhitenSquare, 2);
