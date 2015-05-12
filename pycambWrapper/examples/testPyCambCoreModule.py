import numpy as np
import pylab

from cosmoHammer import ChainContext

from pycambWrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY
from pycambWrapper.PyCambCoreModule import PyCambCoreModule

params = np.array([70, 0.0226, 0.122, 2.1e-9, 0.96, 0.09])

pyCambCore = PyCambCoreModule(lmax=2250)

ctx = ChainContext(None, params)
pyCambCore(ctx)


pylab.subplot(2,2,1)
pylab.plot(ctx.get(CL_TT_KEY), label="PyCamb")
pylab.legend()
pylab.subplot(2,2,2)
pylab.plot(ctx.get(CL_TE_KEY), label="PyCamb")
pylab.subplot(2,2,3)
pylab.plot(ctx.get(CL_EE_KEY), label="PyCamb")
pylab.subplot(2,2,4)
pylab.plot(ctx.get(CL_BB_KEY), label="PyCamb")
pylab.show()