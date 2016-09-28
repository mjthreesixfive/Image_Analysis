setBatchMode(true);

sdir = getDirectory("Choose Source Directory ");
inputdir = sdir+"evfmask/"
evfdir =  sdir+"evf/"
File.makeDirectory(evfdir);
evftifdir =  sdir+"evftif/";
File.makeDirectory(evftifdir);



//Get the list of files in the input directory
    list = getFileList(inputdir);

//Open each file one at a time if it is a .tif
    for (i=0; i<list.length; i++){
        if (endsWith(list[i], "tif")){

        file = inputdir+list[i];
        print(file);
//Get the filename stem without the extension        
        stems = split(list[i],".");
        stem = stems[0];
   
//generate the filepath
   
        path = inputdir+stem+".tif";

     print(path);
open(inputdir+stem+".tif");
print(stem);
print(inputdir+stem+".tif");
evfname = stem+".tif";
run("3D Distance Map", "map=EVF image=evfname mask=None threshold=1");
selectWindow("EVF");
run("Rotate 90 Degrees Right");
evf = evfdir+stem+"-evf";
print(evf);
selectWindow("EVF");
run("8-bit");
saveAs("Tiff", evftifdir+stem+"-evf.tif");
run("Image Sequence... ", "format=Text name="+stem+"-evf- start=0 digits=4 use save="+evf+"-0000.txt save="+evf+"-0000.txt");
run("Close All");
}
}
setBatchMode(false);
