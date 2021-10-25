function model=fbm_model(sigma_invprior,H_invprior,m_noise_invprior)
%%%%%%%%%%%%%%%%%%%%%%%
% Function that returns fBm models for use with nested sampling etc
%
% Contributors to the implementation: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%5

labels={'Step deviation:','Hurst parameter:','Measurement noise dev.:'};
if isequal(m_noise_invprior,0)
  model.names=@(disc) sprintf('FBM, no measurement noise');
  model.genu=@(obs) struct('c_sigma',rand(1,1),'c_H',rand(1,1));
  model.adjust_u=@(u,obs) adjust_u_func(u,2);
  model.invprior=@(u,obs) [sigma_invprior(u.c_sigma(1)) H_invprior(u.c_H(1))];
  model.logl=@(obs,theta) fbm_main(obs,0,theta(1),0,theta(2),'l');
  model.x2u=@(obs,theta) fbm_main(obs,0,theta(1),0,theta(2),'u');
  model.u2x=@(u,theta) fbm_main(u,0,theta(1),0,theta(2),'x');
  model.labels=@(disc,obs) {labels{1:2}};
else
  model.names=@(disc) sprintf('FBM+measurement noise');
  model.genu=@(obs) struct('c_sigma',rand(1,1),'c_H',rand(1,1),'c_m_noise',rand(1,1));
  model.adjust_u=@(u,obs) adjust_u_func(u,3);
  model.invprior=@(u,obs) [sigma_invprior(u.c_sigma(1)) H_invprior(u.c_H(1)) m_noise_invprior(u.c_m_noise(1))];
  model.logl=@(obs,theta) fbm_main(obs,0,theta(1),theta(3),theta(2),'l');
  model.x2u=@(obs,theta) fbm_main(obs,0,theta(1),theta(3),theta(2),'u');
  model.u2x=@(u,theta) fbm_main(u,0,theta(1),theta(3),theta(2),'x');
  model.labels=@(disc,obs) labels;
end
model.prior_disc=@(disc) 1;
model.disc=@(theta) [];
model.cont=@(theta) theta;
end

%---

function uout = adjust_u_func(u,p)
  fields={'c_sigma','c_H'};
  if p==3
    fields=union(fields,{'c_m_noise'});
  end
  expected=ones(1,p);
  uout=ns_adjust(u,struct,fields,expected);
end

