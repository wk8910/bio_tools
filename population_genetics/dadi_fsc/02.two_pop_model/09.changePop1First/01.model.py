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

upper_bound = [10,0.1,10,10,10,10,0.1,0.1,0.1,50,50,50,50,10,10]
lower_bound = [1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3,1e-3]
# p0 = [3.58393534462, 0.0486773940004, 0.823557413109,  0.322669721201,  0.823557413109,  0.322669721201, 0.02, 0.02, 0.02, 1, 1, 1, 1, 1, 1]
# p0 = [ 0.244652   ,  0.0119095  ,  0.0145135  ,  0.665885   ,  0.360031   ,  0.0304366  ,  0.0048145  ,  0.049628   ,  0.00184596 ,  9.99869    ,  5.73582    ,  6.86905    ,  8.33338    ,  7.58589    ,  0.296722   ]
p0 = [ 0.248036   ,  0.00407439 ,  0.0223131  ,  0.461456   ,  0.347989   ,  0.129358   ,  0.0044879  ,  0.0105292  ,  0.00887286 ,  19.9997    ,  0.941138   ,  13.3628    ,  15.8669    ,  1.21878    ,  0.0732607  ]
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
