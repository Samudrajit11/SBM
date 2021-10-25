function a = rec_modify(a,b,func,varargin)
% For each leaf of b modify the corresponging leaf of a according to func. varargin can contain further trees that should have at least the leafs of b.
  if isnumeric(b)
    lb=length(b);
    c=cellfun(@(x) x(1:lb),varargin,'UniformOutput',false);
    a(1:lb)=func(a(1:lb),b,c{:});
  elseif iscell(b)
    for i=1:length(b)
      ci=cellfun(@(bi) bi{i},varargin,'UniformOutput',false);
      a{i}=rec_modify(a{i},b{i},func,ci{:});
    end
  elseif isstruct(b)
    s=fieldnames(b);
    for i=1:length(s)
      ci=cellfun(@(bi) bi.(s{i}),varargin,'UniformOutput',false);
      a.(s{i})=rec_modify(a.(s{i}),b.(s{i}),func,ci{:});
    end
  end
end

