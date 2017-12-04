from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

def custom_model(params, ns, pts):
    nu1,nu2,T1,T2 = params

    xx = Numerics.default_grid(pts)
    phi = PhiManip.phi_1D(xx)

    phi = Integration.one_pop(phi, xx, T1, nu1)
    phi = Integration.one_pop(phi, xx, T2, nu2)

    fs = Spectrum.from_phi(phi, ns, (xx,))
    return fs
                            
