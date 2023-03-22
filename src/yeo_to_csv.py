#!/usr/bin/env python
#
# Read FSL .txt timeseries and convert to csv

import pandas

# Read time series into CSV and add labels
data = pandas.read_csv(f'yeo.txt', delim_whitespace=True, 
    names=[f'yeo_{n:03d}' for n in range(1,8)]
    )
    
# Write to csv
data.to_csv(f'yeo.csv', index=False)
