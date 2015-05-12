# Copyright (C) 2015 ETH Zurich, Institute for Astronomy

'''
Created on Apr 8, 2015

author: jakeret
'''
from __future__ import print_function, division, absolute_import, unicode_literals


import numpy as np
from wmap5Wrapper import wmapWrapperManager

data = np.loadtxt("lensedcls.dat")

lenght= min(data.shape[0], 1199)

cl_tt = data[:lenght, 1]
cl_te = data[:lenght, 4]
cl_ee = data[:lenght, 2]
cl_bb = data[:lenght, 3]

wmapWrapperManager.setup()

likelihood = wmapWrapperManager.computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb)
print(likelihood)
