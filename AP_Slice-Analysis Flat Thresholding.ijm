waitForUser("Separate your data out by condition");

var sourcedir, resultDir, resultsString, files, subFiles;
var ImgArea, punctaNum, punctaArea, area, PSDresultsString, BassoonresultsString;
var i, y, v, c, ball1, ball2, area, mean, avgMean;

sourcedir = getDirectory("Choose image source");
resultDir = getDirectory("Select output directory for binary masks...");

Dialog.create("Parameter");
	Dialog.addNumber("Rolling Ball radius PSD95 (pix):", 20);
	Dialog.addNumber("Rolling Ball radius Bassoon(pix):", 15);
	Dialog.addNumber("puncta size min (pix):", 6);
	Dialog.addNumber("puncta size max (pix):", 1000000000000000000);
	Dialog.addNumber("circularity min:",0.0);
	Dialog.addNumber("circularity max:",1.00)
Dialog.show();
ball1 = Dialog.getNumber();
ball2 = Dialog.getNumber();
min = Dialog.getNumber();
max = Dialog.getNumber();
cmin = Dialog.getNumber();
cmax = Dialog.getNumber();


resultsString = "PSD95									Bassoon\n";
resultsString =	resultsString+"rolling ball PSD95:	"+ball1+"	"+"rolling ball Bassoon:	"+ball2+"	"+"min puncta size:	"+min+"	"+"max puncta size:	"+max+"\n";
resultsString =	resultsString+"Title	AreaOfImage(um^2)	totalPunctaArea(um^2)	PunctaArea/TotalArea	AvgPunctaArea(um^2)	total#ofPuncta	puncta/100um^2	MeanGreyValue		Title	AreaOfImage(um^2)	totalPunctaArea(um^2)	PunctaArea/TotalArea	AvgPunctaArea(um^2)	total#ofPuncta	puncta/100um^2	MeanGreyValue\n";
print(resultsString);
resultsString =	resultsString+"\n";
BassoonresultsString = "";
PSDresultsString = "";
files = getFileList(sourcedir);
run("Set Measurements...", "area mean area_fraction limit redirect=None decimal=4");

// make subfolders for better organized output
subFolderArray = newArray('PSD95_data/','Bassoon_data/','PSD95_binary/','Bassoon_binary/','PSD95_puncta_masks/','Bassoon_puncta_masks/');
for (i=0; i<subFolderArray.length; i++) {
	File.makeDirectory(resultDir+subFolderArray[i]);
	for(f=0;f<files.length;f++){
		File.makeDirectory(resultDir+subFolderArray[i]+files[f]);
	}
}

