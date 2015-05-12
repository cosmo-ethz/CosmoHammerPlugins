#! /usr/bin/env python

# Copyright (C) 2015 ETH Zurich, Institute for Astronomy

# System imports
from __future__ import print_function, division, absolute_import, unicode_literals

# External modules
from classy import Class

# classWrapper imports
from classWrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY
from numpy import pi

DEFAULT_PARAM_MAPPING = {"H0": 0,
                         "omega_b": 1,
                         "omega_cdm": 2,
                         "A_s": 3,
                         "n_s": 4,
                         "tau_reio": 5}

CLASS_DEFAULT_PARAMS = {'output': 'tCl,pCl,lCl',
                        'lensing': 'yes',
                        'l_max_scalars': 2500}


class ClassCoreModule(object):
    
    def __init__(self, mapping=DEFAULT_PARAM_MAPPING, constants=CLASS_DEFAULT_PARAMS):
        """
        Core Module for the delegation of the computation of the cmb power
        spectrum to the Class wrapper classy.
        The defaults are for the 6 LambdaCDM cosmological parameters.
        
        :param mapping: (optional) dict mapping name of the parameter to the index
        :param constants: (optional) dict with constants overwriting CLASS defaults
        """
        self.mapping = mapping
        if constants is None:
            constants = {}
        self.constants = constants
        
    def __call__(self, ctx):
        p1 = ctx.getParams()
        
        params = self.constants.copy()
        for k,v in self.mapping.items():
            params[k] = p1[v]
        self.cosmo.set(params)
        self.cosmo.compute()
        if self.constants['lensing'] == 'yes':
            cls = self.cosmo.lensed_cl()
        else:
            cls = self.cosmo.raw_cl()
        Tcmb = self.cosmo.T_cmb()*1e6
        frac = Tcmb**2 * cls['ell'][2:] * (cls['ell'][2:] + 1) / 2. / pi
        ctx.add(CL_TT_KEY, frac*cls['tt'][2:])
        ctx.add(CL_TE_KEY, frac*cls['te'][2:])
        ctx.add(CL_EE_KEY, frac*cls['ee'][2:])
        ctx.add(CL_BB_KEY, frac*cls['bb'][2:])
        self.cosmo.struct_cleanup()

    def setup(self):
        """
        Create an instance of Class and attach it to self.
        """
        self.cosmo = Class()
        self.cosmo.set(self.constants)
        self.cosmo.compute()
        self.cosmo.struct_cleanup()
        