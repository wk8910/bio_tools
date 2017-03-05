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

data = data.fold()
ns = data.sample_sizes
pts_l = [40,50,60]

from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

def simple_iso(params, ns, pts):
    """
    params = (nuPre,TPre,nu1,nu2,T)
    ns = (n1,n2)

    Simple migration model, the population size is constant

    nuPre: Size after first size change
    TPre: Time before split of first size change.
    nu1: size of pop 1.
    nu2: size of pop 2.
    T1: Time from divergence to migration end (in units of 2*Na generations)
    T2: Time from migration end to present
    n1,n2: Sample sizes of resulting Spectrum
    pts: Number of grid points to use in integration.
    """
    nuPre,TPre,nu1,nu2,T = params

    xx = Numerics.default_grid(pts)

    phi = PhiManip.phi_1D(xx)
    phi = Integration.one_pop(phi, xx, TPre, nu=nuPre)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    phi = Integration.two_pops(phi, xx, T, nu1, nu2, m12=0, m21=0)

    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs

func = simple_iso
# nuPre,TPre,nu1,nu2,T
upper_bound = [10, 1, 10, 10, 1]
lower_bound = [1e-2, 1e-2, 1e-2, 0, 0]
p0 = [3.58393534462, 0.486773940004, 0.823557413109,  0.322669721201,  0.20555616477]
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
# nuPre,TPre,nu1,nu2,T
print('likelihood\ttheta\tN.nuPre\tT.Tpre\tN.nu1\tN.nu2\tT.T')
print("\t".join(map(str,result)))

