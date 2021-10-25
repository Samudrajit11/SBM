function c = rec_isect2tree(func,varargin)
% A tree is build from running func on common leafs of the trees in varargin. The result only contains leafs corresponding to the intersection of these leafs.

if isnumeric(varargin{1})
  ml=min(cellfun(@length,varargin));
  c=cellfun(@(x) x(1:ml),varargin,'UniformOutput',false);
  c=func(c{:});
elseif iscell(varargin{1})
  ml=min(cellfun(@length,varargin));
  for i=1:ml
    temp=cellfun(@(x) x{i},varargin,'UniformOutput',false);
    c{i}=rec_isect2tree(func,temp{:});
  end
elseif isstruct(varargin{1})
  s=fieldnames(varargin{1});
  for i=2:length(varargin)
    s=intersect(s,fieldnames(varargin{i}));
  end
  c=struct;
  for i=1:length(s)
    temp=cellfun(@(x) x.(s{i}),varargin,'UniformOutput',false);
    c.(s{i})=rec_isect2tree(func,temp{:});
  end
end
end
