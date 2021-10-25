function val = rec_get(u,i)

if length(i)==1
  val=u(i{1});
elseif isnumeric(i{1})
  val=rec_get(u{i{1}},i(2:end));
else
  val=rec_get(u.(i{1}),i(2:end));
end
end

