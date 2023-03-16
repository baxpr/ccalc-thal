#!/usr/bin/env python
#
# Read FSL .txt timeseries

import pandas

# Read THOMAS time series into CSV and add labels
hs=['left','right']
for h in range(0, len(hs)):
    print(hs[h])
    ts = pandas.read_csv(f'thomas_{hs[h]}_removegm.txt', delim_whitespace=True, 
        usecols=[1,3,4,5,6,7,8,9,10,11,12,13],
        names=[
            f'skip1',
            f'thom_AV_{hs[h]}',
            f'skip3',
            f'thom_VA_{hs[h]}',
            f'thom_VLa_{hs[h]}',
            f'thom_VLP_{hs[h]}',
            f'thom_VPL_{hs[h]}',
            f'thom_Pul_{hs[h]}',
            f'thom_LGN_{hs[h]}',
            f'thom_MGN_{hs[h]}',
            f'thom_CM_{hs[h]}',
            f'thom_MDPf_{hs[h]}',
            f'thom_Hb_{hs[h]}',
            f'thom_MTT_{hs[h]}',
            ]
        )
    if h==0:
        data = ts
    else:
        data = pandas.concat([data, ts])


# Write to csv
data.to_csv('thomas_removegm.csv')
