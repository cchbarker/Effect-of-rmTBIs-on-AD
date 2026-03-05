//######## Set Up

//Open the OIR image 
//input = getDirectory("input folder where images are stored");
//output = getDirectory("output folder for results");
input = "/Volumes/NO NAME/Reelin_Image_Analysis/Images/";
output = "/Volumes/NO NAME/Reelin_Image_Analysis/Results/";
list = getFileList(input);
setBatchMode(false);

// Iterate over each file in the image folder
for (j = 0; j < list.length; j++) {
    if (endsWith(list[j], ".oir")) { // Assuming your images have the ".oir" extension
	        options = "open=[Bio-Formats] color_mode=Default view=Hyperstack";
	        run("Bio-Formats Importer", "open=[" + input + list[j] + "]" + options);
	        
	        // Get the original file name without extension
	        originalFileName = getTitle();
	        originalFileNameWithoutExtension = File.getName(originalFileName);
	        originalFilePath = getInfo("image.filename");
			
			// Split channels
			selectImage(originalFileName);
			run("Split Channels");
			
			// Specify the names for each channel
			blueChannelName = "C1-" + originalFileName;
			greenChannelName = "C2-" + originalFileName;

			//####### DAPI Count 
			
			run("Set Scale...", "distance=1 known=0.311 unit=micron global");
			
			// Select the DAPI channel (blue channel)
			selectImage(blueChannelName);
			
			// Duplicate and specify the name for the duplicated image
			duplicateTitle = "duplicate_" + blueChannelName;
			
			// Duplicate the blue channel with the specified title
			run("Duplicate...", "title=" + duplicateTitle);
	
			// Select the original (non-duplicated) version
			selectImage(blueChannelName);
			
			// Preprocess the image with Gaussian Blur
			run("Gaussian Blur...", "sigma=2");
			run("Max...", "value=2000");
			run("Subtract Background...", "rolling=50");
			
			//run("Threshold...");
			setAutoThreshold("Default dark no-reset");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Watershed");
			
			// Initial Measurements
			run("Set Measurements...", "area mean standard min max perimeter shape limit redirect=[None] decimal=2");
			run("Analyze Particles...", "size=10.00-Infinity circularity=0.50-1.00 show=Outlines display summarize overlay composite add");
			run("Measure");
			
			// Get the number of ROIs in the ROI Manager
			nROIs = roiManager("count");

			// Create an array to store ROI indices
			indexes = newArray(nROIs);

			// Fill the array with ROI indices
			for (i = 0; i < nROIs; i++) {
			    indexes[i] = i;
			}

			// Add image name to results table
			selectWindow("Results");
			// change Image File to be the name of the file in all rows
			for (i = 0; i < nResults; i++) {
			        setResult("Image File", i, blueChannelName);
			    }
			
			// Open the image as a composite
			options = "open=[Bio-Formats] color_mode=Composite view=Hyperstack";
			run("Bio-Formats Importer", "open=[" + input + list[j] + "]" + options);
	
			// Create a composite image with the GFAP ROI overlay on all three channels
			//print("Selected Image: " + composite1Name);
			//selectImage(composite1Name);
			run("Colors...", "channels=1 slices");
			roiManager("Show All");
			run("Make Composite");
	
			// Save the composite image as TIFF with the overlay
			saveAs("Tiff", output+j+"-DAPI_Composite_Image_With_ROI.tif");
	
			// Save the results to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+"-DAPI_Count_Results.csv");
			
			// Save Summary data from results
			selectWindow("Summary");
			// Save the Summary to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+"-DAPI_Count_Summary.csv");
					
			//Clear the results Table
			run("Clear Results");
			
			roiManager("select", indexes);
			roiManager("Add");
			roiManager("Save", output+j+"-DAPI_RoiSet.zip");
			
			// Save the non-duplicated original image as TIFF with the overlay
			selectImage(blueChannelName);
			saveAs("Tiff", output+j+"-blueChannel_with_ROI.tif");
			
			run("Set Measurements...", "area mean standard min max perimeter shape limit redirect=[duplicate_C1-" + originalFileName + "] decimal=2");
			run("Analyze Particles...", "size=10.00-Infinity circularity=0.50-1.00 show=Outlines display summarize overlay composite add");
			run("Measure");
			
			// Save the results to a different CSV file (replace with your desired file path)
			selectWindow("Results");
			// change Image File to be the name of the file in all rows
			for (i = 0; i < nResults; i++) {
			        setResult("Image File", i, "duplicate_C1-" + originalFileName + "");
			    }
			    
			// Save the Summary to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+"-DAPI_Duplicate_Image_Results.csv");
	
			//Clear the results Table
			run("Clear Results");
			
			// Open the ROI Manager
			run("ROI Manager...");
			
			// Clear the ROI Manager
			roiManager("reset");
					
			
    	//#####Measure MFI of green channel
			//select green channel
			selectImage(greenChannelName);

			// Specify the name for the duplicated image
			duplicateTitle = "duplicate_" + greenChannelName;
			
			// Duplicate the red channel with the specified title
			run("Duplicate...", "title=" + duplicateTitle);
			
			// Select the original (non-duplicated) version
			selectImage(greenChannelName);
			run("Measure");
			
			// Add image name to results table
			selectWindow("Results");
			// change Image File to be the name of the file in all rows
			for (i = 0; i < nResults; i++) {
			        setResult("Image File", i, greenChannelName);
			    }
			//save results
			saveAs("Results", output+j+"_Green_MFI.csv");
			run("Close");
			
			// Clear All Windows 
			// Images
			run("Close All");
			//close tables
			tableNames = getList("window.titles");
			for (i = 0; i < tableNames.length; i++) {
			selectWindow(tableNames[i]);
			run("Close");
   	 	}
	}
}
			
			//close all images
			run("Close All");


			
			
			
			