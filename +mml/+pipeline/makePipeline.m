function pipeline = makePipeline(varargin)
%% pipeline = makePipeline(varargin) 
% 
% Input:
% =====
% Modules related to machine learning, either of preprocessing,
% classification, or regression.
% 
% Example:
% >> import mml.preprocessing.StandardScaler
% >> import mml.cross_decomposition.PLSRegression
% >> mml.pipeline.makePipeline(StandardScaler(), PLSRegression())
chain = struct();
for processor = varargin
    clsName = split(class(processor{1}), '.');
    chain.(lower(clsName{end})) = processor{1};
end
pipeline = mml.pipeline.Pipeline(chain);
end