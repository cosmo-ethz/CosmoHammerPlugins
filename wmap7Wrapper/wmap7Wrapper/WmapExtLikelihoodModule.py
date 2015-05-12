"""

"""
from __future__ import print_function, division, absolute_import, unicode_literals

import numpy as np
from pkg_resources import resource_filename

from cosmoHammer import getLogger

import wmap7Wrapper
from wmap7Wrapper.WmapLikelihoodModule import WmapLikelihoodModule

FILE_PATH  = "data/WMAP_SZ_VBand.dat"

class WmapExtLikelihoodModule(WmapLikelihoodModule):
    """
    Extension for the WMAP likelihood computation using the sz template to post process the power spectrum
    
    :param path: the path to the WMAP data
    :param aszIndex: Index of the asz parameter in the walker position sequence
    """
    def __init__(self, aszIndex=6, path=None):
        """
        Constructor
        """
        super(WmapExtLikelihoodModule, self).__init__(path)
        self.aszIndex = aszIndex

    def setup(self):
        super(WmapExtLikelihoodModule, self).setup()
        
        path = resource_filename(wmap7Wrapper.__name__, FILE_PATH)
        
        getLogger().info("Loading sz template from: %s"%(path))
        
        self.sz = np.loadtxt(path)[:,1]
        
        
    def computeLikelihood(self, ctx):
        self.postProcessPowerSpectrum(ctx)
        
        return super(WmapExtLikelihoodModule, self).computeLikelihood(ctx)
        
    def postProcessPowerSpectrum(self, ctx):
        """Add data from sz template times Asz"""
        cl_tt = ctx.get(wmap7Wrapper.CL_TT_KEY)
        p = ctx.getParams()
        
        l = len(cl_tt)
        cl_tt[0:l] = cl_tt[0:l] + p[self.aszIndex]*self.sz[0:l]
        