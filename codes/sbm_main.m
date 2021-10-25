function out = sbm_main(obs,mu,sigma1,alpha,t0,out_wish)
%%%%%%%%%%%%%%%%%%%%
% Function that returns log-likelihood, u-values or steps depending of out_wish
% being 'l', 'u' or 'x' respectively. The model is scaled Brownian motion.
%
% Contributors to the code in this file:  Samudrajit Thapa and Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dim=length(obs(1,:));
if out_wish=='l'
  N=length(obs(:,1));
  stepdevs=obs-mu(1,:);
  MSD=sigma1^2*((0:N)+t0).^alpha;
  vari=MSD(2:end)-MSD(1:(end-1));
  vari=transpose(vari)*ones(1,dim);
  out=-sum(sum(log(2*pi*vari)))/2-sum(sum(stepdevs.^2./vari))/2;
elseif out_wish=='u'
  N=length(obs(:,1));
  MSD=sigma1^2*((0:N)+t0).^alpha;
  sigmai=sqrt(MSD(2:end)-MSD(1:(end-1)));
  sigmai=transpose(sigmai)*ones(1,dim);
  stepdevs=obs-mu(1,:);
  out=1-erfc(stepdevs./(sqrt(2)*sigmai))/2;
elseif out_wish=='x'
  N=length(obs(:,1));
  MSD=sigma1^2*((0:N)+t0).^alpha;
  sigmai=sqrt(MSD(2:end)-MSD(1:(end-1)));
  sigmai=transpose(sigmai)*ones(1,dim);
  stepdevs = sqrt(2)*sigmai.*erfcinv(2-2*obs);
  out = stepdevs+mu(1,:);
end
end

