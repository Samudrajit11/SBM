function u = rec_add1(u,d_u,i,varargin)

if length(i)==1
  if length(varargin)==0
    u(i{1})=u(i{1})+d_u;
  else
    u(i{1})=varargin{1}(u(i{1})+d_u);
  end
elseif isnumeric(i{1})
  u{i{1}}=rec_add1(u{i{1}},d_u,i(2:end),varargin{:});
else 
  u.(i{1})=rec_add1(u.(i{1}),d_u,i(2:end),varargin{:});
end
end
