function [models,misc,options] = cube_default_settings(obs,models,misc,options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set a number of default settings, if these fields are not already set
% when cube_main is called.
%
% Contributors to the programming: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isfield(misc,'percentiles_at')
  misc.percentiles_at=[0.02 0.16 0.5 0.84 0.98];
end

if ~isfield(misc,'nparpool')
  misc.nparpool = 0;
end

if ~isfield(misc,'summary')
  misc.summary='cube_results.txt';
end

if ~iscell(models)
  models=num2cell(models);
end

if ~iscell(options)
  options=num2cell(options);
end

for i=1:length(models)
  if nargin(models{i}.genu)==0
    models{i}.genu=@(obs) models{i}.genu();
    if isfield(models{i},'adjust_u')
      models{i}.adjust_u=@(u,obs) models{i}.adjust_u(u);
    end
  end 

  if nargin(models{i}.invprior)==1
    models{i}.invprior=@(u,obs) models{i}.invprior(u);
  end 

  if ~isfield(models{i},'disc') || length(models{i}.disc)==0
    models{i}.disc=@(theta) [];
  end
  if isfield(models{i},'labels')
    if isnumeric(models{i}.labels)
      if ~isfield(models{i},'cont') || length(models{i}.cont)==0
        models{i}.cont=@(theta,obs) theta(models{i}.labels>0);
      end
      models{i}.labels=@(disc,obs) arrayfun(@(m) misc.labels(m,:),models{i}.labels(models{i}.labels>0),'UniformOutput',false);
    elseif iscell(models{i}.labels)
      models{i}.labels=@(disc,obs) models{i}.labels;
    end
  end
  if ~isfield(models{i},'cont') || length(models{i}.cont)==0
    models{i}.cont=@(theta,obs) theta;
  elseif nargin(models{i}.cont)==1
    models{i}.cont=@(theta,obs) models{i}.cont(theta);
  end
  if isfield(misc,'summary')
    if ~isfield(models{i},'labels') || length(models{i}.labels)==0
      models{i}.labels=@(disc,obs) arrayfun(@(m) sprintf('Parameter %i: ',m),1:length(models{i}.cont(models{i}.invprior(models{i}.genu(obs),obs),obs)),'UniformOutput',false);
    end
  end
  if isfield(models{i},'checks')
    if ~isfield(models{i},'replicate') && isfield(models{i},'u2x')
      models{i}.replicate=@(obs,theta) models{i}.u2x(rand(size(obs)),theta);
    end
  end
end

