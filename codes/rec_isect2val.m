function c = rec_isect2val(f2,f1,varargin)
% A value is calculate from running f1 on common leafs of the trees in varargin and then combining the results with f2.

if isnumeric(varargin{1})
  ml=min(cellfun(@length,varargin));
  c=cellfun(@(x) x(1:ml),varargin,'UniformOutput',false);
  c=f2(f1(c{:}));
elseif iscell(varargin{1})
  ml=min(cellfun(@length,varargin));
  b=NaN(1,ml);
  for i=1:ml
    temp=cellfun(@(x) x{i},varargin,'UniformOutput',false);
    b(i)=rec_isect2val(f2,f1,temp{:});
  end
  c=f2(b);
elseif isstruct(varargin{1})
  s=fieldnames(varargin{1});
  for i=2:length(varargin)
    s=intersect(s,fieldnames(varargin{i}));
  end
  b=NaN(1,length(s));
  for i=1:length(s)
    temp=cellfun(@(x) x.(s{i}),varargin,'UniformOutput',false);
    b(i)=rec_isect2val(f2,f1,temp{:});
  end
  c=f2(b);
end
end
