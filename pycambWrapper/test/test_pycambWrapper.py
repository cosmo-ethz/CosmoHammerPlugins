#!/usr/bin/env python
import pylab

from cosmoHammer.ChainContext import ChainContext

import pycambWrapper

paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]

ctx = ChainContext(None, paramValues)
pyCambCore = pycambWrapper.PyCambCoreModule()
pyCambCore(ctx)

cl_tt =ctx.get(pycambWrapper.CL_TT_KEY)
cl_te =ctx.get(pycambWrapper.CL_TE_KEY)
cl_ee =ctx.get(pycambWrapper.CL_EE_KEY)
cl_bb =ctx.get(pycambWrapper.CL_BB_KEY)


pylab.subplot(1,1,1) 
pylab.title("Power spectrum")
ell = pylab.arange(1,len(cl_tt)+1)
pylab.semilogx(ell,cl_tt)
pylab.xlabel("$\ell$", fontsize=20)
pylab.ylabel("$\ell (\ell+1) C_\ell / 2\pi \quad [\mu K^2]$", fontsize=20)
pylab.xlim(1,2000)

pylab.show()