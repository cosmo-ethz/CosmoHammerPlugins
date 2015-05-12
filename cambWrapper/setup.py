#!/usr/bin/env python
# encoding: utf-8

import setuptools
import sys
from numpy.distutils.core import setup


####
#Gfortran compiler, no optimization:
####
# include_dirs = []
# extra_f90_compile_args=[]
# extra_link_args=[]

####
#Intel composer ifort + mkl, -openmp toggles mutli-processor:
####
# include_dirs = "${MKLROOT}/include"
# extra_f90_compile_args=["-O3 -W0 -WB -openmp -fpp -vec_report0 -mkl=parallel -fPIC"]
# MKLLIBS="${MKLROOT}/lib/intel64/libmkl_intel_lp64.a ${MKLROOT}/lib/intel64/libmkl_intel_thread.a ${MKLROOT}/lib/intel64/libmkl_core.a"
# extra_link_args=["-Wl,--start-group",  MKLLIBS, " -Wl,--end-group -openmp"]

####
#Intel composer ifort + mkl for Mac OS X:
####
include_dirs = "${MKLROOT}/include"
extra_f90_compile_args=["-O3 -W0 -WB -openmp -fpp -vec_report0 -fPIC"]
extra_link_args=["${MKLROOT}/lib/libmkl_intel_lp64.a ${MKLROOT}/lib/libmkl_intel_thread.a ${MKLROOT}/lib/libmkl_core.a -liomp5 -lpthread -lm"]


if '--nonstop' in sys.argv:
    sys.argv.remove('--nonstop')
    from nonstopf2py import f2py
else:
    from numpy import f2py

#generate wrappring code
f2py.run_main(['-m', '_cambWrapper', '-h', '--overwrite-signature', '_dummy.pyf', 'source/CambWrapper.f90'])


desc = open("README.rst").read()


def configuration(parent_package='',top_path=None):
    from numpy.distutils.misc_util import Configuration
    config = Configuration("cambWrapper", parent_package, top_path,
                           namespace_packages = ['cambWrapper'],
                           version='0.2.2',
                           author  = 'Joel Akeret',
                           author_email="jakeret@phys.ethz.ch",
                           description = "Wrapper for the Code for Anisotropies in the Microwave Background",
                           url="http://refreweb.phys.ethz.ch/software/cambWrapper-0.2.2",
                           long_description = desc,
                           license="GPLv3")

    config.add_extension('_cambWrapper',
                         sources=[
                            'camb/constants.f90',
                            'camb/utils.F90',
                            'camb/subroutines.f90',
                            'camb/inifile.f90',
                            'camb/power_tilt.f90',
                            'camb/recfast.f90',
                            'camb/reionization.f90',
                            'camb/modules.f90',
                            'camb/bessels.f90',
                            'camb/equations.f90',
                            'camb/halofit.f90',
                            'camb/lensing.f90',
                            'camb/SeparableBispectrum.F90',
                            'camb/cmbmain.f90',
                            'camb/camb.f90',
                            'source/CambWrapperCore.f90',
                            'source/CambWrapper.f90',
                            '_cambWrapper.pyf'] ,
            include_dirs = include_dirs,
            libraries = [],
            extra_f90_compile_args=extra_f90_compile_args,
            extra_link_args=extra_link_args)

    return config

required = ["numpy>1.6.2"]

setup(configuration=configuration,
        packages = setuptools.find_packages(),
        include_package_data = True,
        platforms = ["any"],
        install_requires=required,
        package_data={"": ["LICENSE"]},
        data_files = [('cambWrapper/camb', ["cambWrapper/camb/params.ini"]),
                      ('cambWrapper', ['camb/HighLExtrapTemplate_lenspotentialCls.dat'])],
        zip_safe = False,
        keywords="cambWrapper, CAMB, Code for Anisotropies in the Microwave Background",
        classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Science/Research",
        "Programming Language :: Python",
        "Programming Language :: Fortran",
        'Natural Language :: English',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
    ])
