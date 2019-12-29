function varargout = loadShootout(returnXy, dataMode)

if ~exist('returnXy', 'var'), returnXy=true; end

dataFile='+mml\+datasets\boston_house_prices.csv';
if exist(dataFile,'file')~=2,
    url='https://raw.githubusercontent.com/scikit-learn/scikit-learn/7b136e92acf49d46251479b75c88cba632de1937/sklearn/datasets/data/boston_house_prices.csv';
    [A, cURL_out] = system(['curl ' url ' > ' dataFile]);
end
data=csvread(dataFile,2,1);


if returnXy
    X=data(:, 1:(end-1));
    y=data(:,end);
    varargout{1} = X;
    varargout{2} = y;
else
    varargout{1} = data;
end
