# CellAnalysis
Created by Sven T. Bitters, 2016

## Introduction
CellAnalysis is an image anlysis tool for the measurement of pixel intensity written in MATLAB. 

The primary objective of CellAnalysis is to aid researchers with the evaluation of fluorescence distribution across a cell in a micrograph. A possible usage scenario would be an experiment where a membrane-bound soluble protein of interest (e.g. tagged with a fluorescent protein) is expressed in a cell; then a competitor is added which displaces the protein from the membrane. With increasing competitor concentration more and more of the protein of interest will relocalize from the membrane to the cytoplasm which can be observed using a microscope - i.e. fluorescence of the membrane decreases, while general fluorescence of the cell increases. The general approach to quantifying the protein's displacement is measuring pixel intensity across many cells using a tool like ImageJ which returns a pixel intensity plot for each analysed cell. Further analysis of these plots then often proceeds by hand: the researcher first determines the pixel intensity of the cell membrane and then estimates the average pixel intensity of the cytoplasm (which may or may not be biased). Finally, the ratio between membrane and cytoplasmic pixel intensity is caluclated manually. All in all, this method is really laborious and consumes a lot of time - time that could have been spent on conducting another experiment.

Using CellAnalysis this process is sped up heavily because after a micrograph has been imported to the software the user only has to place region of interest (ROI) lines across the relevant cells - the subsequent analysis steps are then automated as much as possible. CellAnalysis determines membrane and cytoplasmic regions by itself, then measures mean pixel intensity, and in the end calculates the pixel intensity ratio between membrane and cytoplasm. Once all measurements are done, CellAnalysis returns a text file containing a list with membrane and cytoplasmic pixel intensity and their ratio of all selected cells together with the corresponding pixel intensity plots.


## How to use
<ol>
<li>Open CellAnalysis. There are two plot windows and some buttons in the application window.</li>
<li>Click on the button "Load Image" in order to import an image file. Any image format can be read by CellAnalysis.</li>
<li>After the image has been imported successfully, choose which "cell type" you want to analyse by clicking on one of the buttons in the panel "Choose cell type":</li>
<ul>
<li>"Yeast cells" will analyse cross sections of whole cells, also works with protoplasts.</li>
<li>"Plant cells" is used to analyse cells in the context of tissues, thus the membranes/cell walls between two different cells will be evaluated.</li>
</ul>
<li>By clicking on "Measure Cells" the measurement process is initiated. When inside the borders of the image window the mouse pointer will change to some type of cross-hairs - in this state the start of a ROI line can placed in the image by pressing the left mouse button. By moving the mouse across a cell, the ROI line is drawn. Once the left mouse button is released again, the end of a ROI line is placed in the image. At this stage, the ROI line can still be resized and dragged around the image. Double clicking on the ROI line hands the line over to pixel saturation analysis.</li>
<li>Immediately after double clicking on the ROI line a pixel intensity plot appears in the small plot window on the right side of the application window. CellAnalysis recognizes when the pixel intensity distribution is not plausible in the context of the experiments it was designed to analyze and returns an error in such cases (e.g. there is a peak in the cytoplasm that is higher than the membrane peaks).</li>
<li>If </li>

</ol>
