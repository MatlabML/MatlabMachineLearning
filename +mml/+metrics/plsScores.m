close all
data = mml.datasets.loadShootout(false);
Xtrain = data.calibrate_1.data;
Ytrain = data.calibrate_Y.data;
Xtest = data.test_1.data;
Ytest = data.test_Y.data;
import mml.pipeline.makePipeline
pca = makePipeline(mml.preprocessing.StandardScaler(),...
    mml.decomposition.PCA(4));
pls = makePipeline(mml.preprocessing.StandardScaler(),...
    mml.cross_decomposition.PLSRegression(4));
pls = mml.cross_decomposition.PLSRegression(4);
for m = {'pls' 'pca'
        pls, pca}
    name  = m{1};
    model = m{2};
    weightFraction = @(a) a(:, end) ./ a(:, 1);
    ytrain = weightFraction(Ytrain);
    ytest  = weightFraction(Ytest);
    switch name
        case 'pls'
            model.fit(Xtrain, ytrain);
        case 'pca'
            model.fit(Xtrain);
    end
    Ttrain = model.transform(Xtrain);
    Ttest  = model.transform(Xtest);

    figure;
    plot(Ttrain(:,1), Ttrain(:,2),'.');hold on;
    plot(Ttest(:,1), Ttest(:,2),'.');hold off;
    title(name);
end