from os.path import join

from cosmoHammer.ChainContext import ChainContext
from planck13Wrapper.PlanckLikelihoodModule import PlanckLikelihoodModule
from numpy import exp, array, arange
from pycambWrapper.PyCambCoreModule import PyCambCoreModule

camb = PyCambCoreModule(lmax = 2700)
camb.setup()

# Path to clik files
path = ''

clik_files = [join(path,'commander_v4.1_lm49.clik'),join(path,'CAMspec_v6.2TN_2013_02_26_dist.clik'),
              join(path,'lowlike_v222.clik')]
# clik_files = join(path,'commander_v4.1_lm49.clik')

params = array([67.04, 0.022032, 0.12038, exp(3.0980)*1e-10, 0.9619, 0.0925, 152, 63.3, 117.0, 0.0, 27.2, 6.80, 0.916, 0.406, 0.601, 1.0, 1.0, 0.03, 0.9, 0.0])

nuisance_indices = [[], range(6,6+14), []]
# nuisance_indices = [[]]

like = PlanckLikelihoodModule(clik_files, nuisance_indices)
like.setup()

ctx = ChainContext(None, params)

camb(ctx)

print like.computeLikelihood(ctx)