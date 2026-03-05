//######## Set Up

//Open the OIR image 
//input = getDirectory("input folder where images are stored");
//output = getDirectory("output folder for results");
input = "/Users/caseychristine/Desktop/CB_Test_Images/";
output = "/Users/caseychristine/Desktop/CB_Test_Images_results/";
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
	        
	        //set scale for images
	        run("Set Scale...", "distance=1 known=1.24 unit=micron global");
	        			
	        // Split channels
			selectImage(originalFileName);
			run("Split Channels");
			
			// Specify the names for each channel
			blueChannelName = "C1-" + originalFileName;
			redChannelName = "C2-" + originalFileName;			
			
			//######## Mean Flourescence Intensity (MFI) for Red Channel 
			
			// Select the red channel 
			selectImage(redChannelName);
			
			// Specify the name for the duplicated image
			duplicateTitle = "duplicate_" + redChannelName;
			
			// Duplicate the red channel with the specified title
			run("Duplicate...", "title=" + duplicateTitle);
			
			// Select the original (non-duplicated) version
			selectImage(redChannelName);
			
			//Measure MFI of original image
			run("Set Measurements...", "area mean standard redirect=[None] decimal=2");
			run("Measure");
			
			// Add image name to results table
			selectWindow("Results");
			// change Image File to be the name of the file in all rows
			for (i = 0; i < nResults; i++) {
			        setResult("Image File", i, redChannelName);
			    }
			
			//Save Results Table
			saveAs("Results", output+j+ originalFileNameWithoutExtension + "-Iba1_MFI.csv");
			
			//Clear Results Table
			run("Clear Results");
			
			
			//####### Measuring microglial intensity, shape, count, etc.
			
			//Select red channel
			selectImage(redChannelName);
			
			// Remove the backgroung using Rolling Ball Subtraction 
			run("Subtract Background...", "rolling=50");

			// Increase brightness/contrast of the non-duplicated image with normalization
			// ****changed value to 0.01
			run("Enhance Contrast...", "saturated=0.01");
	
			// Preprocess the image with Gaussian Blur
			// ***** Removed enhanced local contrast
			run("Gaussian Blur...", "sigma=2");
			

			// Threshold and Convert to Mask
			//setAutoThreshold("MaxEntropy dark no-reset");
			//setOption("BlackBackground", true);
			//run("Convert to Mask");
			//setAutoThreshold("Intermodes dark");
			setAutoThreshold("MaxEntropy dark no-reset");
			setOption("BlackBackground", true);
			run("Convert to Mask");
			

			// Initial Measurements
			// ***** changed values for size and circularity
			run("Set Measurements...", "area mean standard min max perimeter shape limit redirect=[None] decimal=2");
			run("Analyze Particles...", "size=6.00-infinity circularity=0.5-1.00 show=Outlines display summarize overlay composite add");
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
			        setResult("Image File", i, redChannelName);
			    }
			
			// Open the image as a composite
			options = "open=[Bio-Formats] color_mode=Composite view=Hyperstack";
			run("Bio-Formats Importer", "open=[" + input + list[j] + "]" + options);
	
			// Create a composite image with the Red ROI overlay on all channels
			//print("Selected Image: " + composite1Name);
			//selectImage(composite1Name);
			run("Colors...", "channels=1 slices");
			roiManager("Show All without labels");
			run("Make Composite");
	
			// Save the composite image as TIFF with the overlay
			saveAs("Tiff", output+j+ originalFileNameWithoutExtension + "_Composite_Image.tif");
	
			// Save the results to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+ originalFileNameWithoutExtension + "-Iba1_Count.csv");
			
			// Save Summary data from results
			selectWindow("Summary");
			// Save the Summary to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+ originalFileNameWithoutExtension + "-Iba1_Summary.csv");
					
			//Clear the results Table
			run("Clear Results");
			
			//roiManager("select", indexes);
			//roiManager("Add");
			//roiManager("Save", output+j+ originalFileNameWithoutExtension + "-Aggregates_RoiSet.zip");
			
			// Save the non-duplicated original image as TIFF with the overlay
			selectImage(redChannelName);
			saveAs("Tiff", output+j+ originalFileNameWithoutExtension + "-redChannel_with_ROI.tif");
			
			//*****also changed size values here and circularity
			run("Set Measurements...", "area mean standard min max perimeter shape limit redirect=[duplicate_C2-" + originalFileName + "] decimal=2");
			run("Analyze Particles...", "size=6-infinity circularity=0.50-1.00 show=Outlines display summarize overlay composite add");
			run("Measure");
			
			// Save the results to a different CSV file (replace with your desired file path)
			selectWindow("Results");
			// change Image File to be the name of the file in all rows
			for (i = 0; i < nResults; i++) {
			        setResult("Image File", i, "duplicate_C2-" + originalFileName + "");
			    }
			    
			// Save the Summary to a CSV file (replace with your desired file path)
			saveAs("Results", output+j+ originalFileNameWithoutExtension + "_Duplicate_Image_Results.csv");
			
			        // Clear the results Table
			        run("Clear Results");
			
			        // Clear All Windows 
			        // Images
			        run("Close All");
			        // Tables
			        tableNames = getList("window.titles");
			        for (i = 0; i < tableNames.length; i++) {
			            selectWindow(tableNames[i]);
			            run("Close");
			        }
			    }
			}

run("Close All");