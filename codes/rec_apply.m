function a = rec_apply(func,a,varargin)
% Applies the function func to the leafs of a. varargin can contain trees who should contain leafs matching a's, which are given to func as input also.
  if isnumeric(a)
    a=func(a,varargin{:});
  elseif iscell(a)
    for i=1:length(a)
      ci=cellfun(@(bi) bi{i},varargin,'UniformOutput',false);
      a{i}=rec_apply(func,a{i},ci{:});
    end
  elseif isstruct(a)
    s=fieldnames(a);
    for i=1:length(s)
      ci=cellfun(@(bi) bi.(s{i}),varargin,'UniformOutput',false);
      a.(s{i})=rec_apply(func,a.(s{i}),ci{:});
    end
  end
end

