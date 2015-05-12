
import _wmapWrapper


def setup(wmapDataPath=None):
	"""
	Sets up the wmap module
	"""
	if(wmapDataPath is None):
		from pkg_resources import resource_filename
		wmapDataPath = resource_filename(_wmapWrapper.__name__, "data/")
		
	_wmapWrapper.wmapwrapper.setupparams(wmapDataPath)



def computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb):
	"""
	computes the wmap likelihood for the given cls
		cl_tt
		cl_te
		cl_ee
		cl_bb

	"""
	return _wmapWrapper.wmapwrapper.computewmaplikelihood(cl_tt,cl_te,cl_ee,cl_bb)
