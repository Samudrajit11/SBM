function out = pbm_main(obs,mu,sigma,out_wish)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
% Contributors to the programming: Michael Lomholt
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~isequal(mu,[]) && ~(out_wish=='x')
  obs=obs-mu(1,:);
end

if out_wish=='l'
  var=sigma^2;
  out=-log(2*pi*var)*numel(obs)/2-sum(sum(obs.^2))/(2*var);
elseif out_wish=='u'
  out=1-erfc(obs/(sqrt(2)*sigma))/2;
elseif out_wish=='x'
  out = sqrt(2)*sigma*erfcinv(2-2*obs);
  if ~isequal(mu,[])
    out = out+mu(1,:);
  end
elseif out_wish=='g'
  out = [-numel(obs)/sigma+sum(sum(obs.^2))/sigma^3, sum(obs,1)/sigma^2];
end
end

