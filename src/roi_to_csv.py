#!/usr/bin/env python
#
# Read FSL .txt timeseries and convert to csv

import pandas
import sys

roicsv = sys.argv[1]
fsltxt = sys.argv[2]

# Output filename
fslcsv = fsltxt.replace('.txt', '.csv')

# Read ROI labels
roiinfo = pandas.read_csv(roicsv)

# Read time series into data frame and add labels
data = pandas.read_csv(
    fsltxt, 
    delim_whitespace=True, 
    usecols=roiinfo.Label-1,
    names=roiinfo.Region,
    )
    
# Write to csv
data.to_csv(fslcsv, index=False)
