#!/usr/bin/env python

import pandas

label = [x for x in range(1,401)]
region = [f'schaefer_{n:03d}' for n in range(1,401)]

info = pandas.DataFrame(list(zip(label, region)), columns=['Label','Region'])

info.to_csv('Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm-labels.csv', index=False)
