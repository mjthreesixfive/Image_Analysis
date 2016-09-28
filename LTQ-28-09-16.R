#Run Detection macro in ImageJ
system("/Applications/ImageJ144/ImageJ/ImageJ64.app/Contents/MacOS/JavaApplicationStub -batch ~/Desktop/250916/LTQ-25-09-16-v12.8.ijm ")

#Filter the output for nuclei that had one locus tag detection only
setwd("~/Desktop/liftestoutput")
files = dir('Input', full.names =TRUE)
files

stems = sapply(strsplit(files,split = 'Input/'),'[[',2)
stems = sub('.tif','',stems)

lt.results = dir('LocusTagResults', full.names =TRUE)

lt.stems = sapply(strsplit(lt.results,split = 'LocusTagResults/'),'[[',2)
lt.stems = sub('.csv','',lt.stems)
lt.stems == stems

single.det = list()

val.data = "/Users/mj365/Desktop/liftestoutput/manual-validation-27-09-16.csv"
val.df = read.csv(val.data)

#How many manually curated?
table(apply(val.df[,c('X','Y','Z')],1,sum,na.rm=T) > 0)

#How many in the table had a detected lt?
table(val.df$LT > 0)

#How many in the table had a discard flag?
table(val.df$Discard > 0)

#How many were scored as missed
table(val.df$Missed > 0)
val.df$Missed[is.na(val.df$Missed)] = 0
table(val.df$Missed > 0)

val.df[is.na(val.df$LT),]$LT = 0

#Get stem from val.df
val.stem = sub('.tif','',as.character(val.df[,1]))

#Check if discard = 0

val.list = list()
for(i in 1:dim(val.df)[1]){
lt.cent = data.frame(matrix(rep(NA,4),ncol = 4))
colnames(lt.cent) = c('Input','X','Y','Z')
val.list[[i]] = lt.cent
}




for(i in 1:dim(val.df)[1]){
if(val.df$Discard[i] == 0){

        if(sum(val.df[i,c('X','Y','Z')],na.rm=T) > 0){
                lt.cent = val.df[i,c('Input','X','Y','Z')]
                val.list[[i]] = lt.cent
                }
        
        }
}



for(i in 1:length(val.list)){
        if((is.na(val.list[[i]]$Input)) & (dim(read.csv(lt.results[i]))[1] > 0) & val.df$LT[i] != 0){
        lt.row = val.df$LT[i]
        cent.df = read.csv(lt.results[i])
        val.list[[i]]$Input = sub('.csv','',sub('LocusTagResults/','',lt.results[i]))
        val.list[[i]]$X = cent.df[lt.row,'X']
        val.list[[i]]$Y = cent.df[lt.row,'Y']
        val.list[[i]]$Z = cent.df[lt.row,'Z']
        }
}

table(unlist(lapply(val.list, function(x) is.na(x$Input))))

table(val.df$Discard == 1)
table(val.df$Missed == 1)
table(val.df$LT > 0)

#for a quick look before manual curation
#single.det = list()
#for(i in 1: length(lt.stems)){
#        if(dim(read.csv(lt.results[i]))[1] == 1){
#                single.det[[i]] = read.csv(lt.results[i])
#                single.det[[i]]$File = lt.stems[i]
#        }
#}

index = 1:215
val.list2 =val.list[index[unlist(lapply(val.list, function(x) sum(as.numeric(is.na(x))) != 4))]]

lt.df = do.call(rbind,val.list2)
colnames(lt.df)[1] = 'File'
#Copy the masks from these to a new folder

#Get the file paths of the DNAmasks
DNAmask.files = dir('DNAmask',full.names = TRUE)

#get the stems 
DM.stems = sapply(strsplit(DNAmask.files,split = 'DNAmask/'),'[[',2)
#DM.stems = sub('-mask.tif','',DM.stems)

#keep the stems that have detections
detected = sub('-mask.tif','',DM.stems[DM.stems %in% paste(lt.df$File,'-mask.tif',sep='')])

#create a folder for evf masks that have a detection
dir.create('evfmask')

DMpaths = paste(dir(getwd(),full.names = T)[grep('DNAmask',dir(getwd()))],'/',detected,'-mask.tif',sep='')

evfpath = dir(getwd(),full.names = TRUE)[grep('evfmask',dir(getwd(),full.names = TRUE))]

