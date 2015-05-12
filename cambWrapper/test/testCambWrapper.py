#!/usr/bin/env python
from cambWrapper import cambWrapperManager
import pylab

cambWrapperManager.setup()

paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]
cl_tt,cl_te,cl_ee,cl_bb = cambWrapperManager.computecmbpowerspectrum(paramValues)
 
 
 
pylab.subplot(1,2,1) 
pylab.title("Power spectrum")
ell = pylab.arange(1,len(cl_tt)+1)
pylab.semilogx(ell,cl_tt)
pylab.xlabel("$\ell$", fontsize=20)
pylab.ylabel("$\ell (\ell+1) C_\ell / 2\pi \quad [\mu K^2]$", fontsize=20)
pylab.xlim(1,2000)

pylab.subplot(1,2,2) 
pylab.title("Matter power spectrum")
kh, power = cambWrapperManager.computeCambMatterPowerSpectrum(paramValues)
pylab.semilogx(kh, power)
pylab.xlabel("Wavenumber $ k [h Mpc^{-1}]$", fontsize=20)
pylab.ylabel("Powerspectrum $P(k) [h^{-3}Mpc^3$", fontsize=20)
pylab.xlim(10**-4,1)
pylab.show()

#non stopping version only
# try:
#     paramValues = [  9.68021910e+01,   1.52035392e-02,  6.44873802e-01  , 2.19184020e-09 ,  7.54612255e-01 ,  2.79024850e-01]
#     cl_tt,cl_te,cl_ee,cl_bb = cambWrapperManager.computecmbpowerspectrum(paramValues)
# except RuntimeError:
#     print "Got infeasible params"