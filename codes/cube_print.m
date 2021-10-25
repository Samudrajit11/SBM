function cube_print(results,models,misc,obs)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prints out a summary of 'results' to the text file misc.summary
%
% Contributors to the code in this file: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fname = misc.summary;
if isfield(misc,'append')
  fid = fopen(fname,'a');
  fprintf(fid,misc.append);
else
  fid = fopen(fname,'w');
end

% Find best model (choose one)
if all(cellfun(@(f) isfield(f,'logZ'),results)) && all(cellfun(@(x) length(x.logZ)>0,results))
  logZ_tot = ns_logsumexp(cellfun(@(x) x.logZ,results));
  for i = 1:length(models)
      evi(i) = exp(results{i}.logZ-logZ_tot);
  end
  [~,best] = max(evi);
  fprintf(fid,'CUBE run found highest evidence for MODEL %i (share of total sum: %.2f%%).\n',best,100*evi(best));
  else
    best=1;
    fprintf(fid,'CUBE run with only MC sampling (model evidences not computed).\n');
end

for i=1:length(models)     % Loop over models at top level
  fprintf(fid,'\n');
  if all(cellfun(@(f) isfield(f,'logZ'),results)) && all(cellfun(@(x) length(x.logZ)>0,results))
    fprintf(fid,'MODEL %i (share of summed evidences: %.2f%%):\n',i,100*evi(i));
  else
    fprintf(fid,'MODEL %i:\n',i);
  end
  if isfield(results{i},'logZ') && length(results{i}.logZ)>0
    fprintf(fid,'log10-evidence: %.3f',results{i}.logZ(1)/log(10));
    if isfield(results{i},'logZ_error')
      fprintf(fid,' +/- %.3f',results{i}.logZ_error/log(10));
    end
    fprintf(fid,'\n');
  end
  fprintf(fid,'log10-maximal likelihood: % .3f\n',results{i}.samples(end).logl/log(10));

  [~,ind]=sort(cell2mat(results{i}.an.log_sumps),'descend');
  for i2 = ind %1:length(results{i}.an.maxLpar)     % Loop over submodels
    if isfield(models{i},'names') && length(models{i}.names)>0
      fprintf(fid,['\n  ' models{i}.names(results{i}.an.discs{i2}) ' ']);
    elseif length(ind)>1
      fprintf(fid,['\n  ']);
    end
    if length(ind)>1
      fprintf(fid,'(probability %.3f):\n',exp(results{i}.an.log_sumps{i2}));
      fprintf(fid,'  log10-probability: %.3f\n',(results{i}.an.log_sumps{i2})/log(10));
      if isfield(models{i},'prior_disc') && isfield(results{i},'logZ') && length(results{i}.logZ)>0
        fprintf(fid,'  log10-evidence: %.3f\n',(results{i}.logZ+results{i}.an.log_sumps{i2}-log(models{i}.prior_disc(results{i}.an.discs{i2})))/log(10));
      end
      fprintf(fid,'  log10-maximal likelihood: %.3f',results{i}.an.maxlogls{i2}/log(10));
    end
    perc_text='Percentile:';
    labels=models{i}.labels(results{i}.an.discs{i2},obs);
    label_length=max([cellfun(@(s) length(s),labels) length(perc_text)]);
    fprintf(fid,['\n  ' perc_text]);
    for j=length(perc_text):(label_length-1)
      fprintf(fid,' ');
    end
    for j=1:length(misc.percentiles_at)
      fprintf(fid,ns_print_val(misc.percentiles_at(j),9));
    end
    fprintf(fid,' MaxL@    Mean    +/- dev.');
    if isfield(misc,'true') && ((isfield(misc.true,'model') && misc.true.model==i) || length(models)==1) && isequal(misc.true.disc,results{i}.an.discs{i2})
      fprintf(fid,'     True!');
    end
    fprintf(fid,'\n');
    for j=1:length(results{i}.an.param_mean{i2})
        fprintf(fid,['  ' labels{j}]);
        for j2=length(labels{j}):(label_length-1)
          fprintf(fid,' ');
        end
        for k=1:length(misc.percentiles_at)
          fprintf(fid,ns_print_val(results{i}.an.percentiles{i2}(j,k),9));
        end
        fprintf(fid,[ns_print_val(results{i}.an.maxLpar{i2}(j),9) ns_print_val(results{i}.an.param_mean{i2}(j),9) '+/-' ns_print_val(results{i}.an.param_stddev{i2}(j),9)]);
        if isfield(misc,'true') && ((isfield(misc.true,'model') && misc.true.model==i) || length(models)==1) && isequal(misc.true.disc,results{i}.an.discs{i2})
          fprintf(fid,ns_print_val(misc.true.cont(j),9));
        end
        fprintf(fid,'\n');
    end
  end

    if isfield(models{i},'replicate')
      fprintf(fid,'\n');       
