This file describes how to run Bayesian inference on simulated FBM or SBM trajectories.

1. Go to the folder "examples_of_use" and open the file "sbm_fbm_skel.m".
2. It is a function that takes 4 arguments:
  modelindex: it can take values 1 (SBM) or 2 (FBM). This then sets the stochastic process
              used to generate the simulated trajectory.
  al: it is the anomalous diffusion exponent $\alpha$ that is used to generate the simulated 
      trajectory.
  noise: this value sets the noise-strength $\sigma_{mn}$ for the simulated trajectory.
  L: it sets the number of points in the trajectory.
3. Upon running "sbm_fbm_skel.m", a text file (named "resultfile.txt") with results of the inference
  gets saved  in the   folder "Resultfiles".
  
