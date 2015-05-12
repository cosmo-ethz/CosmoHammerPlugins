========
Usage
========

Using CambWrapper
-----------------

See the 'test/testCambWrapper.py' script for illustration. It sets up the subroutines of the wrapper and calculates the power spectrum.
	

To use Wrapper for the Code for Anisotropies in the Microwave Background in a project::

	from cambWrapper import cambWrapperManager
	import pylab
	
	cambWrapperManager.setup()
	
	paramValues = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]
	cl_tt,cl_te,cl_ee,cl_bb = cambWrapperManager.computecmbpowerspectrum(paramValues)
	 
	ell = pylab.arange(1,len(cl_tt)+1)
	pylab.semilogx(ell,cl_tt)
	pylab.xlabel("$\ell$", fontsize=20)
	pylab.ylabel("$\ell (\ell+1) C_\ell / 2\pi \quad [\mu K^2]$", fontsize=20)
	pylab.xlim(1,2000)
	pylab.show()
	
	kh, power = cambWrapperManager.computeCambMatterPowerSpectrum(paramValues)
	pylab.semilogx(kh, power)
	pylab.xlabel("Wavenumber $ k [h Mpc^{-1}]$", fontsize=20)
	pylab.ylabel("Powerspectrum $P(k) [h^{-3}Mpc^3$", fontsize=20)
	pylab.xlim(10**-4,1)
	pylab.show()
	


Changing exposed wrapper subroutines
------------------------------------

When changing routines of the wrapper, a new header file for f2py has to be generated using the *createHeader.sh* script. 

The script creates a file with the name *_cambWrapper.pyf*. **Note:** Make sure that you manually remove the globally defined variables (*Type(CAMBparams) params* and *logical :: initialized*) 
	