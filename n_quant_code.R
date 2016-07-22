setwd("~/Desktop/160701_tif_crop")
files = list.files(getwd())
files
glands = paste(sapply(strsplit(files, split = '-'),'[[',4),
sapply(strsplit(files, split = '-'),'[[',9))
unique(glands)

#5 68E1, 3 mdelta 1
setwd("~/Desktop/160701_tif_crop")
files = list.files(getwd())
files
glands = paste(sapply(strsplit(files, split = '-'),'[[',4),
               sapply(strsplit(files, split = '-'),'[[',9))
unique(glands)

nuclei = paste(sapply(strsplit(files, split = '-'),'[[',4),
               sapply(strsplit(files, split = '-'),'[[',9),
               substr(sapply(strsplit(files, split = '-'),'[[',10),1,3),
               substr(sapply(strsplit(files, split = '.tif_nuc'),'[[',2),2,2))

length(grep('68E1',unique(nuclei)))
length(grep('mdelta',unique(nuclei)))
