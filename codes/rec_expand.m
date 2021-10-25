function a = rec_expand(a,b,filler)
% Expands a to cover all of b, filling new leafs using the function filler
  if isnumeric(b)
    if length(b)>length(a)
      if nargin(filler)==1
        a=[a filler(length(b)-length(a))];
      else
        a=[a filler(length(b)-length(a),a)];
      end
    end
  elseif iscell(b)
    if ~iscell(a)
      a=cell(1,length(b));
    elseif length(b)>length(a)
      a=[a cell(1,length(b)-length(a))];
    end
    for i=1:length(b)
      a{i}=rec_expand(a{i},b{i},filler);
    end
  elseif isstruct(b)
    if ~isstruct(a)
      a=struct;
    end
    s=fieldnames(b);
    for i=1:length(s)
      if ~isfield(a,s{i})
        a.(s{i})=[];
      end
      a.(s{i})=rec_expand(a.(s{i}),b.(s{i}),filler);
    end
  else
    disp('Error in rec_expand: format of b is wrong')
  end
end

