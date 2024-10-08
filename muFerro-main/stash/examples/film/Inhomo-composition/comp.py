# -*- coding: utf-8 -*-
"""
Created on Tue Jun 23 01:47:56 2020

@author: cxx
"""

import nt_vtk
import numpy as np

#%%
data=np.zeros([2,2,6,1])
for z in range(0,data.shape[2]):
    # data[:,:,z,:]=0.2*z-0.1
    data[:,:,z,:]=1
data[:,:,5,:]=-0.1
nv = nt_vtk.Data()
nv.data = data
nv.get_dat_file("test.in")
