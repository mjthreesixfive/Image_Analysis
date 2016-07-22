#Set the directory containing cropped tif files (each image should contain just one nucleus).
setwd("~/Desktop/160701_tif_crop")

#get the file list
files = list.files(getwd())

#get just the tissue sample IDs
glands = paste(sapply(strsplit(files, split = '-'),'[[',4),
sapply(strsplit(files, split = '-'),'[[',9))
unique(glands)

#in this case the result was:
#5 68E1, 3 mdelta 1

#do a similary analysis but counting the nuclei
nuclei = paste(sapply(strsplit(files, split = '-'),'[[',4),
               sapply(strsplit(files, split = '-'),'[[',9),
               substr(sapply(strsplit(files, split = '-'),'[[',10),1,3),
               substr(sapply(strsplit(files, split = '.tif_nuc'),'[[',2),2,2))

#these lines count the unique number of nuclei
length(grep('68E1',unique(nuclei)))
length(grep('mdelta',unique(nuclei)))
