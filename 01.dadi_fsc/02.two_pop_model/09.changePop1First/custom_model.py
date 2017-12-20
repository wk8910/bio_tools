from dadi import Numerics, PhiManip, Integration
from dadi.Spectrum_mod import Spectrum

def custom_model(params, ns, pts):
    nuPre,TPre,nu1_0,nu2_0,nu1_1,nu2_1,T1,T2,T3,m12_1,m21_1,m12_2,m21_2,m12_3,m21_3 = params

    xx = Numerics.default_grid(pts)

    phi = PhiManip.phi_1D(xx)
    phi = Integration.one_pop(phi, xx, TPre, nu=nuPre)
    phi = PhiManip.phi_1D_to_2D(xx, phi)

    phi = Integration.two_pops(phi, xx, T1, nu1_0, nu2_0, m12=m12_1, m21=m21_1)
    phi = Integration.two_pops(phi, xx, T2, nu1_1, nu2_0, m12=m12_2, m21=m21_2)
    phi = Integration.two_pops(phi, xx, T3, nu1_1, nu2_1, m12=m12_3, m21=m21_3)

    fs = Spectrum.from_phi(phi, ns, (xx,xx))
    return fs
                                
