#!/usr/bin/env python
from cambWrapper import CambCoreModule, CL_TT_KEY, CL_TE_KEY, CL_EE_KEY, CL_BB_KEY
from cosmoHammer.ChainContext import ChainContext

lmax = 2000
camb = CambCoreModule(lmax = lmax)
camb.setup()

params = [70, 0.0426, 0.122, 2.1E-009, 0.96, 0.09]
ctx = ChainContext(None, params)

camb(ctx)

cl_tt =ctx.get(CL_TT_KEY)
assert cl_tt.shape == (lmax-1,)
assert ctx.contains(CL_TE_KEY)
assert ctx.contains(CL_EE_KEY)
assert ctx.contains(CL_BB_KEY)