for(y=0;y<files.length;y++){
	subFiles = getFileList(sourcedir+files[y]);
	resultsString = resultsString+files[y]+"\n";
	print(files[y]);
	for(v=0;v<subFiles.length;v++){
		area = 0;
		mean = 0;
		BassoonresultsString = "";
		PSDresultsString = "";

		run("Clear Results");
		open(sourcedir+files[y]+subFiles[v]);
		run("Properties...", "channels=2 slices=1 frames=1 unit=micron pixel_width=0.1803572 pixel_height=0.1803752 voxel_depth=1.0000000");
		run("Select All");
		run("Measure");
		ImgArea = getResult("Area",0);

		// Parse file name string
		title = getTitle();
		tempTitle = substring(title,0, (lengthOf(title)-lengthOf(".tif")));
		//plate = substring(title, lastIndexOf(title,'-')-1,lastIndexOf(title,'-'));
		//slice = substring(title, lastIndexOf(title,'-')+1,lastIndexOf(title,'-')+2);
		//image = substring(title, lastIndexOf(title,'-')+2,lastIndexOf(title,'-')+3); // debug...

		run("Split Channels");
 
		// PSD95
		selectWindow("C1-"+title);
		run("Duplicate...", "title=green");
		run("Clear Results");
		roiManager("reset"); 
		selectWindow("C1-"+title);
		run("Subtract Background...", "rolling="+ball1); // set rolling ball radius for PSD95 channel here.
		setThreshold(47,230);
		run("Find Maxima...", "noise=15 output=[Segmented Particles] above");
		run("Make Binary");
		selectWindow("C1-"+title+" Segmented");
		run("Duplicate...", "title=mask");
		selectWindow("C1-"+title+" Segmented");
		run("Analyze Particles...", "size="+min+"-"+max+" pixel circularity="+cmin+"-"+cmax+" show=[Bare Outlines] display clear add");
		roiManager("Show All without labels");
		roiManager("Save", resultDir+"PSD95_data/"+files[y]+tempTitle+"_PSD95.zip");
		selectImage("mask");
		saveAs("tiff",resultDir+"PSD95_binary/"+files[y]+tempTitle);
		close();
		selectWindow("C1-"+title);
		punctaNum = nResults;
		for(c=0;c<nResults;c++)	{
			area = area+getResult("Area",c);
		}
		punctaArea = area/punctaNum;
		saveAs("results", resultDir+"PSD95_data/"+files[y]+tempTitle+"_PSD95_puncta.xls");
		saveAs("Tiff", resultDir+"PSD95_puncta_masks/"+files[y]+tempTitle);
		close();

		run("Clear Results"); 
		selectImage("green");
		roiManager("Measure");
		for(c=0;c<nResults;c++)	{
			mean = mean+getResult("Mean",c);
		}
		avgMean = mean/punctaNum;

		PSDresultsString = PSDresultsString+tempTitle+"	"+ImgArea+"	"+area+"	"+(area/ImgArea)+"	"+punctaArea+"	"+punctaNum+"	"+((punctaNum/ImgArea)*100)+"	"+avgMean;
		
		// Bassoon (or gephyrin)
		selectWindow("C2-"+title);
		run("Duplicate...", "title=red");
		run("Clear Results");
		roiManager("reset");
		selectWindow("C2-"+title);
		run("Subtract Background...", "rolling="+ball2); // set rolling ball radius for Bassoon channel here.
		setThreshold(36,240);
		run("Find Maxima...", "noise=15 output=[Segmented Particles] above");
		run("Make Binary");
		selectWindow("C2-"+title+" Segmented");
		run("Duplicate...", "title=mask");
		selectWindow("C2-"+title+" Segmented");
		run("Analyze Particles...", "size="+min+"-"+max+" pixel circularity="+cmin+"-"+cmax+" show=[Bare Outlines] display clear add");
		roiManager("Show All without labels");
		selectImage("mask");
		saveAs("tiff",resultDir+"Bassoon_binary/"+files[y]+tempTitle);
		close();
		roiManager("Save", resultDir+"Bassoon_data/"+files[y]+tempTitle+"_Bassoon.zip");
		selectWindow("C2-"+title);
		punctaNum = nResults;
		for(c=0;c<nResults;c++){
			area = area+getResult("Area",c);
		}
		punctaArea = area/punctaNum;
		saveAs("results", resultDir+"Bassoon_data/"+files[y]+tempTitle+"_Bassoon_puncta.xls");
		saveAs("Tiff", resultDir+"Bassoon_puncta_masks/"+files[y]+tempTitle);
		close();

		run("Clear Results");
		selectImage("red");
		roiManager("Measure");
		for(c=0;c<nResults;c++)	{
			mean = mean+getResult("Mean",c);
		}
		avgMean = mean/punctaNum;
		BassoonresultsString = BassoonresultsString+tempTitle+"	"+ImgArea+"	"+area+"	"+(area/ImgArea)+"	"+punctaArea+"	"+punctaNum+"	"+((punctaNum/ImgArea)*100)+"	"+avgMean;

		resultsString = resultsString+PSDresultsString+"		"+BassoonresultsString+"\n";
		print(PSDresultsString+"		"+BassoonresultsString);
		run("Close All");
	}
}

File.saveString(resultsString,resultDir+"Summary.xls");

