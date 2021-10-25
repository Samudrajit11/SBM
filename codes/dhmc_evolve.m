function [walker_out,step_mod,varargout]=dhmc_evolve(obs,model,logLstar,walker_in,step_mod,varargin)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Uses a discrete Hamiltonian Monte Carlo technique to find
% a new sample uniformly distributed inside
% the region of parameter space with higher likelihood than the minimum 
% requirement (logLstar). 
%
% Some of the arguments of the function are
% 
% obs - the observations
% walker_in - the walker that constitutes the starting point of the
%   random walk process.
% logLstar - the minimum requirement for the likelihood of the new sample
% step_mod_in - a struct that regulates the average step length during this call of the function. When the remaning parameter space
%   becomes small, the steps are adjusted in length to ensure a
%   success rate of the random walk steps of about 75%.
%
% Contributors to the code in this file: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mc_ts=0.8;
if length(varargin)>0
  misc=varargin{1};
else
  misc=struct;
end
if isfield(misc,'hasty') && misc.hasty
  nsteps=1;
else
  if isnumeric(logLstar)
    nsteps=5;
  else
    nsteps=5;
  end
end
if length(varargin)>1
  options=varargin{2};
else
  options=struct;
end
if isfield(options,'nsteps')
  nsteps=options.nsteps;
end
step_fac=@() 2*rand;

if isequal(logLstar,'H-')
  arrow=-1;
else
  arrow=1;
end

if isfield(options,'hist')
  varargout{1}={options.hist(walker_in)};
end

if isfield(model,'adjust_step_mod')
  step_size=model.adjust_step_mod(step_mod,walker_in.theta);
else
  step_size=step_mod;
end

a_sum=[];
n_tries=[];

walker_out=walker_in;
imp_filler=@(n) arrayfun(@(usign) sign(usign).*log(abs(usign)),2*rand(1,n)-1);
imp=rec_align(struct,walker_out.u,imp_filler);
walker_trial=walker_out;
for i=1:nsteps
  j=rec_first(walker_trial.u,arrow);
  while isfield(options,'skip') && options.skip(j)
    j=rec_next(walker_trial.u,j,arrow);
  end
  while ~isequal(j,0)
    d_u=step_fac()*rec_evoke(step_size,j)*sign(rec_get(imp,j));
    walker_trial.u=rec_add1(walker_trial.u,d_u,j,@(u) mod(u,1));
    if isfield(model,'adjust_u')
      walker_trial.u = model.adjust_u(walker_trial.u,obs);
    end
    walker_trial.theta = model.invprior(walker_trial.u,obs);
    if ~isequal(walker_trial.theta,walker_out.theta)
      walker_trial.logl=model.logl(obs,walker_trial.theta);
    end
    if ~isnumeric(logLstar)
      Delta_U=-walker_trial.logl+walker_out.logl;
      cond=(abs(rec_get(imp,j)) > Delta_U);
      a_sum=rec_increase1(a_sum,min(1,exp(-Delta_U)),j);
      n_tries=rec_increase1(n_tries,1,j);
    else
      Delta_U=0;
      cond=(walker_trial.logl > logLstar);
      a_sum=rec_increase1(a_sum,double(cond),j);
      n_tries=rec_increase1(n_tries,1,j);
    end
    if cond       % Accept trial step
      walker_out=walker_trial;
      imp=rec_add1(imp,-sign(rec_get(imp,j))*Delta_U,j);
      imp=rec_align(imp,walker_out.u,imp_filler);
      if isfield(options,'hist')
        varargout{1}=[varargout{1} {options.hist(walker_out)}];
      end
    else          % Reject and reflect
      imp=rec_add1(imp,0,j,@(p) -p);
      walker_trial=walker_out;
    end
    j=rec_next(walker_trial.u,j,arrow);
    while isfield(options,'skip') && options.skip(j)
      j=rec_next(walker_trial.u,j,arrow);
    end
  end
end
step_mod=rec_expand(step_mod,a_sum,@mc_step_mod_filler);
step_mod=rec_modify(step_mod,a_sum,@(s,a,n) min(1,s.*exp(0.5*(a./n-mc_ts))),n_tries);
end

