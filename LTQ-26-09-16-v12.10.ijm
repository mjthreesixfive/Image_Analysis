setBatchMode(true);
verbose = false;

//Set the source and directories

    sdir = getDirectory("Choose Source Directory ");
    inputdir = sdir+"Input/"
    File.makeDirectory(inputdir);

//Create directories for the results    
    resultsdir = sdir+"Results/"
    File.makeDirectory(resultsdir);
    outputdir =  sdir+"Output/"
    File.makeDirectory(outputdir);
    DNAmaskdir =  sdir+"DNAmask/"
    File.makeDirectory(DNAmaskdir);
        edgemaskdir =  sdir+"edgemask/"
    File.makeDirectory(edgemaskdir);
         edgemasktifdir =  sdir+"edgemasktif/"
    File.makeDirectory(edgemasktifdir);
         iminfodir =  sdir+"iminfo/"
    File.makeDirectory(iminfodir);
 

//Get the list of files in the input directory
    list = getFileList(inputdir);

//Open each file one at a time if it is a .tif
    for (i=0; i<list.length; i++){
        if (endsWith(list[i], "tif")){
        
        file = inputdir+list[i];
//Get the filename stem without the extension        
        stems = split(list[i],".");
        stem = stems[0];
   
//generate the filepath
        path = inputdir+stem+".tif";

//open the file
        open(path);


//Convert to 8-bit
        //run("8-bit");

//split the channels
        run("Split Channels");

//Store red channel name
        w0 = "C1-"+stem+".tif";

//Store green channel name
        w1 = "C2-"+stem+".tif";

//Store blue channel name
        w2 = "C3-"+stem+".tif";

//Duplicate the blue channel
        selectWindow(w2);
   
        run("Duplicate...", "title="+w2+" duplicate channels=1");
     
//Add Gaussian Blur
        run("Gaussian Blur...", "sigma=2 scaled stack");

//Threshold automatically using an algorithm that maximises the inter-class entropy of the image histogram
       //setAutoThreshold("MaxEntropy dark");
       //run("Threshold...");
       setThreshold(30, 255);
        //run("Threshold...");
        setOption("BlackBackground", true);

//Make a binary mask and fill holes (ignores the nucleolus)
        setOption("BlackBackground", true);
        run("Convert to Mask", "method=Default background=Default black");
        run("Fill Holes", "stack");

//Run 3D segmentation and invert the result
        run("3D Simple Segmentation", "low_threshold=30 min_size=1000 max_size=-1");
       
        selectWindow("Bin");
        run("Invert", "stack");

//Subtract the binary mask from the original image
        
        imageCalculator("Subtract create stack", w2,"Bin");
    
        selectWindow("Result of "+w2);
        rename("Segment1");


//Apply a median filter and another, less stringent threshold to the masked image
        selectWindow("Segment1");
        run("Gaussian Blur...", "sigma=0.5 scaled stack");
        run("Median...", "radius=20 stack");
        setThreshold(10, 255);
        setOption("BlackBackground", true);
        run("Convert to Mask", "method=Default background=Default black");
        run("Fill Holes", "stack");

//Save an improved mask
        saveAs("Tiff", DNAmaskdir+stem+"-mask.tif");
       // waitForUser("Click OK");
        selectWindow(stem+"-mask.tif");
        run("Invert", "stack");
        
//Subtract the new mask from the original image
imageCalculator("Subtract create stack", w2,stem+"-mask.tif");

//Run 3D object counter
run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D Objects Counter", "threshold=30 slice=10 min.=500 max.=8912896 exclude_objects_on_edges objects surfaces centroids centres_of_masses statistics summary");

//Save measurements
selectWindow("Statistics for Result of "+w2);
saveAs("Results", resultsdir+"C3-"+stem+".csv");
selectWindow("Statistics for Result of "+w2);
run("Close");

//Make a boundary outline
selectWindow("Objects map of Result of "+w2);
run("Brightness/Contrast...");
run("Gaussian Blur...", "sigma=0.5 scaled stack");
setThreshold(1,255);
run("Convert to Mask", "method=Default background=Default black");
run("Fill Holes", "stack");
run("Despeckle", "stack");

//save another improved mask
saveAs("Tiff", DNAmaskdir+stem+"-mask.tif");

run("Find Edges", "stack");
saveAs("Tiff", edgemasktifdir+stem+"-edge.tif");
run("Rotate 90 Degrees Right");
edgepath = edgemaskdir+stem+"-edge";
print(edgepath);
//run("Image Sequence... ", "format=Text name="+stem+"- start=0 digits=4 use save="+edgepath+"-0000.txt save="+edgepath+"-0000.txt");
run("Rotate 90 Degrees Left");
open(edgemasktifdir+stem+"-edge.tif");

//Rename the centroid map channel
w3 ="Centroids map of Result of "+w2;
selectWindow(w3);

rename("centroids");
open(DNAmaskdir+stem+"-mask.tif");
selectWindow(stem+"-mask.tif");


//Merge into an overlay and save

run("Merge Channels...", "red="+stem+"-edge.tif green=centroids blue="+w2+" create keep ignore");

saveAs("Tiff", outputdir+stem+"-DNA-OL.tif");      

run("Close All");


//Set the output directories for the red channel
    ltdir =  sdir+"LocusTagResults/";
    File.makeDirectory(ltdir);
    ltoutputdir =  sdir+"LocusTagOutput/";
    File.makeDirectory(ltoutputdir);
    detoutputdir =  sdir+"DetectionOutput/";
    File.makeDirectory(detoutputdir);
    
open(DNAmaskdir+stem+"-mask.tif");
//rename("mask");
run("Invert", "stack");
open(path);

//Convert to 8-bit
        //run("8-bit");

//split the channels
        run("Split Channels");

//Store red channel name
        w0 = "C1-"+stem+".tif";

//Store green channel name
        w1 = "C2-"+stem+".tif";

//Store blue channel name
        w2 = "C3-"+stem+".tif";
  
        imageCalculator("Subtract create stack",w0,stem+"-mask.tif");
        run("Gaussian Blur...", "sigma=0.4 scaled stack");
        //run("Auto Threshold", "method=Yen white stack");
        setThreshold(70, 255);
        setOption("BlackBackground", true);
        run("Convert to Mask", "method=Default background=Default black");
        run("Invert", "stack");

        imageCalculator("Subtract create stack",w0,"Result of "+w0);
        run("3D Simple Segmentation", "low_threshold=10 min_size=15 max_size=-1");
        selectWindow("Bin");
        run("Invert", "stack");
        imageCalculator("Subtract create stack",w0,"Bin");
           

run("3D OC Options", "volume surface nb_of_obj._voxels nb_of_surf._voxels integrated_density mean_gray_value std_dev_gray_value median_gray_value minimum_gray_value maximum_gray_value centroid mean_distance_to_surface std_dev_distance_to_surface median_distance_to_surface centre_of_mass bounding_box dots_size=5 font_size=10 show_numbers white_numbers store_results_within_a_table_named_after_the_image_(macro_friendly) redirect_to=none");
run("3D Objects Counter", "threshold=50 slice=10 min.=15 max.=8912896 exclude_objects_on_edges objects surfaces centroids centres_of_masses statistics summary");
        selectWindow("Statistics for Result of "+w0);
        saveAs("Results", ltdir+stem+".csv");
        stat ="Statistics for Result of "+w0;
        selectWindow(stat);
        run("Close");
       
       selectWindow("Objects map of Result of "+w0);
        run("Brightness/Contrast...");
       

        rename("Bin");
        w5 ="Centroids map of Result of "+w0;
        selectWindow(w5);
        rename("centroids");
        selectWindow("Bin");
        run("Invert", "stack");
        run("Merge Channels...", "red=Bin green=centroids blue="+w2+" create keep ignore");
        saveAs("Tiff", ltoutputdir+stem+"-LT-OL.tif");

selectWindow("B&C");
run("Close");
//waitForUser("Click OK");    
     
run("Close All");

open(outputdir+stem+"-DNA-OL.tif");
//split the channels
        run("Split Channels");
//Store red channel name
        w10 = "C1-"+stem+"-DNA-OL.tif";

//Store green channel name
        w11 = "C2-"+stem+"-DNA-OL.tif";

//Store blue channel name
        w12 = "C3-"+stem+"-DNA-OL.tif";


open(ltoutputdir+stem+"-LT-OL.tif");//split the channels
        run("Split Channels");
//Store red channel name
        w13 = "C1-"+stem+"-LT-OL.tif";

//Store green channel name
        w14 = "C2-"+stem+"-LT-OL.tif";

//Store blue channel name
        w15 = "C3-"+stem+"-LT-OL.tif";

imageCalculator("Add create stack",w11,w13);
rename("DNA-cent-LT-mask");
selectWindow("DNA-cent-LT-mask");
run("RGB Color");
run("8-bit Color", "number=256");
imageCalculator("Add create stack",w10,w14);
rename("DNA-mask-LT-cent");        
selectWindow("DNA-mask-LT-cent");        
run("RGB Color");
run("8-bit Color", "number=256");
open(DNAmaskdir+stem+"-mask.tif");
run("Invert", "stack");
imageCalculator("Subtract create stack",w12,stem+"-mask.tif");
selectWindow("Result of "+w12);
rename("blue");
selectWindow("blue");
run("RGB Color");
run("8-bit Color", "number=256");
//waitForUser("Click OK");
run("Merge Channels...", "red=DNA-cent-LT-mask green=DNA-mask-LT-cent blue=blue create");
//waitForUser("Click OK");
selectWindow("Composite");
run("Stack to RGB", "slices");
//waitForUser("Click OK");
//saveAs("Tiff", detoutputdir+stem+"-Det-OL.tif");
run("Show Info...");
selectWindow("Info for "+stem+"-Det-OL.tif");
saveAs("Text", iminfodir+stem+".txt");
//waitForUser("Click OK");
run("Close All");


}
}

setBatchMode(false);
run("Quit");
