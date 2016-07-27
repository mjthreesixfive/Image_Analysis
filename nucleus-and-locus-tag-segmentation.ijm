//This macro takes a 3 channel tif cropped to contain just one nucleus
//It loops through a folder containing many slices and detects several features
//First it makes a binary image of the DNA in the Blue channel
//Then it applies a gaussian filter and draws an outline around this
//This selection is used to measure the cross-sectional area of the DNA
//It is also used to make a mask to remove all red channel signal not overlapping
//DNA. This subset of red channel signal is then segmented using Gaussian filter
//and the selection is also outlined
//finally the green channel is blurred and segmented using a gaussian filter but this needs work

setBatchMode(true); //batch mode on
verbose = false;	//set to true to turn on extra printing

//set directories and measurements
dir1 = getDirectory("Choose Source Directory ");
if(verbose) print(dir1);
rdir = getDirectory("Choose Red Channel Save Directory ");
gdir = getDirectory("Choose Green Channel Save Directory ");
bdir = getDirectory("Choose Blue Channel Save Directory ");
resdir = getDirectory("Choose Results Save Directory ");
if(verbose) print(rdir);
if(verbose) print(gdir);
if(verbose) print(bdir);
if(verbose) print("Got directories");

print("analysing "+dir1);
run("Set Measurements...", "area mean min centroid center perimeter bounding shape median area_fraction display redirect=None decimal=3");

//start the loop with the file names
list = getFileList(dir1);
for (i=0; i<list.length; i++){
	if (endsWith(list[i], "tif")){
		if(verbose) print(list[i]);
		thefile = dir1+list[i];
		if(verbose) print("analysing "+thefile);
		open(thefile);
		if(verbose) print("Opened file");
        run("Make Composite");
		run("Split Channels");
		print("Split channels");

//Store the names of the three channels
        w0 = "C1-"+list[i];
        w1 = "C2-"+list[i];
        w2 = "C3-"+list[i];

//Save the red and green channels for later        
        selectWindow(w1);
        saveAs("Tiff", gdir+w1+"-G.tif"); // save the green channel
		close;
        
        selectWindow(w0);
        saveAs("Tiff", rdir+w0+"-R.tif"); 
		close;
        
//Duplicate the blue channel
        run("Duplicate...", "title="+w2+"-C3 duplicate channels=3");	//duplicate channel 3 (blue from RGB)
        if(verbose) print("Duplicated DNA channel");
        setOption("BlackBackground", true);

//add gaussian blur
        run("Gaussian Blur...", "sigma=2.5 scaled");

//binarise using Kapur's maximum entropy threshold
		setAutoThreshold("MaxEntropy dark");
		run("Convert to Mask");
		run("Fill Holes");
		if(verbose) print("Holes filled");

// save the blue channel mask
  		saveAs("Tiff", bdir+w2+"-M1.tif"); 
        saveAs("Text Image", bdir+w2+"-M1.txt"); 
//create a ROI from the binary image
		run("Create Selection");	
//measure selection
        run("Measure");

//add an overlay of the selection for inspection later
		selectImage(w2);	
		run("Restore Selection");
		Overlay.addSelection("yellow");
		run("Flatten");
		run("Select None");	//remove the ROI

//Save the blue overlay as a flattened RGB image
		saveAs("Tiff", bdir+w2+"-Blue-OL.tif");	
		if(verbose) print("Detection saved");
		run("Close All");	
		
//Open the mask saved from earlier and subtract it from the red channel
		open(bdir+w2+"-M1.tif");
        open(rdir+w0+"-R.tif");
        run("Invert");
        w3 = getList("image.titles");
        imageCalculator("Subtract create", w3[0] , w3[1]);
 
 //Save the subtracted red channel       
        saveAs("Tiff", rdir+w2+"-Red-S.tif");	//save the flattened RGB stack with the overlay
		run("Close All");

//Open the green channel and detect it - perhaps this should be modified to use the max entropy threshold		
		open(gdir+w1+"-G.tif");
		//run("Subtract...", "value=50 stack");
        run("Gaussian Blur...", "sigma=0.25 scaled stack");
        run("Make Binary", "method=Default background=Default calculate black");
        run("Fill Holes", "stack");
        run("Convert to Mask", "method=Default background=Default calculate black");
        run("Create Selection");
        run("Measure");

        open(gdir+w1+"-G.tif");
		run("Restore Selection");
		Overlay.addSelection("green");
		run("Flatten");
		run("Select None");	//remove the ROI
		saveAs("Tiff", gdir+w1+"-Green-OL.tif");	//save the flattened RGB stack with the overlay
		if(verbose) print("Detection saved");
		
//detect the band in the red channel
        open(rdir+w2+"-Red-S.tif");
		run("Subtract...", "value=50 stack");
        run("Make Binary", "method=Default background=Default calculate black");
        run("Fill Holes", "stack");
        run("Despeckle", "stack");
        run("Gaussian Blur...", "sigma=0.5 scaled stack");
        run("Convert to Mask", "method=Default background=Default calculate black");
        run("Create Selection");
        run("Measure");
        open(rdir+w2+"-Red-S.tif");
		run("Restore Selection");
		Overlay.addSelection("yellow");
		run("Flatten");
		run("Select None");	//remove the ROI
		saveAs("Tiff", rdir+w2+"-Red-OL.tif");	//save the flattened RGB stack with the overlay
		if(verbose) print("Detection saved");
		
       }
       resultspath = resdir+"Results"+"13-07-16"+".csv";
	 saveAs("Results", resultspath);
}
setBatchMode(false); //exit batch mode
print(dir1+" analysis finished");
