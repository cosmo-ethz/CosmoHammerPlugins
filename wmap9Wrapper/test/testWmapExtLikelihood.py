# Copyright (C) 2015 ETH Zurich, Institute for Astronomy

'''
Created on Apr 7, 2015

author: jakeret
'''
from __future__ import print_function, division, absolute_import, unicode_literals
from wmap9Wrapper.WmapExtLikelihoodModule import WmapExtLikelihoodModule

wmapLikelihood = WmapExtLikelihoodModule(use_lowl_pol=False)
wmapLikelihood.setup()

print(wmapLikelihood.sz)