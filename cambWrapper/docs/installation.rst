============
Installation
============

Compiling using python distutils
--------------------------------
1) Execute 'get_camb.sh' from your command shell to download and extract the CAMB code
2) Adapt the setup.py file according to your preferred compiler by uncommenting the compiler options. (Currently intel ifort and GNU gfortran is supported)

**Important** If you want to compile with ifort, make sure you correctly sourced the compilervars and mklvars 
	(e.g. "source /opt/intel/composer_xe_2011_sp1.8.273/bin/compilervars.sh intel64" and "source /opt/intel/mkl/bin/mklvars.sh intel64")
	and that the MKLROOT environment var is correctly set (e.g. export MKLROOT=/opt/intel/composer_xe_2011_sp1.8.273/mkl)


3) Run the following commands from the command line in the root folder of cambWrapper

 ``>$ python setup.py build``
 
 ``>$ sudo python setup.py install``
 
 or
 
 ``>$ python setup.py install --user``
 
 If you don't want to use the default compiler add to the first command "``--fcompiler=<compiler>``".  
 Where <compiler> is your desired compiler i.e. intel, intelem or gnu95. (See ``f2py -c --help-fcompiler`` for available compilers)
 
 **Mac OS X users**: If you installed your python and dependencies with mac ports make sure that after the wrapper has been compiled and built 
 that the appropriate libraries have been linked be executing the following command in the build directory:
 
  ``>$ otool -L build/lib.macosx-10.9-x86_64-2.7/cambWrapper/_cambWrapper.so``
 
 In case your python is not correctly configured and the system python in linked instead of your port version you need the adapt the library by executing:
  
  ``>$ install_name_tool -change /System/Library/Frameworks/Python.framework/Versions/2.7/Python /opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python build/lib.macosx-10.9-x86_64-2.7/cambWrapper/_cambWrapper.so``
 

Non stopping version of the wrapper:
------------------------------------
CAMB performs various sanity checks on the input parameters. If any of the values violate some boundary or physical condition the computation is stopped by using Fortran's stop function.
Unfortunately this also kills the calling python interpreter. As long you use the wrapper in a save environment i.e. you will manually call the wrapper function this will likely not bother you.
But if you intent to use the wrapper for some sampling i.e. you will perform some random walks in the parameter space where it's likely that the wrapper is called with 
infeasible parameter combinations you may want to compile the wrapper as non stopping version. Then instead of killing the interpreter the wrapper will raise a RuntimeError.
(Thanks to Yu Feng <yfeng1@cmu.edu> @ McWilliam Center, Carnegie Mellon 2012)
You can do this by using the following command:

``>$ python setup.py build --nonstop``
