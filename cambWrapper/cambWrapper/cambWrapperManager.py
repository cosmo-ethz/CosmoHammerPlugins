
import _cambWrapper
import os
import sys
import numpy as np

DEFAULT_PARAM_INI = "camb/params.ini"

lmax = 1200

def _file_path():
    return os.path.dirname(__file__)

def setup(cambParamFile=None):
    """
    Sets up the camb module
    
    :param cambParamFile: (optional) file path to the params.ini to use. If none is given the wrapper falls back to the default file 
    """
    if(cambParamFile is None):
        from pkg_resources import resource_filename
        cambParamFile  = resource_filename(_cambWrapper.__name__, DEFAULT_PARAM_INI)

    global lmax
    lmax = _cambWrapper.cambwrapper.setupparams(cambParamFile, _file_path()+"/")


def computecmbpowerspectrum(paramValues):
    """
    computes the power spectrum (cls) for the given values
    
    :param paramValues: an array containing the following values:
        hubble
        ombh2
        omch2
        scalar_amp
        scalar_spectral_index
        re_optical_depth

    :return: four arrays containing cl_tt, cl_te, cl_ee, cl_bb

    """
    cl_tt, cl_te, cl_ee, cl_bb = _cambWrapper.cambwrapper.computecmbpowerspectrum(paramValues, lmax)
    return cl_tt, cl_te, cl_ee, cl_bb


def computeCambMatterPowerSpectrum(paramValues, redshifts=[0], maxk=1., logk_spacing=0.02):
    """
    computes the matter power spectrum for the given values
    
    :param paramValues: an array containing the following values:
        hubble
        ombh2
        omch2
        scalar_amp
        scalar_spectral_index
        re_optical_depth
    :param redshifts: (optional)
    :param maxk: (optional)
    :param logk_spacing: (optional)

    :return: two arrays containing matter_power_kh, matter_power

    """    
    redshifts = np.array(redshifts,dtype=np.float64)
    ordered_redshifts = redshifts.copy()
    ordered_redshifts.sort()
    ordered_redshifts=ordered_redshifts[::-1]
    if not (redshifts == ordered_redshifts).all(): sys.stderr.write("WARNING:  Re-ordered redshift vector to be in temporal order.  Ouput will be similarly re-ordered.\n")
    if len(redshifts)>500: raise ValueError("At most 500 redshifts can be computed without changing the hardcoded camb value")

    
    _cambWrapper.cambwrapper.computeCambMatterPowerSpectrum(paramValues, maxk,logk_spacing,ordered_redshifts)
    
    power=_cambWrapper.cambwrapper.matter_power.copy()
    kh=_cambWrapper.cambwrapper.matter_power_kh.copy()
    
    _cambWrapper.cambwrapper.freematterpower
    
    return kh.squeeze(),power.squeeze()


