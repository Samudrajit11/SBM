function a = rec_increase(a,b)
% Leafs of b are added to corresponding leafs of a (set to 0 if not exists).
% varargin can optionally contain a function that modifies the resulting leaf.

if isnumeric(b)
  lb=length(b);
  ml=min(length(a),lb);
  a(1:ml)=a(1:ml)+b(1:ml);
  if lb>ml
    a((1+ml):lb)=b((1+ml):lb);
  end
elseif iscell(b)
  lb=length(b);
  ml=min(length(a),lb);
  for i=1:ml
    a{i}=rec_increase(a{i},b{i}); 
  end
  for i=(ml+1):lb
    a{i}=rec_increase([],b{i});
  end
elseif isstruct(b)
  s=fieldnames(b);
  for i=1:length(s)
    if isfield(a,s{i})
      a.(s{i})=rec_increase(a.(s{i}),b.(s{i}));
    else
      a.(s{i})=rec_increase([],b.(s{i}));
    end
  end
end
end

