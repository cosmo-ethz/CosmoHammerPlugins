#!/usr/bin/env python

import os
import sys
from setuptools.command.test import test as TestCommand
from setuptools import find_packages

try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup


if sys.argv[-1] == 'publish':
    os.system('python setup.py sdist upload')
    sys.exit()


class PyTest(TestCommand):
    def finalize_options(self):
        TestCommand.finalize_options(self)
        self.test_args = []
        self.test_suite = True

    def run_tests(self):
        import pytest
        errno = pytest.main(self.test_args)
        sys.exit(errno)


readme = open('README.rst').read()
doclink = """
Documentation
-------------

The full documentation can be generated with Sphinx"""

history = open('HISTORY.rst').read().replace('.. :changelog:', '')

requires = [] #during runtime
tests_require=['pytest>=2.3'] #for testing

PACKAGE_PATH = os.path.abspath(os.path.join(__file__, os.pardir))

required = ["numpy>=1.6.3"]

setup(
    name='planck13Wrapper',
    version='0.1.0',
    description='CosmoHammer adapter for Planck Likelihood code',
    long_description=readme + '\n\n' + doclink + '\n\n' + history,
    author='Sebastian Seehars',
    author_email='seehars@phys.ethz.ch',
    url='http://www.cosmology.ethz.ch/research/software-lab/cosmohammer.html',
    packages=find_packages(PACKAGE_PATH, "test"),
    package_dir={'planck13Wrapper': 'planck13Wrapper'},
    include_package_data=True,
    license='Proprietary',
    zip_safe=False,
    keywords='planck13Wrapper',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        "Intended Audience :: Science/Research",
        'Intended Audience :: Developers',
        'License :: Other/Proprietary License',
        'Natural Language :: English',
        'Programming Language :: Python :: 2',
        'Programming Language :: Python :: 2.6',
        'Programming Language :: Python :: 2.7',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.3',
    ],
    tests_require=tests_require,
    install_requires=required,
    cmdclass = {'test': PyTest},
)