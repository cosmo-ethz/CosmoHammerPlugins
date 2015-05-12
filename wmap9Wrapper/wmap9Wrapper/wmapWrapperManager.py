
import _wmapWrapper

summed=True

def setup(wmapDataPath=None,
          use_TT=True,
          use_TE=True,
          use_lowl_TT=True,
          use_lowl_pol=True,
          ttmin=2,
          ttmax=1200,
          sum_up=True):
    """
    Sets up the wmap module
        
    :param wmapDataPath:
    :param use_TT:
    :param use_TE:
    :param use_lowl_TT:
    :param use_lowl_pol:
    :param ttmin:
    :param ttmax:
    :param sum_up:
    """
    if(wmapDataPath is None):
        from pkg_resources import resource_filename
        wmapDataPath = resource_filename(_wmapWrapper.__name__, "data/")
    global summed
    summed = sum_up
    _wmapWrapper.wmapwrapper.setupparams(wmapDataPath,use_TT,use_TE,use_lowl_TT,use_lowl_pol,ttmin,ttmax)



def computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb):
    """
    computes the wmap likelihood for the given cls
    
    :param cl_tt:
    :param cl_te:
    :param cl_ee:
    :param cl_bb:
    """
    like = _wmapWrapper.wmapwrapper.computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb)
    if summed:
        like = sum(like)
    return like
