#!/usr/bin/env python
#
# Read FSL .txt timeseries

import pandas

# Read time series into CSV and add labels
data = pandas.read_csv(f'schaefer_removegm.txt', delim_whitespace=True, 
        names=[f'schaefer_{n:03d}' for n in range(1,401)]
        )

# Write to csv
data.to_csv('schaefer_removegm.csv', index=False)
