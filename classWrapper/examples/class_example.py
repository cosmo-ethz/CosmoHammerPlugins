from classWrapper.ClassCoreModule import ClassCoreModule
from classWrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY
from cosmoHammer import ChainContext
import pylab
import numpy as np

Class = ClassCoreModule()
Class.setup()

params = np.array([[70, 65, 80, 3],
                   [0.0226, 0.01, 0.03, 0.001],
                   [0.122, 0.09, 0.2, 0.01],
                   [2.1e-9, 1.8e-9, 2.35e-9, 1e-10],
                   [0.96, 0.8, 1.2, 0.02],
                   [0.09, 0.01, 0.1, 0.03]])

p = params[:,0]
ctx = ChainContext(None, p)
Class(ctx)

pylab.plot(ctx.get(CL_TT_KEY))
pylab.plot(ctx.get(CL_TE_KEY))
pylab.plot(ctx.get(CL_EE_KEY))
pylab.plot(ctx.get(CL_BB_KEY))
pylab.show()

