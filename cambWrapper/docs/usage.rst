========
Usage
========

Using CambWrapper
-----------------

See the 'test/testCambWrapper.py' script for illustration. It sets up the subroutines of the wrapper and calculates the power spectrum.
	

To use Wrapper for the Code for Anisotropies in the Microwave Background in a project::

	from cambWrapper import cambCoreModule, CL_TT_KEY
	from cosmoHammer import ChainContext
	
	# Default order of parameters is defined as:
	# H0, ombh2, omch2, As, ns, tau 
	paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]
	
	camb = cambCoreModule()
	ctx = ChainContext(None, paramValues)

	camb(ctx)
	
	cltt = ctx[CL_TT_KEY]
	