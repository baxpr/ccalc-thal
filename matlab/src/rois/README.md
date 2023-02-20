# Sources for regions of interest

## ASDR set

In `src/rois/asdr`, `asdr.nii.gz` and `asdr-labels.csv`.

Insular regions (posterior, mid, anterior) were generated using 16 cytoarchitecturally-defined ROIs (Farb 2013). The posterior, mid, and anterior ROIs included the 2 most posterior, 3 middle, and 3 most anterior regions per hemisphere, respectively. Overlapping voxels between middle and anterior, posterior regions were assigned to respective anterior and posterior regions.

Amygdala regions (centromedial, basolateral nuclei) were generated via the Juelich atlas in FSL (Amunts 2005), thresholding the corresponding maps at 50%. As the centomedial region is significantly smaller, voxels that met criteria for both regions were assigned to the centromedial ROI rather than basolateral.

The temporoparietal junction (TPJ) ROIs were generated using the anterior and posterior TPJ maps from the temporoparietal junction parcellation in FSL (Mars 2013), thresholded at 50%. The small percentage of overlapping voxels were assigned to anterior TPJ.

Inferior frontal gyrus maps (pars triangularis and pars opercularis) were generated using the Harvard-Oxford cortical atlas in FSL (Desikan 2006), thresholding the corresponding maps at 50%.

Midline regions (though the following regions may be slightly right or left, a single bilateral mask was generated for the following 3 regions due to their proximity to midline, following the corresponding references). The left ventromedial prefrontal cortex (vmPFC) map was generated from connectivity-based parcellations (Jackson 2020), using available maps from https://neurovault.org/collections/4798/. The ventral connectivity cluster was selected, using a 80% intensity threshold. The dorsal anterior cingulate cortex (dACC) and right supplemental motor area (rSMA) masks were generated as 8mm spheres from peak activation coordinates for cognitive-evaluation > affective-experiential empathy and affective-perceptual empathy contrasts, respectively (Fan 2011).

Primary somatosensory regions were generated from mean MNI coordinates for body-part specific responses, determined via electrostimulation (Roux 2018 Table 3). Primary motor regions were generated via the same procedures (Roux 2020 Tables 3-4). Mean coordinates were taken directly from tables in most cases; however, for Table 3 in Roux 2020, mean coordinates were computed from the listed coordinates for each distinct body part, rather than the broader body part groupings provided, e.g. computed for “thumb” rather than the listed mean coordinate for “all fingers”). 4mm spheres were generated around the averaged coordinate for each specific body part listed in each paper. The corresponding spherical regions were added together to form the following categorial groupings:

- S1 trunk: feet, leg, knee, thigh, hip, abdomen, thorax (1 midline voxel was overlapping between the L, R trunk regions; this voxel was deleted from both final ROIs)
- S1 arm: thumb, index (2nd) finger, middle (3rd) finger, ring (4th) finger, little (5th) finger, shoulder, elbow. A few voxels from the added arm ROIs were overlapping with the S1 trunk area; these voxels were assigned to S1 trunk (as the smaller region).
- S1 upper face: eyes, eyebrows, nose, face (cheek)
- S1 lower face: lips, jaw. Ooverlapping voxels with upper face or mouth were assigned to lower face, as the smallest area
- S1 mouth: tongue (base/mid), teeth, larynx, pharynx

- M1 trunk: buttock, foot, hip, knee
- M1 arm: thumb, index (2nd) finger, middle (3rd) finger, ring (4th) finger, little (5th) finger, shoulder, elbow, wrist
- M1 upper face: forehead, nose, eyebrows, eyes, cheek
- M1 lower face: lips, jaw
- M1 mouth: tongue, larynx. Overlapping voxels between lower face and mouth were assigned to lower face.

References: 

