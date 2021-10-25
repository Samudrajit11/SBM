function next = rec_next(u,i,arrow)
%Returns the next element of u in direction of arrow starting from i. Returns 0 if at end

if length(i)==1
  if i{1}+arrow<=length(u) && i{1}+arrow>=1
    next={i{1}+arrow};
  else
    next=0;
  end
elseif isnumeric(i{1})
  rest = rec_next(u{i{1}},i(2:end),arrow);
  if isequal(rest,0)
    if i{1}+arrow<=length(u) && i{1}+arrow>=1
      next=[{i{1}+arrow} rec_first(u{i{1}+arrow},arrow)];
    else
      next=0;
    end
  else
    next=[{i{1}} rest];
  end
else
  rest = rec_next(u.(i{1}),i(2:end),arrow);
  if isequal(rest,0)
    s=sort(fieldnames(u));
    j=find(ismember(s,i{1}))+arrow;
    if j<=length(s) && j>=1
      next=[{s{j}} rec_first(u.(s{j}),arrow)];
    else
      next=0;
    end
  else
    next=[{i{1}} rest];
  end
end
end

