# CellAnalysis

## Introduction
CellAnalysis is an image anlysis tool written for the measurement of pixel intensity. 

The primary objective of CellAnalysis is to aid researchers with the evaluation of fluorescence distribution across a cell in a micrograph. A possible usage scenario would be an experiment where a membrane-bound soluble protein of interest (e.g. tagged with a fluorescent protein) is expressed in a cell; then a competitor is added which displaces the protein from the membrane. With increasing competitor concentration more and more of the protein of interest will relocalize from the membrane to the cytoplasm which can be observed using a microscope - i.e. fluorescence of the membrane decreases, while general fluorescence of the cell increases. The general approach to quantifying the protein's displacement is measuring pixel intensity across many cells using a tool like ImageJ which returns a pixel intensity plot for each analysed cell. Further analysis of these plots then often proceeds by hand: the researcher first determines the pixel intensity of the cell membrane and then estimates the average pixel intensity of the cytoplasm (which might be done with a certain bias). Finally, the ratio between membrane and cytoplasmic pixel intensity is caluclated manually. All in all, this method is really laborious and consumes a lot of time - time that could have been spent on conducting another experiment.

CellAnalysis automates many of the described steps

In short, any picture format can be imported into CellAnalysis and pixel intensity is then analysed along a user-created ROI (region of interest) line drawn directly in the image. The pixel data gathered from this is then displayed as a curve
