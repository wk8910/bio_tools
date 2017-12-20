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

# nuPre,TPre,nu1_0,nu2_0,nu1_1,nu2_1,T1,T2,T3,m12_1,m21_1,m12_2,m21_2,m12_3,m21_3

func = custom_model.custom_model

upper_bound = [10,0.1,10,10,10,10,0.1,0.1,0.1,50,50,50,50,20,20]
lower_bound = [1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3]
# p0 = [3.58393534462, 0.0486773940004, 0.823557413109,  0.322669721201,  0.823557413109,  0.322669721201, 0.02, 0.02, 0.02, 1, 1, 1, 1, 1, 1]
# p0 = [ 0.0931267  ,  0.0132581  ,  0.289233   ,  4.01457    ,  0.328125   ,  0.117906   ,  0.0776964  ,  0.0032607  ,  0.0115559  ,  0.6668     ,  5.76796    ,  9.99726    ,  9.89201    ,  9.91517    ,  9.00742    ]
p0 = [ 0.0153023  ,  0.00117927 ,  0.225511   ,  0.957868   ,  0.414266   ,  0.170334   ,  0.0197057  ,  0.00914041 ,  0.0116247  ,  1.29439    ,  9.1889     ,  19.9971    ,  13.3251    ,  5.06736    ,  6.50228    ]
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
# nuPre,TPre,nu1_0,nu2_0,nu1_1,nu2_1,T1,T2,T3,m12_1,m21_1,m12_2,m21_2,m12_3,m21_3
print('likelihood\ttheta\tN.nuPre\tT.Tpre\tN.nu1_0\tN.nu2_0\tN.nu1_1\tN.nu2_1\tT.T1\tT.T2\tT.T3\tM.m12_1\tM.m21_1\tM.m12_2\tM.m21_2\tM.m12_3\tM.m21_3')
print("\t".join(map(str,result)))
