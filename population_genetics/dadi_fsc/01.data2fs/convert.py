#! /usr/bin/env python
import dadi
import sys,os

input_file = sys.argv[1]
output_file = sys.argv[2]
dd=dadi.Misc.make_data_dict(input_file)
fs=dadi.Spectrum.from_data_dict(dd,pop_ids=['population1','population2'],projections=[10,10])
dadi.Spectrum.to_file(fs,output_file)
