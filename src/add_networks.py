#!/usr/bin/env python
#
# Add Yeo7 network labels to Schaefer ROIs

import pandas
import sys

roi_dir = sys.argv[1]
out_dir = sys.argv[2]

networks_csv = 'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'
networks_csv = f'{roi_dir}/Schaefer2018/{networks_csv}'

networks = pandas.read_csv(networks_csv)

networks['Label'] = networks['ROI Label']
networks['Region'] = [f'schaefer_{x:03d}' for x in networks['ROI Label']]
networks['Network'] = [x.split('_')[2] for x in networks['ROI Name']]

networks = networks[['Label','Region','Network']]

networks.to_csv(f'{out_dir}/schaefer-networks.csv', index=False)
