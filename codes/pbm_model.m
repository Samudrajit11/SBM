function model=pbm_model(mu_invprior,sigma_invprior,varargin)
%%%%%%%%%%%%%%%%%%%%%%%
% Function that returns a pure Brownian motion model
%
% Contributors to the implementation: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%
if length(varargin)>0
  head='crg_';
else
  head='cr_';
end

labels={'Step deviation:','x-drift/step: ','y-drift/step: ','z-drift/step: '};
if isequal(mu_invprior,0)
  model.names=@(disc) sprintf('BM');
  model.genu=@(obs) struct([head 'sigma'],rand(1,1));
  model.adjust_u=@(u,obs) adjust_u_func(u,obs,1,head);
  model.invprior=@(u,obs) sigma_invprior(u.([head 'sigma']));
  model.logl=@(obs,theta) pbm_main(obs,0,theta(1),'l');
  model.x2u=@(obs,theta) pbm_main(obs,0,theta(1),'u');
  model.u2x=@(u,theta) pbm_main(u,0,theta(1),'x');
  model.labels=@(disc,obs) {labels{1}};
  if length(varargin)>0
    grad_inv_sigma=varargin{end};
    model.grad=@(obs,theta,u) grad_func(obs,theta,u,0,grad_inv_sigma,head);
  end
else
  model.names=@(disc) sprintf('BM+drift');
  model.genu=@(obs) struct([head 'sigma'],rand(1,1),[head 'mu'],rand(1,size(obs,2)));
  model.adjust_u=@(u,obs) adjust_u_func(u,obs,2,head);
  model.invprior=@(u,obs) [sigma_invprior(u.([head 'sigma'])) mu_invprior(u.([head 'mu']))];
  model.logl=@(obs,theta) pbm_main(obs,theta(2:end),theta(1),'l'); % theta(2:end)=mu
  model.x2u=@(obs,theta) pbm_main(obs,theta(2:end),theta(1),'u');
  model.u2x=@(u,theta) pbm_main(u,theta(2:end),theta(1),'x');
  model.labels=@(disc,obs) {labels{1:(1+size(obs,2))}};
  if length(varargin)>0
    grad_inv_mu=varargin{1};
    grad_inv_sigma=varargin{2};
    model.grad=@(obs,theta,u) grad_func(obs,theta,u,grad_inv_mu,grad_inv_sigma,head);
  end
end
model.prior_disc=@(disc) 1;
model.disc=@(theta) [];
model.cont=@(theta) theta;
end
%---
function [grad,varargout] = grad_func(obs,theta,u,grad_inv_mu,grad_inv_sigma,head)
if isequal(grad_inv_mu,0)
  dlogl_dtheta=pbm_main(obs,0,theta(1),'g');
  dtheta_du=grad_inv_sigma(theta(1),u.([head 'sigma']));
  grad.([head 'sigma'])=dlogl_dtheta(1)*dtheta_du;
  if nargout>0
    varargout{1}=pbm_main(obs,0,theta(1),'l');
  end
else
  dlogl_dtheta=pbm_main(obs,theta(2:end),theta(1),'g');
  dtheta_du=[grad_inv_sigma(theta(1),u.([head 'sigma'])), grad_inv_mu(theta(2:end),u.([head 'mu']))];
  grad.([head 'sigma'])=dlogl_dtheta(1)*dtheta_du(1);
  grad.([head 'mu'])=dlogl_dtheta(2:end).*dtheta_du(2:end);
  if nargout>0
    varargout{1}=pbm_main(obs,theta(2:end),theta(1),'l');
  end
end
end

function uout = adjust_u_func(u,obs,p,head)
  if isfield(u,[head 'sigma']) && length(u.([head 'sigma']))>0
    uout=struct([head 'sigma'],u.([head 'sigma']));
  else
    uout=struct([head 'sigma'],rand(1,1));
  end
  if p==2
    if isfield(u,[head 'mu']) && length(u.([head 'mu']))>0
      uout=setfield(uout,[head 'mu'],u.([head 'mu']));
    else
      uout=setfield(uout,[head 'mu'],rand(1,size(obs,2)));
    end
  end
end

