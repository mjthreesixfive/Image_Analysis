# Image Analysis.
## A repository for my image analysis code to detect and quantify nuclear organisation.
###An outline for the directories created and used in each run:
1. Convert
This folder contains ImageJ macros to convert .ids or .lif files into Tif stacks cropped 
images are temporarily stored here.

2. Crop
This folder contains ImageJ macros to crop tiff stack files to cropped slices of 
individual nuclei, images are temporarily stored here.

3.Segment
This folder contains an ImageJ macro to split 3 color image slices to single channel
and segment it, measuring the area and pixel intensities. These measurements are
output to a .csv file in 4.

4. Measure - stores results table

5. Import - an R script for importing the results table and text matrices representing
the segmented images. This should also contain filtering functions where images can be
included or excluded based on area detected, number of objects detected or pixel 
intensity in selection.

6. Organise - an R script to tabulate the data in the R environment after import.
key columns being image metadata, nucleus number, channel, x,y,z co-ordinates and whether
the co-ordinates refer to the image centroid or a median slice.

7. Calculate - an R script using the table described above to calculate minimum distances
between various points in the nucleus. For example, distance from the DNA and Lamin 
centroid to the locus tag centroid, minimum distance from the locus tag centroid to the 
lamin and DNA perimeter. This code can also calculate some summary statistics such as
the mean dimensions of the nucleus and the centroid, the mean position in the x, y and z
directions, the mean minimum distance in various conditions, it should also calculate
the locus tag position normalised to nucleus size, possibly taking the length from the
centroid of the DNA or lamin channel through the locus tag to the perimeter

8. Plot - plots for each of the above calculations.
