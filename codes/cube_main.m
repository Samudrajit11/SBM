function [results]=cube_main(obs,models,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Does Bayesian inference of 'models' on the data in 'obs'
% with optional miscellaneous global options in varargin{1}
% and model options in the cell array varargin{2}
% using Monte Carlo techniques.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
if length(varargin)>0
  misc=varargin{1};
else
  misc=struct;
end
if length(varargin)>1
  options=varargin{2};
else
  options=cell(1,length(models));
  options(1,:)={struct};
end

% Put in default settings where needed
[models,misc,options]=cube_default_settings(obs,models,misc,options);

for i=1:length(models)
  if isfield(options{i},'algorithm')
    algorithm{i}=options{i}.algorithm;
  else
    algorithm{i}=@mc_algorithm;
  end
end

if length(models)==1 || misc.nparpool==0
  for i=1:length(models)
    results{i}=algorithm{i}(obs,models{i},misc);
    fprintf('Generated %i samples for Model %i.\n',length(results{i}.samples),i);
  end
else
  parfor (i=1:length(models),misc.nparpool)
    results{i}=algorithm{i}(obs,models{i},misc);
    fprintf('Generated %i samples for Model %i.\n',length(results{i}.samples),i);
  end
end

for i=1:length(models)
  results{i}.an=ns_analyze(obs,results{i}.samples,models{i},misc);
end

if isfield(misc,'summary') && ~isequal(misc.summary,false)
  cube_print(results,models,misc,obs);
end

if isfield(misc,'save_results')
  save(misc.save_results,'results');
end

disp('CUBE is done.');
toc
end

