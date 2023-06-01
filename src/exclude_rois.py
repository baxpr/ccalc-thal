#!/usr/bin/env python
#
# Remove some ROI time series from schaefer ROIs

import pandas
import sys

datacsv = sys.argv[1]
outcsv = sys.argv[2]
excludes = sys.argv[3]

# Excludes are comma separated list like "1,5,219". Convert to list and zero-pad
excludes = excludes.split(',')
excludes = [f'schaefer_{x:03d}' for x in [int(y) for y in excludes]]
print('Excluded ROIs:')
print(excludes)

# Load ROI data and drop cols
data = pandas.read_csv(datacsv)
data = data.drop(columns=excludes)

# Write back out
data.to_csv(outcsv, index=False)
