#!/usr/bin/env python
#
# Read FSL .txt timeseries and convert to csv

import pandas
import sys

roicsv = sys.argv[1]
roiinfo = pandas.read_csv(roicsv)

# Read time series into CSV and add labels
data = pandas.read_csv(
    f'yeo.txt', 
    delim_whitespace=True, 
    usecols=roiinfo.Label-1,
    names=roiinfo.Region,
    )
    
# Write to csv
data.to_csv(f'yeo.csv', index=False)
