//***MUST RUN IN IMAGEJ, FIJI WILL SPLIT CHANNELS***

//Macro to open a folder of tiff stacks
//Wait for user to select and add multiple ROIs to the ROI manager
//Save these ROIs as a .zip file, then crop each original image to a single nucleus
//appending a number to the file name so that each nucleus is uniquely identifiable.

setBatchMode(true); //batch mode on

//get the directory where the images are located
    sdir = getDirectory("choose source directory "); 

//get the destination directory
    ddir = getDirectory("choose destination directory "); 

//get the roi directory
    roidir = getDirectory("choose roi directory ");

//get the list of files in the source directory
    list = getFileList(sdir);

//start a loop which opens each one and waits for user to click OK
    for (i=0; i<list.length; i++){
    stems = split(list[i],".");
    stem = stems[0];
//close any open files
    run("Close All");
   
//get the file path
    path = sdir+list[i];

//Open the current file
    print(path);
    open(path);

run("Duplicate...", "title="+stem+".tif duplicate ");
selectWindow(stem+".tif");
run("Close");

//convert to 8-bit
run("8-bit");

//split the channels
run("Split Channels");

//Store red channel name
w0 = "C2-"+stem+".tif";
selectWindow(w0);
rename("red");

run("Duplicate...", "title=red duplicate channels=1");

selectWindow("red");
run("Subtract...", "value=255 stack");
rename("green");

//Store blue channel name
w2 = "C1-"+stem+".tif";

//waitForUser("Click OK");
run("Merge Channels...", "red=red green=green blue="+w2+" composite" );
run("Make Composite");
//waitForUser("Click OK"); 

run("Z Project...", "projection=[Max Intensity]"); 
//Open the ROI manager
//    run("ROI Manager...");

//Wait for user to click when done
//   waitForUser("Select each ROI, press t to store and then click OK"); 
    close();

//save the ROIs
//    roiManager("Save", roidir+list[i]+".zip");

//Clear the list of ROIs
    roiManager("reset");

//set the rois to crop
    roiset = roidir+stem+".tif.zip";

//open the image
    //open(path);
 
//run ROI Manager
    run("ROI Manager...");
    roiManager("Open", roiset);

//loop through the ROIs and save each frame
    n = roiManager("count"); 
    for (j=0; j<n; j++) { 
    roiManager("select", j); 
    nuc = "_N_"+j; 
    run("Duplicate...", "title = nuc duplicate range=1-3000"); 
    
    saveAs("Tiff", ddir+stem+nuc+".tif");
    close(); 
    } 
//Clear the list of ROIs
    roiManager("reset");
    run("Close All"); 
    }



