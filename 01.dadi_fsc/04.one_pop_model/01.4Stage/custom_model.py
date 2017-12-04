from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

def custom_model(params, ns, pts):
    nu1,nu2,nu3,nu4,T1,T2,T3,T4 = params

    xx = Numerics.default_grid(pts)
    phi = PhiManip.phi_1D(xx)

    phi = Integration.one_pop(phi, xx, T1, nu1)
    phi = Integration.one_pop(phi, xx, T2, nu2)
    phi = Integration.one_pop(phi, xx, T3, nu3)
    phi = Integration.one_pop(phi, xx, T4, nu4)

    fs = Spectrum.from_phi(phi, ns, (xx,))
    return fs
                            