- Amunts, K., Kedo, O., Kindler, M., Pieperhoff, P., Mohlberg, H., Shah, N. J., ... & Zilles, K. (2005). Cytoarchitectonic mapping of the human amygdala, hippocampal region and entorhinal cortex: intersubject variability and probability maps. Anatomy and embryology, 210(5-6), 343-352.

- Desikan R. S., Ségonne F., Fischl B., Quinn B. T., Dickerson B. C., Blacker D., Buckner R. L., Dale A. M., Maguire R. P., Hyman B. T., Albert M. S., Killiany R. J. An automated labeling system for subdividing the human cerebral cortex on MRI scans into gyral based regions of interest. (2006). Neuroimage, 3(3), 968-80.

- Fan, Y., Duncan, N. W., de Greck, M., & Northoff, G. (2011). Is there a core neural network in empathy? An fMRI based quantitative meta-analysis. Neuroscience & Biobehavioral Reviews, 35(3), 903–911. https://doi.org/10.1016/j.neubiorev.2010.10.009

- Farb, N. A. S., Segal, Z. V., & Anderson, A. K. (2013). Attentional Modulation of Primary Interoceptive and Exteroceptive Cortices. Cerebral Cortex, 23(1), 114–126. https://doi.org/10.1093/cercor/bhr385

- Jackson, R. L., Bajada, C. J., Lambon Ralph, M. A., & Cloutman, L. L. (2020). The Graded Change in Connectivity across the Ventromedial Prefrontal Cortex Reveals Distinct Subregions. Cerebral Cortex, 30(1), 165–180. https://doi.org/10.1093/cercor/bhz079

- Mars, R. B., Sallet, J., Schuffelgen, U., Jbabdi, S., Toni, I., & Rushworth, M. F. S. (2012). Connectivity-Based Subdivisions of the Human Right “Temporoparietal Junction Area”: Evidence for Different Areas Participating in Different Cortical Networks. Cerebral Cortex, 22(8), 1894–1903. https://doi.org/10.1093/cercor/bhr268

- Roux, F.-E., Djidjeli, I., & Durand, J.-B. (2018). Functional architecture of the somatosensory homunculus detected by electrostimulation: Human somatosensory homunculus. The Journal of Physiology, 596(5), 941–956. https://doi.org/10.1113/JP275243

- Roux, F., Niare, M., Charni, S., Giussani, C., & Durand, J. (2020). Functional architecture of the motor homunculus detected by electrostimulation. The Journal of Physiology, 598(23), 5487–5504. https://doi.org/10.1113/JP280156


 

## Amygdala HO50

From the Harvard-Oxford atlas, https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Atlases

## BNST

Avery SN, Clauss JA, Winder DG, Woodward N, Heckers S, Blackford JU. BNST neurocircuitry in humans. Neuroimage. 2014;91:311-323. doi:10.1016/j.neuroimage.2014.01.017

## Hippocampus_Ant HO

Anterior portion (Woolard 2012) of the Harvard-Oxford atlas hippocampus (https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/Atlases)

Woolard AA, Heckers S. Anatomical and functional correlates of human hippocampal volume asymmetry. Psychiatry Res. 2012;201(1):48-53. doi:10.1016/j.pscychresns.2011.07.016

## Hypothalamus

Manual segmentation by J. Blackford

## Insula_anterior

Combination of the 6 anterior sub-regions from

Farb NA, Segal ZV, Anderson AK. Attentional modulation of primary interoceptive and exteroceptive cortices. Cereb Cortex. 2013;23(1):114-126. doi:10.1093/cercor/bhr385

## vmPFC

A 10mm sphere surrounding a peak point of BNST-vmPFC connectivity from Avery et al 2014, (0,53,-9) mm. The sphere was then divided into left and right hemisphere sections.

Avery SN, Clauss JA, Winder DG, Woodward N, Heckers S, Blackford JU. BNST neurocircuitry in humans. Neuroimage. 2014;91:311-323. doi:10.1016/j.neuroimage.2014.01.017


