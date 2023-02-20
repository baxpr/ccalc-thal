# Insula / Amygdala / TPJ ROI set

     1  left posterior insula
     2  right posterior insula
     3  left mid insula
     4  right mid insula
     5  left anterior insula
     6  right anterior insula
     7  left basolateral amygdala
     8  right basolateral amygdala
     9  left centromedial amygdala
    10  right centromedial amygdala
    11  left aTPJ
    12  right aTPJ

## Insular regions (posterior, mid, anterior) 

These were generated using the 16 cytoarchitecturally-defined ROIs in Farb et al. (2013). The posterior, mid, and anterior ROIs included the 2 most posterior, 3 middle, and 3 most anterior regions per hemisphere, respectively. Overlapping voxels between middle and anterior, posterior regions were assigned to respective anterior and posterior regions.

- Farb, N. A. S., Segal, Z. V., & Anderson, A. K. (2013). Attentional Modulation of Primary Interoceptive and Exteroceptive Cortices. Cerebral Cortex, 23(1), 114–126. https://doi.org/10.1093/cercor/bhr385

## Amygdala regions (centromedial, basolateral nuclei)

These were generated via the Juelich atlas in FSL, thresholding the corresponding maps at 50%. Since the centomedial region is significantly smaller, voxels that met criteria for both regions were assigned to the centromedial ROI rather than basolateral.

- Amunts, K., Kedo, O., Kindler, M., Pieperhoff, P., Mohlberg, H., Shah, N. J., ... & Zilles, K. (2005). Cytoarchitectonic mapping of the human amygdala, hippocampal region and entorhinal cortex: intersubject variability and probability maps. Anatomy and embryology, 210(5-6), 343-352.

## Temporoparietal junction (TPJ)

This ROI was generated using the “aTPJ” map from the Mars et al. (2013) temporoparietal junction parcellation in FSL, thresholded at 50%.

- Mars, R. B., Sallet, J., Schuffelgen, U., Jbabdi, S., Toni, I., & Rushworth, M. F. S. (2012). Connectivity-Based Subdivisions of the Human Right “Temporoparietal Junction Area”: Evidence for Different Areas Participating in Different Cortical Networks. Cerebral Cortex, 22(8), 1894–1903. https://doi.org/10.1093/cercor/bhr268
