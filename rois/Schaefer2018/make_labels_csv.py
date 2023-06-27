#!/usr/bin/env python
#
# Region labels and network assignments for Schaefer400 set in Yeo7 networks

import pandas

networks_csv = 'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm.Centroid_RAS.csv'

networks = pandas.read_csv(networks_csv)

networks['Label'] = networks['ROI Label']
networks['Region'] = [f'schaefer_{x:03d}' for x in networks['ROI Label']]
networks['Network'] = [x.split('_')[2] for x in networks['ROI Name']]
networks['NetworkNum'] = [0 for x in networks['Network']]

networks.loc[networks.Network=='Vis', 'NetworkNum'] = 1
networks.loc[networks.Network=='SomMot', 'NetworkNum'] = 2
networks.loc[networks.Network=='DorsAttn', 'NetworkNum'] = 3
networks.loc[networks.Network=='SalVentAttn', 'NetworkNum'] = 4
networks.loc[networks.Network=='Limbic', 'NetworkNum'] = 5
networks.loc[networks.Network=='Cont', 'NetworkNum'] = 6
networks.loc[networks.Network=='Default', 'NetworkNum'] = 7

networks = networks[['Label','Region','Network','NetworkNum']]

networks.to_csv(f'Schaefer2018_400Parcels_7Networks_order_FSLMNI152_2mm-labels.csv', index=False)