DM.newpath = paste(evfpath,'/',detected,'-mask.tif',sep ='')

file.copy(from = DMpaths, to = DM.newpath, copy.mode = TRUE)


#Compute the EVF map - run the macro via FIJI
#won't run system("/Applications/FIJI.app/Contents/MacOS/ImageJ-macosx -batch ~/Desktop/250916/evf-270916.ijm ")
#system("/Applications/FIJI.app/Contents/MacOS/ImageJ-macosx -batch ~/Desktop/250916/270916-test.ijm ")

#Get the locus tag centroid co-ordinate and the value of the EVF
evffilenames = dir('evf')
evffilepaths = dir('evf',full.names=T)
results.list = list()

for(i in 1:dim(lt.df)[1]){
print(length(grep(paste(lt.df$File[i],'-mask-evf-',sep=''),evffilenames)))
}

lt.df$File = sub('.tif','',lt.df$File)

lt.df = lt.df[-15,]

lt.df[93,]

evffilepaths[grep(lt.df$File[i],evffilenames)]

round(lt.df[93,c('X','Y','Z')])


for(i in 1:length(lt.df$File)){
lt.cent = round(lt.df[i,c('X','Y','Z')])
if(length(grep(lt.df$File[i],evffilenames)) > 0){
        evftoload = evffilepaths[grep(lt.df$File[i],evffilenames)][lt.cent[,'Z']-1]
        print(evftoload)
        evfmap = as.matrix(read.table(evftoload))
        evfmap[as.numeric(lt.cent['X']),as.numeric(lt.cent['Y'])]
        results.list[[i]] = cbind(Nuc = lt.df$File[i],lt.cent,EVF = evfmap[as.numeric(lt.cent['X']),as.numeric(lt.cent['Y'])])
}
print(paste('files found: ', length(grep(lt.df$File[i],evffilenames))))        
}


results.df = do.call(rbind,results.list)
results.m = matrix(unlist(strsplit(as.character(results.df$Nuc),split = '[-_]')),ncol = 7,byrow=T)
results.df$Date = results.m[,1]
results.df$Locus = results.m[,2]
results.df$Sex = results.m[,3]
results.df$ImageID = results.m[,4]
results.df$NucID = results.m[,7]

#only run once
#results.df$EVF = results.df$EVF/255
head(results.df)
barplot(table(results.df$Locus))
barplot(table(results.df$Sex))
barplot(table(results.df$Date))

boxplot(EVF ~ Locus*Sex, data = results.df)


boxplot(EVF ~ Locus, data = results.df)
t.test(x = results.df[results.df$Locus == '68E1','EVF'],y = results.df[results.df$Locus == 'mdelta','EVF'])


#plotting code
n = 20
lt.cent = unlist(c(lt.df$'File'[n],round(lt.df[n,c('X','Y','Z')])))
info.files = dir('iminfo',full.names = T)
info = read.table(info.files[grep(lt.cent[1],info.files)],skip = 1,sep = '\t')

width = as.character(info[2,])
width.microns = as.numeric(sapply(strsplit(width,split = '\\s+'),'[[',2))
width.pixel = as.numeric(sub('\\)','',sub('\\(','',sapply(strsplit(width,split = '\\s+'),'[[',4))))

height = as.character(info[3,])
height.microns = as.numeric(sapply(strsplit(height,split = '\\s+'),'[[',2))
height.pixel = as.numeric(sub('\\)','',sub('\\(','',sapply(strsplit(height,split = '\\s+'),'[[',4))))

depth = as.character(info[4,])
depth.microns = as.numeric(sapply(strsplit(depth,split = '\\s+'),'[[',2))
depth.pixel = as.numeric(sub('\\)','',sub('\\(','',sapply(strsplit(depth,split = '\\s+'),'[[',4))))

XY.scale = width.microns/width.pixel
Z.scale = depth.microns/depth.pixel

evftoload = evffilepaths[grep(lt.cent[1],evffilenames)][as.numeric(lt.cent['Z'])-1]
lt.cent
evftoload
print(evftoload)
evfmap = as.matrix(read.table(evftoload))
image(evfmap)
abline(h = (height.microns-as.numeric(lt.cent['Y'])*XY.scale)/height.microns)
abline(v = as.numeric(lt.cent['X'])*XY.scale/width.microns)
lt.cent
evftoload
lt.cent
n
