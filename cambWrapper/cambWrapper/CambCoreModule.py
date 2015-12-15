
from cosmoHammer.exceptions import LikelihoodComputationException
from cosmoHammer import getLogger

import camb

from cambWrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY


DEFAULT_COSMO_MAPPING = {"H0": 0,
                         "ombh2": 1,
                         "omch2": 2,
                         "tau": 5
                         }

DEFAULT_INIT_MAPPING = {"As": 3,
                        "ns": 4}

class CambCoreModule(object):
    """
    Core Module for the delegation of the computation of the cmb power
    spectrum to CAMB.
    
    :param CAMBparams: (optional) instance of CAMBparams; default: create
    new CAMBparams instance
    :param cosmo_mapping: (optional) dict mapping index of parameter vector to
    name used in set_cosmology routine of CAMBparams instance
    :param cosmo_constants: (optional) dict of default values for parameters
    in set_cosmology that are fixed; default: default values from CAMB
    :param init_mapping: (optional) dict mapping index of parameter vector to
    name used in InitPower.set_params routine of CAMBparams instance
    :param init_constants: (optional) dict of default values for parameters in
    InitPower.set_params that are fixed; default: default values from CAMB
    """
    
    def __init__(self, CAMBparams = None, cosmo_mapping=DEFAULT_COSMO_MAPPING, 
                 cosmo_constants={}, init_mapping=DEFAULT_INIT_MAPPING,
                 init_constants={}, lmax = None):
        if CAMBparams is None:
            self.CAMBparams = camb.CAMBparams()
            self.CAMBparams.InitPower.set_params()
        else:
            self.CAMBparams = CAMBparams
        self.cosmo_mapping = cosmo_mapping
        self.cosmo_constants = cosmo_constants
        self.init_mapping = init_mapping
        self.init_constants = init_constants
        if lmax is None:
            self.lmax = self.CAMBparams.max_l
        else:
            self.lmax = lmax
        
    def __call__(self, ctx):
        p = ctx.getParams()
        try:
            cosmo_params = {}
            for k,v in self.cosmo_mapping.items():
                cosmo_params[k] = p[v]
            cosmo_params.update(self.cosmo_constants)
            self.CAMBparams.set_cosmology(**cosmo_params)
            
            init_params = {}
            for k,v in self.init_mapping.items():
                init_params[k] = p[v]
            init_params.update(self.init_constants)
            self.CAMBparams.InitPower.set_params(**init_params)

            results = camb.get_results(self.CAMBparams)
            Tcmb = self.CAMBparams.TCMB*1e6
            powers = results.get_cmb_power_spectra(lmax = self.lmax)['total']
            powers *= (Tcmb * Tcmb)
            # The convention in CosmoHammer is to have the spectra in units
            # microK^2 and starting from ell=2 
            ctx.add(CL_TT_KEY, powers[2:,0])
            ctx.add(CL_TE_KEY, powers[2:,3])
            ctx.add(CL_EE_KEY, powers[2:,1])
            ctx.add(CL_BB_KEY, powers[2:,2])
        except camb.baseconfig.CAMBError:
            getLogger().warn("CAMBError catched. Used params [%s]"%( ", ".join([str(i) for i in p]) ) )
            raise LikelihoodComputationException()

    def setup(self):
        """
        Make a CAMB test run to confirm that everything works for the default
        parametrization.
        """
        self.CAMBparams.set_cosmology(**self.cosmo_constants)
        self.CAMBparams.InitPower.set_params(**self.init_constants)
        camb.get_results(self.CAMBparams)
