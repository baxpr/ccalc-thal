#!/usr/bin/env python
#
# Region labels and network assignments for Schaefer400 set in Yeo7 networks

import pandas

networks_csv = 'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'

networks = pandas.read_csv(networks_csv)

networks['Label'] = networks['ROI Label']
networks['Region'] = [f'schaefer_{x:03d}' for x in networks['ROI Label']]
networks['Network'] = [x.split('_')[2] for x in networks['ROI Name']]

networks = networks[['Label','Region','Network']]

networks.to_csv(f'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm-labels.csv', index=False)
