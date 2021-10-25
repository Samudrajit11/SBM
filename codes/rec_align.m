function impout = rec_align(imp,u,filler)
% Makes sure imp has the same structure as u by removing or adding branches.
% New leafs of p are filled using the function filler.

  if isnumeric(u)
    if ~isnumeric(imp)
      imp=[];
    end
    missing=length(u)-length(imp);
    if missing>0
      impout=[imp filler(missing)];
    else
      impout=imp(1,1:length(u));
    end
  elseif iscell(u)
    impout=cell(1,length(u));
    if ~iscell(imp)
      imp=cell(1,length(u));
    elseif length(u)>length(imp)
      imp = [imp cell(1,length(u)-length(imp))];
    end
    for i=1:length(u)
      impout{i}=rec_align(imp{i},u{i},filler);
    end
  elseif isstruct(u)
    impout=struct;
    if ~isstruct(imp)
      imp=struct;
    end
    s=fieldnames(u);
    for i=1:length(s)
      if ~isfield(imp,s{i})
        imp.(s{i})=[];
      end
      impout.(s{i})=rec_align(imp.(s{i}),u.(s{i}),filler);
    end
  end
end

