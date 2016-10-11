macro 'convert LIF tiff' {

/*
 * - converts LIF files into TIFF. 
 * - the macro ask for an input folder that should contain 1 or more lif files. Nothing else.
 * - each series is saved as one tiff. The name of the series is appended to the file name.
 * - if the series has more the one frame, a Max Intensity projection is performed before saving
 * - the TIFFs are saved in a folder generated by the macro
 * 
 * Martin Hoehne, August 2015
 * 
 *  Update October 2015: works for Multichannel images as well
 */
run("Bio-Formats Macro Extensions");

dir1 = getDirectory("Choose folder with lif files ");
dir2 = getDirectory("Choose folder to save tif files ");

list = getFileList(dir1);

setBatchMode(true);

for (i=0; i<list.length; i++) {
	showProgress(i+1, list.length);
	print("processing ... "+i+1+"/"+list.length+"\n         "+list[i]);
	path=dir1+list[i];

	//how many series in this lif file?
	Ext.setId(path);//-- Initializes the given path (filename).
	Ext.getSeriesCount(seriesCount); //-- Gets the number of image series in the active dataset.




	
for (j=1; j<=seriesCount; j++) {
run("Bio-Formats", "open=path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+j);
text=getMetadata("Info");
title = getTitle();
title = split(title, ".");
title = title[1];
title = replace(title, "lif - ", "");

print("Title is: "+title);
n1=indexOf(text,"Image name = ")+13;

print("n1 = "+n1);

n2 = indexOf(text, "Location", n1);

print("n2 = "+n2);

nameline = substring(text, n1, n2);

stems = split(nameline, "\n");

stem = stems[0];
stem = replace(stem, "lif - ", "");

print("Series is: " + j);
print("stem is: "+stem);



getDimensions(width, height, channels, slices, frames);

print(width+height);

if(width+height > 1024){

saveAs("TIFF", dir2+title+".tif");

}

//if (startsWith(stem,date1)){
//saveAs("TIFF", dir2+stem+"-"+j+".tif");
  //     		run("Close");
//	} else if (startsWith(stem,date2)){

//saveAs("TIFF", dir2+stem+"-"+j+".tif");
    
   		
//	}
run("Close All");
		}
	}


showMessage(" -- finished --");	
run("Close All");
setBatchMode(false);

} // macro