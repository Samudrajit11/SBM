function [walker,step_mod]=cube_evolve(obs,model,logLstar,walker,step_mod,varargin)

% initialize step_mod if run for the first time
if isequal(step_mod,[])
  if isfield(model,'evolve_extra')
    step_mod={[],[]};
  else
    step_mod={[]};
  end
end

[walker,step_mod{1}]=dhmc_evolve(obs,model,logLstar,walker,step_mod{1},varargin{:});
if isfield(model,'evolve_extra')
  [walker,step_mod{2}]=model.evolve_extra(obs,model,logLstar,walker,step_mod{2},varargin{:});
end
end
