function[]=sbm_fbm_skel(modelindex,al,noise,L)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%modelindex=1 =>SBM trajectory, 2=>FBM trajectory
%al : anomalous diffusion exponent
%noise : noise-strength, \sigma_mn
%L : number of points in the trajectory
%%%%%%%%%%%%%%%%

    clear misc options model obs
    addpath('..');
    rng('shuffle');  %Use random seed for the inference
    dim=2;    %dimension of the trajectory
    inv_normal=@(u) sqrt(2)*erfinv(2*u-1);
    width_sigma=1;
    typical_sigma=1;
    inv_sigma=@(u) typical_sigma*10^(width_sigma*inv_normal(u));

    model{1}=sbm_mn_model(inv_sigma,@(u) 2*u,0,@(u) u);
    model{2}=fbm_model(inv_sigma,@(u) u,@(u) u);
    
    u=model{modelindex}.genu(1:dim);
    theta=model{modelindex}.invprior(u,1:dim);
    if (modelindex==1)
        theta(2)=al;    
    else
        theta(2)=al/2;
    end  
    theta(3)=noise;
    obs=model{modelindex}.u2x(rand(L,dim),theta);
    %rng('shuffle');  %Use random seed for the inference
    misc.true.model=modelindex;
    misc.true.cont=model{modelindex}.cont(theta);
    misc.true.disc=model{modelindex}.disc(theta);
    misc.true

    options{1}=struct;
    options{1}.algorithm=@ns_algorithm;
    options{2}=options{1};
    filename2 = 'resultfile.txt';
    misc.summary= strcat(pwd,'/Resultfiles/',filename2);
    results=cube_main(obs,model,misc,options);
    
end




