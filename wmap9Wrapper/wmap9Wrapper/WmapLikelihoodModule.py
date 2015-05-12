
from cosmoHammer.exceptions import InvalidLikelihoodException

from wmap9Wrapper import wmapWrapperManager
from wmap9Wrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY

class WmapLikelihoodModule(object):
    
    """
    Module for the wmap likelihood computation
    
    :param path: (optional) the path to the WMAP data
    :param kwargs: (optional) kw arguments passed to the wrapper
    
    """
    def __init__(self, path=None, **kwargs):
        self.path = path
        self.kwargs = kwargs
    
    def computeLikelihood(self, ctx):
        """
        call the native code to compute log likelihood
        
        :param ctx: an instance of a ChainContext
        
        :returns: the log likelihood 
        
        :raises InvalidLikelihoodException: in case the log likelihood from the 
                wmapWrapper is smaller than 0.0001
        """
        cl_tt =ctx.get(CL_TT_KEY)
        cl_te =ctx.get(CL_TE_KEY)
        cl_ee =ctx.get(CL_EE_KEY)
        cl_bb =ctx.get(CL_BB_KEY)
        
        loglike = -wmapWrapperManager.computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb)
        
        if(abs(loglike)<0.0001):
            raise InvalidLikelihoodException()

        return loglike

    def setup(self):
        """
        Sets up the cmb likelihood wrapper
        """

        wmapWrapperManager.setup(self.path, **self.kwargs)
