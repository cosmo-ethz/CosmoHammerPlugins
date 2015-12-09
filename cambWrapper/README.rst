CambWrapper - Wrapper for the Code for Anisotropies in the Microwave Background
===============================================================================
CambWrapper is a CosmoHammer wrapper for CAMB. It uses the official python bindings for CAMB by Anthony Lewis
(see http://camb.readthedocs.org/en/latest/).

At this point, CambWrapper simply computes the CMB power spectrum. It is however fairly straightforward to include
the other functionalities that are available in CAMB such as calculating derived parameters, the matter power spectrum,
or the comoving distance. 

How the parameter vector is mapped to CAMB parameters is defined in the parameters init_mapping (for the primordial parameters)
and cosmo_mapping (for all the other LCDM parameters) of the CambCoreModule. The default mapping is given by the following order:
H0, ombh2, omch2, As, ns, tau

The module calculates the CMB power spectra as l*(l+1)*Cl/2pi and in units of microK^2, starting with l = 2.

To run CambWrapper in order to compute the CMB power spectra from a given set of parameters, you would do something like:

::

	from cambWrapper import cambCoreModule, CL_TT_KEY
	from cosmoHammer import ChainContext
	
	# Default order of parameters is defined as:
	# H0, ombh2, omch2, As, ns, tau 
	paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]
	
	camb = cambCoreModule()
	ctx = ChainContext(None, paramValues)

	camb(ctx)
	
	cltt = ctx[CL_TT_KEY]
	