=============================
Planck Likelihood Module
=============================

CosmoHammer adapter for Planck Likelihood code

You need to install the Planck likelihood from the Planck Legacy archive first:
http://pla.esac.esa.int/pla/#home

Note that to complete the installation, you might need to source the script in: 
plc-1.0/bin/clik_profile.sh

To install the adapter, run the following commands from the command line in
the root folder of the planck13Wrapper:
python setup.py install --user

Using the planck13Wrapper:
---------------------------------
See the 'examples/planck_example.py' script for illustration. It sets up the
subroutines of the wrapper and calculates the likelihood using the pycamb
module.


License
-------
Planck Likelihood Module is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Planck Likelihood Module is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Planck Likelihood Module.  If not, see <http://www.gnu.org/licenses/>.
