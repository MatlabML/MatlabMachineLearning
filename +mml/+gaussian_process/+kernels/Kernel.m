classdef Kernel
    properties
%         kernel
    end
    methods
        function self = Kernel()
%             if nargin==0, kernel=@(x,y)x'*y; end
%             self.kernel = kernel;
        end
        %https://jp.mathworks.com/help/matlab/matlab_oop/create-a-simple-class.html#buo0ann
        function objnew = plus(obj1, obj2)
            k = @(x,y)obj1.kernel(x,y)+obj2.kernel(x,y);
            objnew = mml.gaussian_process.kernels.Kernel( k );
        end
        function objnew = minus(obj1, obj2)
            k = @(x,y)obj1.kernel(x,y)-obj2.kernel(x,y);
            objnew = mml.gaussian_process.kernels.Kernel( k );
        end
%         function objnew = mtimes(obj1, obj2)
%             k = @(x,y)obj1.kernel(x,y) * obj2.kernel(x,y);
%             objnew = mml.gaussian_process.kernels.Kernel( k );
%         end
        function varargout = subsref(self, s)
            switch s.type
                case '()'
                    varargout = {self.kernel(s.subs{:})};
                case '.'
                    if ischar(s.subs)
                        varargout = {self.(s.subs)};
                    elseif iscell(s.subs)
                        varargout = cellfun(@(ch)self.(ch), s.subs);
                    end
                otherwise
                    error('class input is referred by Class()')
            end
        end
    end
end