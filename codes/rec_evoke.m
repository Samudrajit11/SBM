function val = rec_evoke(u,i)
% Like rec_get, but defaulting to step_mod initial values when the leaf does not exist
if length(i)==1
  if i{1}<=length(u)
    val=u(i{1});
  elseif length(u)>0
    val=geomean(u);
  else
    val=1;
  end
elseif isnumeric(i{1})
  if i{1}<=length(u)
    val=rec_evoke(u{i{1}},i(2:end));
  else
    val=1;
  end
else
  if isfield(u,i{1})
    val=rec_evoke(u.(i{1}),i(2:end));
  else
    val=1;
  end
end
end

