function out = ns_exp_disc(n_scale,n_min,n_max,out_wish)
%%%%%%%%%%%%%%
% Provides an exponential or uniform prior for use with nested sampling
%
% Contributors to the code in this file: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%

if out_wish == 'n'
  if n_scale==Inf
    out=@(u) ceil((n_max-n_min+1)*u)+n_min-1;
  else
    out=@(u) min(ceil(-n_scale*log(1-u*(1-exp(-(n_max-n_min+1)/n_scale)))+n_min-1),n_max);
  end
else
  if n_scale==Inf
    out=@(disc) 1/(n_max-n_min+1);
  else
    parent_prior=@(n) (1-exp(-(n-n_min+1)/n_scale))/(1-exp(-(n_max-n_min+1)/n_scale));
    out=@(disc) parent_prior(disc)-parent_prior(disc-1);
  end
end

