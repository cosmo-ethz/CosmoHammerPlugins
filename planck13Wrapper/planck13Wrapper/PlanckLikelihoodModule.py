#! /usr/bin/env python

# Copyright (C) 2015 ETH Zurich, Institute for Astronomy

# System imports
from __future__ import print_function, division, absolute_import, unicode_literals


# External modules
from cosmoHammer.Constants import *
from numpy import array, append, arange, pi
from copy import deepcopy
import clik

# planck13Wrapper imports
from planck13Wrapper import CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY 


class PlanckLikelihoodModule(object):
    
    def __init__(self, clik_files, nuisance_indices = None):
        """
        Module for the Planck likelihood computation

        :param clik_files: List of clik files used in the likelihood
        :param nuisance_indices (optional): List of index lists in the
        parameter vector containing the nuisance parameters for each file in
        clik_files; if None it is assumed that none of the likelihoods needs
        nuisance parameters; default: None 
        """
        if type(clik_files) is str:
            self.clik_files = [clik_files]
            self.n = 1
        else:
            self.clik_files = clik_files
            self.n = len(clik_files)
        
        if nuisance_indices is None:
            self.nu_inds = self.n * [[]]
        else:
            try:
                nn = len(nuisance_indices)
            except TypeError:
                nn = 1
                nuisance_indices = [nuisance_indices]
            if nn == self.n:
                self.nu_inds = nuisance_indices
            else:
                raise Warning('Need a list of %i nuisance index arrays'%self.n)

    def computeLikelihood(self, ctx):
        """
        call the native code to compute log likelihood
        
        :param ctx: an instance of a ChainContext
        
        :returns: the sum of the log likelihoods defined in the
        clik_files list. 
        """

        cl_tt = ctx.get(CL_TT_KEY)
        cl_ee = ctx.get(CL_EE_KEY)
        cl_te = ctx.get(CL_TE_KEY)
        cl_bb = ctx.get(CL_BB_KEY)
        l = arange(len(cl_tt)) + 2
        cls = array([2.*pi*cl_tt/(l*(l+1.)), 2.*pi*cl_ee/(l*(l+1.)),
                     2.*pi*cl_bb/(l*(l+1.)), 2.*pi*cl_te/(l*(l+1.)),
                     None, None])
        p = deepcopy(ctx.getParams())
        cl01 = array([0.0, 0.0])
        loglike = 0.

        for i, l in enumerate(self.likes):
            inds = array([bool(int(f)) for f in l.has_cl])
            lmax = array(l.lmax)
            input = array([])
            for j, flag in enumerate(inds):
                if flag:
                    tcl = append(cl01, cls[j][:lmax[j]-1])
                    input = append(input, tcl)
            input = append(input, p[self.nu_inds[i]])
            loglike += l(input)[0]

        return loglike
            
    def setup(self):
        """
        Sets up the Planck likelihood
        """

        self.likes = []
        for i, f in enumerate(self.clik_files):
            l = clik.clik(f)
            self.likes.append(l)
            nn = len(l.extra_parameter_names)
            if nn != len(self.nu_inds[i]):
                raise Warning('Index arrays %i does not have correct shape.'%i)