% Print the results of any user defined model checks
      if isfield(models{i},'checks')
        for j=1:length(models{i}.checks)
          fprintf(fid,models{i}.checks(j).misc.labels{1});       
          if isfield(models{i}.checks(j).misc,'columns')
            fprintf(fid,'\n');
            if length(models{i}.checks(j).misc.labels)>1
              label2=models{i}.checks(j).misc.labels{2};
              len1stC=length(sprintf(label2));
              fprintf(fid,label2);
            else
              if isfield(models{i}.checks(j).misc,'rows')
                fprintf(fid,' R  \\  C');
                len1stC=8;
              else
                fprintf(fid,' Input:  ');
                len1stC=9;
              end
            end
            for l=1:length(results{i}.checks(j).pvals(1,:));
              fprintf(fid,ns_print_val(models{i}.checks(j).misc.columns(l),8));
            end
            fprintf(fid,'\n');
          end
          for k=1:length(results{i}.checks(j).pvals(:,1));
            if isfield(models{i}.checks(j).misc,'rows')
              fprintf(fid,ns_print_val(models{i}.checks(j).misc.rows(k),len1stC));
            elseif isfield(models{i}.checks(j).misc,'columns')
              fprintf(fid,' p-value:');
              for l=1:(len1stC-9);
                fprintf(fid,' ');
              end
            end
            for l=1:length(results{i}.checks(j).pvals(1,:));
              pval=results{i}.checks(j).pvals(k,l);
              fprintf(fid,ns_print_val(pval,8));
            end
            fprintf(fid,'\n');
          end
        end
      end
    end
  if isfield(results,'bgof') && isfield(results{i}.bgof,'logZmod')
    fprintf(fid,'\n');
    fprintf(fid,'Bayesian goodness-of-fit (spread is std(log10(beta))):\n');
    if isfield(models{best},'names') && length(models{i}.names)>0
      fprintf(fid,[models{best}.names(results{best}.an.discs{ind(1)}) ' (MODEL %i)\n'],best);
    elseif length(results{best}.an.maxLpar)>1
      fprintf(fid,'Best submodel of MODEL %i\n',best);
    else
      fprintf(fid,'MODEL %i\n',best);
    end
    [Bsorted,id]=sort(results{i}.bgof.logZmod,'descend');
    fprintf(fid,' ncomb log10(B) spread   <phi>   +/- std(phi)\n');
    for j=1:length(results{i}.bgof.logZmod)
      fprintf(fid,ns_print_val(id(j),6));
      fprintf(fid,ns_print_val(results{i}.bgof.logZmod(id(j))*log10(exp(1)),9));
      fprintf(fid,ns_print_val(results{i}.bgof.stddev_logbeta(id(j))*log10(exp(1)),9));
      fprintf(fid,ns_print_val(results{i}.bgof.phi_mean(id(j)),9));
      fprintf(fid,['+/-' ns_print_val(results{i}.bgof.phi_stddev(id(j)),9)]);
      fprintf(fid,'\n');
    end
  end
end
fprintf(fid,'\n');
fclose(fid);
end

%%% A function that prints a value with a format depending on its magnitude %%%
function txt = ns_print_val(val,len)
  if mod(val,1)==0
    txt=sprintf('% -i',val);
  elseif abs(val)>=0.01 & abs(val)<100
    if mod(val,0.01)==0
      txt=sprintf('% .2f ',val);
    else
      txt=sprintf('% .3f',val);
    end
  else
    txt=sprintf('% .1e',val);
  end
  for j=1:(len-length(txt))
    txt=[txt ' '];
  end
end
