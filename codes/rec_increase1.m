function u = rec_increase1(u,d_u,i)

if length(i)==1
  if length(u)<i{1}
    u(i{1})=d_u;
  else
    u(i{1})=u(i{1})+d_u;
  end
elseif isnumeric(i{1})
  if length(u)<i{1}
    u{i{1}}=rec_increase1([],d_u,i(2:end));
  else
    u{i{1}}=rec_increase1(u{i{1}},d_u,i(2:end));
  end
elseif isfield(u,i{1})
  u.(i{1})=rec_increase1(u.(i{1}),d_u,i(2:end));
else
  u.(i{1})=rec_increase1([],d_u,i(2:end));
end
end
