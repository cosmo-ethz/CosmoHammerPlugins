CambWrapper - Wrapper for the Code for Anisotropies in the Microwave Background
===============================================================================
CambWrapper is a python wrapper for the Fortan90 code of CAMB.

.. note:: This wrapper is no longer compatible with the current version of CAMB. 


.. image:: https://raw.githubusercontent.com/cosmo-ethz/CosmoHammerPlugins/master/cambWrapper/docs/spectrum.png
   :alt: Possible outputs of cambWrapper.
   :align: left


To run CambWrapper in order to compute the power spectrum from a given set of parameters, you would do something like:

::

	from cambWrapper import cambWrapperManager
	
	paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]

	cambWrapperManager.setup()
	cl_tt,cl_te,cl_ee,cl_bb = cambWrapperManager.computecmbpowerspectrum(paramValues)
