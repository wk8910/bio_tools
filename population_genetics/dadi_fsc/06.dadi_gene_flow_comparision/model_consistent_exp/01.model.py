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

data = data.fold()
ns = data.sample_sizes
pts_l = [40,50,60]

# nuPre,TPre,nu1_0,nu2_0,nu1,nu2,T,m12,m21

func = custom_model.custom_model

upper_bound = [10,1,10,10,10,10,1,10,10]
lower_bound = [1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3]
# p0 = [5.11984,0.558449,0.403511,0.317042,0.403511,0.317042,0.0432683,0.0432683,0.0432683,1.44061,1.7391,1.44061,1.7391,1.44061,1.7391]
p0 = [1,0.1,1,1,1,1,0.1,1,1]
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

# nuPre,TPre,nu1_0,nu2_0,nu1,nu2,T,m12,m21
print('likelihood\ttheta\tN.nuPre\tT.Tpre\tN.nu1_0\tN.nu2_0\tN.nu1\tN.nu2\tT.T\tM.m12\tM.m21')
print("\t".join(map(str,result)))
