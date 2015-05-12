#!/usr/bin/env python
# encoding: utf-8

import setuptools
from numpy.distutils.core import setup
from platform import system
import os

#Path to the CFITSIO installation
CFITSIO = "/opt/local/"

#If true WMAP data will be installed with the python package.
#If false the path to the data has to be passed when calling the WmapWrapperManager
include_data_files = True

desc = open("README.rst").read()

if system() == "Linux":
    ###
    # Intel with MKL
    ###
    include_dirs = [CFITSIO + "/include", "${MKLROOT}/include"]
    library_dirs = [CFITSIO + "/lib", "${MKLROOT}/lib/intel64 "]
    libraries = ["cfitsio", "mkl_intel_lp64", "mkl_intel_thread", "mkl_core", "iomp5", "mkl_mc3", "mkl_def", "pthread", "m"]
    extra_f90_compile_args=["-O3 -openmp -DOPTIMIZE -I${MKLROOT}/include/intel64/ilp64 -I${MKLROOT}/include"]
    extra_link_args=["${MKLROOT}/lib/intel64/libmkl_lapack95_ilp64.a -openmp"]
    
elif system() == "Darwin":
    ####
    #Intel with MKL on Mac OS X
    ####
    include_dirs = [CFITSIO + "/include", "${MKLROOT}/include", "${MKLROOT}/lib/intel64/lp64"]
    library_dirs = [CFITSIO + "/lib", "${MKLROOT}/lib"]
    libraries = ["cfitsio"]
    extra_f90_compile_args=["-O3 -DOPTIMIZE"]
    extra_link_args=["${MKLROOT}/lib/libmkl_lapack95_lp64.a -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm"]

def get_data_files():
    if(not include_data_files):
        return []
    
    data_files = []
    data_folder = "likelihood_v4p1/data"
    target_folder = "wmap7Wrapper/data"
    for root, subFolders, files in os.walk(data_folder):
        filePaths = []
        for file in files:
            filePaths.append(root+"/"+file)
        data_files.append((root.replace(data_folder, target_folder), filePaths))
    return data_files


def configuration(parent_package='',top_path=None):
    from numpy.distutils.misc_util import Configuration
    config = Configuration("wmap7Wrapper", parent_package, top_path,
                           namespace_packages = ['wmap7Wrapper'],
                           version='0.3.0',
                           author  = 'Joel Akeret',
                           author_email="jakeret@phys.ethz.ch",
                           description = "perform the wmap likelihood computation",
                           url = "http://www.fhnw.ch",
                           long_description = desc)

    config.add_extension('_wmapWrapper',
                         sources=[
            				'likelihood_v4p1/read_archive_map.f90',
            				'likelihood_v4p1/read_fits.f90',
            				'likelihood_v4p1/healpix_types.f90',
                            'source/br_mod_dist.f90',
            				'likelihood_v4p1/WMAP_7yr_options.F90',
            				'likelihood_v4p1/WMAP_7yr_util.f90',
            				'likelihood_v4p1/WMAP_7yr_gibbs.F90',
            				'likelihood_v4p1/WMAP_7yr_tt_pixlike.F90',
            				'likelihood_v4p1/WMAP_7yr_tt_beam_ptsrc_chisq.f90',
                            'source/WMAP_7yr_teeebb_pixlike.F90',
            				'likelihood_v4p1/WMAP_7yr_likelihood.F90',
            				'source/WmapWrapperCore.f90',
            				'source/WmapWrapper.f90',
            				'_wmapWrapper.pyf'] ,
                            include_dirs = include_dirs,
                            library_dirs = library_dirs,
                            libraries = libraries,
                            extra_f90_compile_args=extra_f90_compile_args,
                            extra_link_args=extra_link_args
                            )

    return config



required = ["numpy"]

setup(configuration=configuration,
        packages = setuptools.find_packages(),
        include_package_data = True,
        platforms = ["any"],
        install_requires=[required],
        package_data={"": ["LICENSE"],
                      'wmap7Wrapper': ['data/*.dat']},
        data_files = get_data_files(),
        zip_safe = False,
        classifiers=[
        "Development Status :: 3 - Alpha",
        "Intended Audience :: Science/Research",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
    ])


