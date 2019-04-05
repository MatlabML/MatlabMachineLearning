classdef TransformerMixin < handle
    methods
        function self = TransformerMixin
            % constructor
        end
        function Xt = fitTransform(self, varargin)
            %% fitTransform(self, X, y)
            % Only the third one works, because matlab function that uses
            % varargout omits variables other than the first one.
            % 
            % 1. varargout = { self.fit(varargin{:}).transform(varargin{:}) };
            % 2. X = self.fit(varargin{:}).transform(varargin{:});
            % 3. [X, y] = self.fit(varargin{:}).transform(varargin{:});
            %
            % ---
            % To activate this appropriately, the function must map the
            % output once and then insert them into varargout.
            Xt = self.fit(varargin{:}).transform(varargin{:});
        end
    end
end
