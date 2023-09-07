# SliceAnalysis
This macro generates puncta density and colocalization analysis where it applies rolling ball background subtraction on each channel, then makes/saves binary masks of each image and the puncta ROIs for each. It saves an excel file including average puncta area, puncta area per whole image, area per 100um2, total number of puncta and total number per 100um2. These data can then be used for manual colocalization.

[![DOI](https://zenodo.org/badge/632650728.svg)](https://zenodo.org/badge/latestdoi/632650728)

This macro was developed for analysis of organotypic slice culture IHC
"Starting Images" folder should contain nested folders of non-RGB z-stack MAX projection two channel images by condition

One initiated, please select the "Starting Images" folder
You will then be prompted to set parameters, though they will unlikely need to be changed:
* Rolling ball radius for the two channels
* Max/min puncta size
* Adjustment of circularity

Once complete, you will have an output of three folders per channel:
* Binary – masks of the image separated by channel
* Data – contains the .zip file with ROI data and an .xls file with the individual puncta areas per image
* Puncta masks – contains a tracing of the puncta analyzed in each image
  
Also outputs a “Summary.xls” file with the following results per channel and condition:
* AreaOfImage(um^2)
* totalPunctaArea(um^2)
* PunctaArea/TotalArea
* AvgPunctaArea(um^2)
* total#ofPuncta
* puncta/100um^2
* MeanGreyValue
