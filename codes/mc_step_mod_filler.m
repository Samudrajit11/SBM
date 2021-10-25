function step_mod_extra = mc_step_mod_filler(n,step_mod_now)
  if length(step_mod_now)>0
    step_mod_extra=geomean(step_mod_now)*ones(1,n);
  else
    step_mod_extra=ones(1,n);
  end
end
