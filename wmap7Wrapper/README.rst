Wmap7Wrapper - Wrapper for the 7yr Wilkinson Mircowave Anisotropy Probe likelihood code 
======================================================================================

Wmap7Wrapper is a python wrapper for the Fortan90 code of the WMAP7 likelihood 

Compiling using python distutils
--------------------------------
1) Execute 'get_wmap.sh' from your command shell to download and extract the WMAP7 code AND data.
2) Adapt the setup.py file according to your preferred compiler by uncommenting the compiler options. (Currently intel ifort and GNU gfortran is supported)
 
3) Run the following commands from the command line in the root folder of Wmap7Wrapper:
 - python setup.py build
 - sudo python setup.py install or python setup.py install --user
 
If you don't want to use the default compiler add to the first command "--fcompiler=<compiler>". Where <compiler> is your desired compiler i.e. intel or gnu95. (See f2py -c --help-fcompiler for available compilers)

If you don't want to download and install the WMAP7 data because you already have it somewhere on your disk, 
use 'get_wmap_sw.sh' instead of 'get_wmap.sh'. Then you have to adapt the 'setup.py' file by chaging 'include_data_files' to False. Make sure, you pass the path to the WMAP7 data when using the WmapWrapperManager.

Using Wmap7Wrapper
------------------

See the 'test/testWmapWrapper.py' script for illustration. It sets up the subroutines of the wrapper and calculates the likelihood.

Changing exposed wrapper subroutines
------------------------------------
When changing routines of the wrapper, a new header file for f2py has to be generated using the 'createHeader' script. The script creates a file with the name wmapwrapper.pyf. Make sure that you manually remove the globally defined variables if any.

License
-------
Wmap7Wrapper is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Wmap7Wrapper is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Wmap7Wrapper.  If not, see <http://www.gnu.org/licenses/>.
