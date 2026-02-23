#! /usr/bin/env python
import os,sys,re
# import matplotlib
# matplotlib.use('Agg')
import numpy
import sys
from numpy import array
# import pylab
import dadi

outdir = "bootstrap"
spectrum_file = "dadi.fs"
data = dadi.Spectrum.from_file(spectrum_file)

for num in range(0,100):
    bootstrap = data.sample()
    subdir= outdir + "/bootstrap" + str(num)
    if not os.path.exists(subdir):
        os.makedirs(subdir)
    outfile= subdir + "/dadi.fs"
    dadi.Spectrum.to_file(bootstrap,outfile)
