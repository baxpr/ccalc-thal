#!/usr/bin/env python
#
# Remove some ROI time series from schaefer ROIs

import pandas
import sys

data_incsv = sys.argv[1]
data_outcsv = sys.argv[2]
networks_incsv = sys.argv[3]
networks_outcsv = sys.argv[4]
excludes = sys.argv[5]

# Excludes are comma separated list like "1,5,219". Convert to list and zero-pad
excludes = excludes.split(',')
excludes = [f'schaefer_{x:03d}' for x in [int(y) for y in excludes]]
print('Excluded ROIs:')
print(excludes)

# Load ROI data and drop cols
data = pandas.read_csv(data_incsv)
data = data.drop(columns=excludes)

# Write back out
data.to_csv(data_outcsv, index=False)

# Load network/ROI list, exclude, write
networks = pandas.read_csv(networks_incsv)
networks = networks.drop(index=[x for x in networks.index if networks.Region[x] in excludes])
networks.to_csv(networks_outcsv, index=False)

