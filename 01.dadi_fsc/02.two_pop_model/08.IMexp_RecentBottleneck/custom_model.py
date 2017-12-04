from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

def custom_model(params, ns, pts):
    nuPre,TPre,s,nu1,nu2,T,m12,m21,Tb,nu1_b,nu2_b = params

    xx = Numerics.default_grid(pts)
    phi = PhiManip.phi_1D(xx)
    phi = Integration.one_pop(phi, xx, TPre, nu=nuPre)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    nu1_0 = nuPre*s
    nu2_0 = nuPre*(1-s)
    nu1_func = lambda t: nu1_0 * (nu1/nu1_0)**(t/T)
    nu2_func = lambda t: nu2_0 * (nu2/nu2_0)**(t/T)
    phi = Integration.two_pops(phi, xx, T, nu1_func, nu2_func,
                               m12=m12, m21=m21)
    phi = Integration.two_pops(phi, xx, Tb, nu1_b, nu2_b, m12=m12, m21=m21)
    
    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs
                                            
