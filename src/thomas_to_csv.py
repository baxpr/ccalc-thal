#!/usr/bin/env python

import pandas

# Read FSL .txt timeseries

# Read THOMAS time series into CSV and add labels
hs=['left','right']
for h in range(0, len(hs)):
    ts = pandas.read_csv(f'thomas_{hs[h]}_removegm.txt', delim_whitespace=True, 
        usecols=[1,3,4,5,6,7,8,9,10,11,12,13],
        names=[
            'skip1',
            'thom_AV_{hs[h]}',
            'skip3',
            'thom_VA_{hs[h]}',
            'thom_VLa_{hs[h]}',
            'thom_VLP_{hs[h]}',
            'thom_VPL_{hs[h]}',
            'thom_Pul_{hs[h]}',
            'thom_LGN_{hs[h]}',
            'thom_MGN_{hs[h]}',
            'thom_CM_{hs[h]}',
            'thom_MDPf_{hs[h]}',
            'thom_Hb_{hs[h]}',
            'thom_MTT_{hs[h]}',
            ]
        )
    if h==0:
        data = ts
    else:
        data = pandas.concat(data, ts, 0)


# Write to csv

