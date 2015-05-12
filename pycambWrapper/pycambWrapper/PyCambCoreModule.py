import pycamb

from cosmoHammer.exceptions import LikelihoodComputationException
from cosmoHammer import getLogger

from pycambWrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY


def _use_physical_converter(args):
    use_physical = args.pop("use_physical")
    if use_physical:
        H0 = args["H0"]
        args["omegab"] = args.pop('ombh2')/(H0/100.)**2
        args["omegac"] = args.pop('omch2')/(H0/100.)**2
        args["omegan"] = args.pop('omnuh2')/(H0/100.)**2
        args["omegak"] = args.pop('omk')
        args["omegav"] = 1- args["omegak"] - args["omegab"] - args["omegac"] - args["omegan"]

    
DEFAULT_PARAM_MAPPING = {"H0": 0,
                          "ombh2": 1,
                          "omch2": 2,
                          "scalar_amp": 3,
                          "scalar_index": 4,
                          "reion__optical_depth": 5,
                         }

CAMB_DEFAULT_PARAMS = {"DoLensing": True,
                       "reion__use_optical_depth": True,
                       "use_physical": True,
                       "omnuh2": 0.0, 
                       "omk": 0.0
                       }

DEFAULT_CONVERTERS = {"use_physical": _use_physical_converter, 
                      }

class PyCambCoreModule(object):
    """
    Core Module for the delegation of the computation of the cmb power spectrum to the PyCamb module.
    The defaults allow for sampling the 6 lcdm cosmologcial parameters.
    
    :param lmax: (optional) Run camb up to the given lmax
    :param mapping: (optional) dict mapping name of the parameter to the index
    :param converters: (optional) dict with param_name: callable items converting parameters
    :param constants: (optional) dict with constants overwriting camb defaults
    """
    
    def __init__(self, lmax=2250, mapping=DEFAULT_PARAM_MAPPING, converters=DEFAULT_CONVERTERS, constants=CAMB_DEFAULT_PARAMS):
        self.lmax = lmax
        self.mapping = mapping
        self.converters = converters
        
        if constants is None:
            constants = {}
        
        self.constants = constants
        
        
        
    def __call__(self, ctx):
        p1 = ctx.getParams()[0:len(self.mapping)]
        
        try:
            params = self.constants.copy()
            for k,v in self.mapping.items():
                params[k] = p1[v]
            
            self._transform(params)

            cl_tt,cl_ee,cl_bb,cl_te = pycamb.camb(self.lmax, **params)
            ctx.add(CL_TT_KEY, cl_tt)
            ctx.add(CL_TE_KEY, cl_te)
            ctx.add(CL_EE_KEY, cl_ee)
            ctx.add(CL_BB_KEY, cl_bb)
        except RuntimeError:
            getLogger().warn("Runtime error catched from the camb so. Used params [%s]"%( ", ".join([str(i) for i in p1]) ) )
            raise LikelihoodComputationException()

    def _transform(self, params):
        if self.converters is None:
            return
        
        for paramName in params.keys():
            try:
                self.converters[paramName](params)
            except KeyError:
                pass

    def setup(self):
        """
        Nothing to be done
        """
        pass


