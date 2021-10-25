function first = rec_first(u,arrow)
% return the index for the first value in u (arrow==1) or last (arrow==-1)
if isnumeric(u)
  if arrow==1
    first={1};
  else
    first={length(u)};
  end
elseif iscell(u)
  if arrow==1
    first=[{1},rec_first(u{1},1)];
  else
    first=[{length(u)},rec_first(u{end},-1)];
  end
elseif isstruct(u)
  s=sort(fieldnames(u));
  if arrow==1
    first=[{s{1}},rec_first(u.(s{1}),1)];
  else
    first=[{s{end}},rec_first(u.(s{end}),-1)];
  end
end
end
