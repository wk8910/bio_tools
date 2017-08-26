#! /usr/bin/env python
import os,sys,re
# import matplotlib
# matplotlib.use('Agg')
import numpy
import sys
from numpy import array
# import pylab
import dadi

spectrum_file = sys.argv[1]
data = dadi.Spectrum.from_file(spectrum_file)

# data = data.fold()
# data = data.project([10,16])
ns = data.sample_sizes
pts_l = [40,50,60]

# params = (nuPre,TPre,s,nu1,nu2,T,m12,m21)
func = dadi.Demographics2D.IM_pre

upper_bound = [10,2,0.9999, 10, 10, 1, 10, 10]
lower_bound = [1e-2,0,0.0001, 1e-2, 1e-3, 0, 0, 0]
# p0 = [1, 0.2,  0.8,   0.491023   ,  0.269151   ,  0.156794   ,  3.15049   ,   3.15049 ]
# p0 = [ 2.95934    ,  0.266711   ,  0.987293   ,  0.650639   ,  0.310276   ,  0.254639   ,  0.358743   ,  6.6396     ]
p0 = [3.58393534462,   0.306618228096,  0.986773940004,  0.823557413109,  0.322669721201,  0.020555616477,  0.2648267148,    7.09644206947]
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
# params = (nuPre,TPre,s,nu1,nu2,T,m12,m21)
print('likelihood\ttheta\tN.nuPre\tT.Tpre\tO.s\tN.nu1\tN.nu2\tT.T\tM.m12\tM.m21')
print("\t".join(map(str,result)))
