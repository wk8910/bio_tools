#! /usr/bin/env python
import os,sys,re
# import matplotlib
# matplotlib.use('Agg')
import numpy
import sys
from numpy import array
# import pylab
import dadi
import custom_model

spectrum_file = sys.argv[1]
data = dadi.Spectrum.from_file(spectrum_file)

# data = data.fold()
ns = data.sample_sizes
pts_l = [40,50,60]


from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

func = custom_model.custom_model

# nu1,nu2,nu3,nu4,T1,T2,T3,T4
upper_bound = [ 10, 10, 10, 10, 10, 10, 10, 10]
lower_bound = [1e-5, 1e-5, 1e-5, 1e-5, 1e-5, 1e-5, 1e-5, 1e-5]
p0 = [1, 1, 1,  1,  1, 1, 1, 1]
func_ex = dadi.Numerics.make_extrap_log_func(func)
p0 = dadi.Misc.perturb_params(p0, fold=1, upper_bound=upper_bound, lower_bound=lower_bound)

print('Beginning optimization ************************************************')
popt = dadi.Inference.optimize_log(p0, data, func_ex, pts_l,
                                   lower_bound=lower_bound,
                                   upper_bound=upper_bound,
                                   verbose=len(p0), maxiter=30)

print('Finshed optimization **************************************************')
print('Best-fit parameters: {0}'.format(popt))
model = func_ex(popt, ns, pts_l)
ll_model = dadi.Inference.ll_multinom(model, data)
print('Maximum log composite likelihood: {0}\n'.format(ll_model))
theta = dadi.Inference.optimal_sfs_scaling(model, data)
print('Optimal value of theta: {0}\n'.format(theta))

result=[ll_model,theta]+popt.tolist()
print('###DADIOUTPUT###')
# nu1,nu2,nu3,nu4,T1,T2,T3,T4
print('likelihood\ttheta\tN.nu1\tN.nu2\tN.nu3\tN.nu4\tT.T1\tT.T2\tT.T3\tT.T4')
print("\t".join(map(str,result)))
