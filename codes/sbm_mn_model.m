function model=sbm_mn_model(sigma1_invprior,alpha_invprior,t0_invprior,mn_invprior)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function that returns a scaled Brownian motion model for use with
% nested sampling
%
% Contributors to the code in this file: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels={'1st step dev.:','alpha:','t0:','mn std.:'};
if isequal(t0_invprior,0)
  model.names=@(disc) sprintf('SBM+MN, t0=0');
  model.genu=@(obs) struct('cr_sigma1',rand,'cr_alpha',rand,'cr_mn',rand);
  model.adjust_u=@(u,obs) adjust_u_func(u,3);
  model.invprior=@(u,obs) [sigma1_invprior(u.cr_sigma1(1)) alpha_invprior(u.cr_alpha(1)) mn_invprior(u.cr_mn)];
  model.logl=@(obs,theta) sbm_mn_main(obs,theta(1),theta(2),0,theta(3),'l');
  model.x2u=@(obs,theta) sbm_mn_main(obs,theta(1),theta(2),0,theta(3),'u');
  model.u2x=@(u,theta) sbm_mn_main(u,theta(1),theta(2),0,theta(3),'x');
  model.labels=@(disc,obs) {labels{1:2},labels{4}};
else
  model.names=@(disc) sprintf('SBM+MN+nonzero t0');
  model.genu=@() struct('cr_sigma1',rand(1,1),'cr_alpha',rand(1,1),'cr_t0',rand(1,1),'cr_mn',rand);
  model.adjust_u=@(u) adjust_u_func(u,4);
  model.invprior=@(u) [sigma1_invprior(u.cr_sigma1(1)) alpha_invprior(u.cr_alpha(1)) t0_invprior(u.cr_t0(1)) mn_invprior(u.cr_mn)];
  model.logl=@(obs,theta) sbm_main(obs,0,theta(1),theta(2),theta(3),theta(4),'l');
  model.x2u=@(obs,theta) sbm_main(obs,0,theta(1),theta(2),theta(3),theta(4),'u');
  model.u2x=@(u,theta) sbm_main(u,0,theta(1),theta(2),theta(3),theta(4),'x');
  model.labels=@(disc) labels;
end
model.prior_disc=@(disc) 1;
model.disc=@(theta) [];
model.cont=@(theta) theta;
end

%---

function uout = adjust_u_func(u,p)
  fields={'cr_sigma1','cr_alpha','cr_mn'};
  if p==4
    fields=union(fields,{'cr_t0'});
  end
  expected=ones(1,p);
  uout=ns_adjust(u,struct,fields,expected);
end

