#!/usr/bin/env python
#
# Read FSL .txt timeseries

import pandas

for gm in ['removegm','keepgm']:

    # Read time series into CSV and add labels
    data = pandas.read_csv(f'schaefer_{gm}.txt', delim_whitespace=True, 
        names=[f'schaefer_{n:03d}' for n in range(1,401)]
        )
    
    # Write to csv
    data.to_csv(f'schaefer_{gm}.csv', index=False)
