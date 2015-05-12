from wmap3Wrapper import wmapWrapperManager

import numpy as np

def copyArray(src, trg, index):
    lenght= min(len(src),len(trg))
    for i in xrange(0,lenght):
        trg[i]=src[i,index]
    

data = np.loadtxt("lensedcls.dat")

size = 1199

cl_tt = np.zeros(size)
cl_te = np.zeros(size)
cl_ee = np.zeros(size)
cl_bb = np.zeros(size)
#
copyArray(data, cl_tt, 1)
copyArray(data, cl_te, 4)
copyArray(data, cl_ee, 2)
copyArray(data, cl_bb, 3)

wmapWrapperManager.setup()

likelihood = wmapWrapperManager.computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb)
print likelihood
