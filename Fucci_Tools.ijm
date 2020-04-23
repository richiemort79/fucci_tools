//Fucci tools is designed to manaually track Fucci labelled cells in time lapse sequences
//Tracking is manual but the are a number of useful features including creating substack on the fly
//and tracking a reference object at the same time

//Global variables for cell tracking

var cal=0;
var gtrack = 1;
var time_step = 10;//this is the image acquisition rate in minutes
var cal = 0;//This is the resolution of the image in micron/px
var	xpoints =newArray();//the extent of the ROI
var ypoints =newArray();//the extent of the ROI
var shortest = 100000;
var Image = "";
var moving_roi = true;
var m_time_step = 10;
var counter = 1;
var status = "";
var csize = 25;
var	cred = 2;
var	cgreen = 4;
var	ccyan = 5;
var	cbright = 3;
var	cfred = 1;
var view = "01010";

//glabal variables for the profile
var pro_time_step = 0;
var pro_scale = 0;
var pro_number_channels = 0;
var	pro_channels = newArray("Cyan","Green","Red","Far Red");
var pro_channel_order = newArray(1,2,3,4);
var pro_view = "";
var pro_norm = "";
var pro_crop = 0;
var pro_track = "";
var pro_track_step = 0;

macro "Initialize Action Tool - CeefD25D4cD52Dd6CdddD18CfffD00D01D02D03D0cD0dD0eD0fD10D11D1eD1fD20D27D28D2fD30D35D3aD3fD44D4bD53D5cD72D82Da3DacDb4DbbDc0Dc5DcaDcfDd0Dd7DdfDe0De1DeeDefDf0Df1Df2Df3DfcDfdDfeDffCcccDd4CfffD26D39D62D7dD92Db3Dc4Dc6Dd8CdefD22D2dDd2DddCaaaDe7CeffD04D0bD29D37D38D40D45D4fD54D55D64D6cD73D7bD83D8aD8dD99D9cDa8Db0DbfDc9Df4DfbCdefD5bD6aD6bDa9Db7Db8CcdfD14D41Db1CfffD12D1dD21D2eD34D36D43D63D93Dd1DdeDe2DedCdefD05D0aD13D1cD31D3eD50D5fDa0DafDc1DceDe3DecDf5DfaC58cD97CeefD46D47D56D65D84CdeeD9dCbdfDebCbcdDadCeefD49D4aD58D59D5aD67D68D69D6dD7cD8cDa5Da6Db5Db6Dc7Dc8CcefD06D09D60D6fD90D9fDf6Df9C58cD75D76D77D78D79D86D87D88CeefD48D57D66D94D95Da4CddeD24D42Dd5CcdeD3dCbbcD3cDe6C9aaDbdCeeeD2aCbdfD07D08D70D7fD80D8fDf7Df8CaceD96CeffD3bCdddD71CccdDe5CabbDe9C999D7eD8eCdefD8bD9aD9bDaaDabDb9DbaCcdfD1bDe4CbcdDcdDdcCddeD15D51CcdeD1aDa1Dc2Dd3CbbdDaeCaabD9eDdbCeeeDa2CbdeDa7DbeCdddD17D19D81CccdDc3CaabD6eC9aaDccCdefD23D32CcdfD4eCbcdDdaCcdeD2cCaaaDe8CbceD74D85CddeD16D33D61D91CcddD5dDb2CbbbD4dCbcdD5eDeaCdeeDbcDcbDd9CccdD2b"
{

//Must be set up for black background
run("Options...", "iterations=1 count=1 black edm=Overwrite do=Nothing");

//Get locationj of fucci_tools_profile and load the setting
profile_path = getDirectory("macros");


//reset counter on intialise
	counter = 1;

//remove scale if any
	run("Set Scale...", "distance=0 known=0 pixel=1 unit=pixel");
	Image = getTitle();
	dir = File.directory();
	gtrack = 1;
	number = 1;
	count = 1;
	getDimensions(width, height, channels, slices, frames);

//prompt for calibration of image
	Dialog.create("Please set calibration values");
	Dialog.addMessage("Set the scale and time step for the time-lapse");
	Dialog.addNumber("Time Step (min):", 10);
	Dialog.addNumber("Scale (um/px):", 0.83);
	Dialog.addMessage("Set the order of the channels in your image (0 = no Channel)");
	Dialog.addNumber("Cyan Channel =", 5);
	Dialog.addNumber("Green Channel =", 4);
	Dialog.addNumber("Red Channel = ", 2);
	Dialog.addNumber("Far-Red =", 1);
	Dialog.addNumber("Brightfield =", 3);
	Dialog.addString("View while tracking?", "01010");
	Dialog.addString("Normalise?", "01010");
	Dialog.addMessage("Define the dimensions of the substack");	
	Dialog.addNumber("Substack crop size", 50);
	Dialog.addMessage("Do you want to track a reference object?");
	Dialog.addCheckbox("Moving ROI", false);
	Dialog.addNumber("Moving ROI time step", 10);	
	Dialog.show();
	time_step = Dialog.getNumber();
	cal = Dialog.getNumber();
	ccyan = Dialog.getNumber();
	cgreen = Dialog.getNumber();
	cred = Dialog.getNumber();
	cfred = Dialog.getNumber();
	cbright = Dialog.getNumber();
	view = Dialog.getString();
	norm_c = Dialog.getString();
	csize = Dialog.getNumber();
	moving_roi = Dialog.getCheckbox();
	m_time_step = Dialog.getNumber();

//set luts
	Stack.setDisplayMode("color");
	Stack.setChannel(cred);
	run("Red");
	Stack.setDisplayMode("color");
	Stack.setChannel(cgreen);
	run("Green");
	Stack.setDisplayMode("color");
	Stack.setChannel(ccyan);
	run("Cyan");
	Stack.setDisplayMode("color");
	Stack.setChannel(cbright);
	run("Grays");
	Stack.setDisplayMode("color");
	Stack.setChannel(cfred);
	run("Magenta");
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(view);

//prompt user to define the region of interest
	if (moving_roi == true) {
		run("Colors...", "foreground=white background=black selection=cyan");
		setSlice(frames);
		run("Select None");
		setTool("Line");
		waitForUser("Select a Region of Interest", "Please define your ROI and press OK");

//save snapshots frame 1 and last
		setSlice(1);
		Stack.setDisplayMode("composite");//do I need this line?
		run("RGB Color", "keep");
		run("Colors...", "foreground=cyan background=cyan selection=cyan");
		run("Restore Selection");
		run("Draw");
		run("Select None");
		saveAs("Tiff", dir+Image+"_ROI_First.tif");
		selectWindow(Image+"_ROI_First.tif");
		run("Close");

//run("Select None");
		setSlice(slices);
		Stack.setDisplayMode("composite");//do i need this line
		run("RGB Color", "keep");
		run("Colors...", "foreground=cyan background=cyan selection=cyan");
		run("Restore Selection");
		run("Draw");
		run("Select None");
		saveAs("Tiff", dir+Image+"_ROI_Last.tif");
		selectWindow(Image+"_ROI_Last.tif");
		run("Close");

//get the skeleton of the condensate
		selectWindow(Image);
		run("Restore Selection");

		if (isOpen("Results")){
			selectWindow("Results");
			run("Close");
		}

//get the skeleton of the condensate
		selectWindow(Image);
		run("Restore Selection");

		get_skel_xy(Image);
	
//add to the saved images
		open(dir+Image+"_ROI_First.tif");
		run("Restore Selection");
		run("Colors...", "foreground=yellow background=black selection=red");
		run("Draw");
		run("Select None");
		saveAs("Tiff", dir+Image+"_ROI_First.tif");
		run("Close");

		open(dir+Image+"_ROI_Last.tif");
		run("Restore Selection");
		run("Colors...", "foreground=yellow background=black selection=red");
		run("Draw");
		run("Select None");
		saveAs("Tiff", dir+Image+"_ROI_Last.tif");
		run("Close");

//save log of coordinates
		print("X Values");
		Array.print(xpoints);
		print("Y Values");
		Array.print(ypoints);
		selectWindow("Log");
		saveAs("Text", dir+Image+"Seelction_Coordinates.txt");

		if (isOpen("Log")){
			selectWindow("Log");
			run("Close");
		}
		Stack.setDisplayMode("composite");
		Stack.setActiveChannels(view);

	}
}

macro "Interactive Measure Channel Tool - C8aeD3aD49D4aC37dD7fCfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3eD3fD40D41D42D43D50D51D52D53D58D59D5aD5bD5cD5dD5eD60D61D62D68D6eD70D71D77D78D7eD84D87D88D8eD8fD91D93D96D97D98D9eD9fDa3Da6Db0Db1Db2Db3Db4Db5Db6Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8DdfDe0De1De2De3De4De5De6De7De8DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfdDfeDffC777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C9beD57C888D28D46D55D82C481Dd9C8beD75D94C58dC6a3D69Da8C9beD85Da4C999D27D36D37D38D54D63D64D72D73D74D83C280DaeDfaC48dD3dD4dC8beCac8D9cDcaC593DadC8beD66C69dD47D65C777D45C7aeD5fD6fC270DafDecDfbC48dD4eC9c8DbdDccC592D6cC59dD67C6a4DdaCbc9D7aC380D9dC48dCac9D7bD7cD8aD9aDaaDb9C5a3DebC69eC8b6DbcC170DbfDceDddDdeDedDfcC47dD4fC592D6dC59dC7a3Da7C380DeaCac8D8cC6a3D6aD79D89C69eD76D86D95Da5C8b6DabDbbDcbC9c8DdbC693D6bD99Db7C59eD3cD4cC7a5Da9C381De9C6a4DcdC7aeD3bD48D4bC9b7DbaC491D7dC59eC7a4Dc9C5a4DbeC6aeC8b6D8bD9bC592Dc8C9c8DacC8b5Db8C481D8dC6a4Ddc" {
	
//get dimensions and watch for clicks
    Stack.getDimensions(width, height, channels, slices, frames);		
    Stack.setDisplayMode("composite");
    Stack.setActiveChannels(view);
    autoUpdate(false);
    getCursorLoc(x, y, z, flags);

//get nearest distance to the skeleton
	if (moving_roi == true) {
		get_s_dist(x, y, xpoints, ypoints);
		dist = shortest;
	}
	
//measure fucci
    fucci_measure(Image, x, y, 10);
   	for (i=1; i<=channels; i++) {
   		row = nResults - i;
   		setResult("Track", row, gtrack);
   		if (moving_roi == true) {
   			setResult("Dis. from COM", row, dist);
   			setResult("Info", row, status);
   		}   	
   	}
	
	if ((moving_roi == true) && (counter>1) && ((counter/m_time_step)%1)==0) {//checks for an integer value ie divisible by 10
		run("Select None");
		setTool("Line");
		waitForUser("Select a Region of Interest", "Please re-define your ROI and press OK");
		get_skel_xy(Image);
		status = "ROI Reset";
	} else {
		status = "";
	}
    counter++;
    crop_new(Image, x, y, csize);
    Stack.setActiveChannels(view);
    Stack.getPosition(channel, slice, frame);
    Stack.setPosition(channel, slice, frame+1);
    Stack.setDisplayMode("composite");
    Stack.setActiveChannels(view);
    run("Select None");
}


macro "Add Track Action Tool - CfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3aD3bD3cD3dD3eD3fD40D41D42D43D50D51D52D53D60D61D62D68D69D6aD70D71D77D78D79D7aD7bD7cD7dD84D87D88D89D8aD8bD8cD8dD8eD8fD91D93D94D97D98D99D9fDa3Da4Da7Da8Db0Db1Db2Db3Db4Db8DbcDc0Dc1Dc2Dc3Dc4DcbDccDcdDd0Dd1Dd2Dd3Dd4DdcDe0De1De2De3De4De5Df0Df1Df2Df3Df4Df5DffC37dD7fC777D45C69dD47D65C777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C48dD6bDb7Dc7Dd6Cbd9DabDbaDbbDceDecC8beD5eD75C582DaeDeaDeeC48dD4dD6cDc8Dd7Dd8De6De7Df6C999D27D36D37D38D54D63D64D72D73D74D83C7aeD48D4bC8b6DadDbeDdbDdeDebDedC59dDb5Dc5C9beD57C361D9dC48dD4eDf7C888D28D46D55D82C69eDa5C58dD6dDc6Dd5Cbd9DacC684Dc9C8aeD49D4aD58D59C8b6DdaC59dD67C9beD5bD5cD5dD85C47dD4fD7eDe8Df8Df9C69eD76D86Da6C8beD5aD66C473De9C7aeD5fD6fC8beD95C473D9cC6aeD6eCdebDcaC8a6DaaC59eD96Db6C59eD4cC695Da9Db9C584D9bDd9C8b6DbdDddC685D9a"
{

    gtrack++;
    counter=1;
    if (isOpen("Substack")) { 
    	selectWindow("Substack"); 
    	rename("Track_"+gtrack-1+"_Substack");
    } else {}
    waitForUser("A new track ("+gtrack+") has been added to the analysis. If it exists the substack has been renamed as Track_"+gtrack-1+"_Substack. Please select the tracking button and continue");
    setSlice(1);
}

macro "Normalised Intensity Plot Action Tool - CfffD5dCf01D38CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D1fD20D24D26D27D2fD30D31D36D3bD3fD40D41D42D43D49D4aD4bD4fD50D51D52D53D59D5aD5fD60D61D62D66D69D6dD6fD70D71D75D76D77D7cD7fD80D81D84D85D86D8cD8dD8fD90D91D94D95D9bD9cD9dD9fDa0Da1Da8DabDacDafDb0Db1Db2Db7Db8DbcDbdDbfDc0Dc1Dc2Dc7Dc8Dc9DcfDd0Dd1Dd2Dd3Dd8Dd9DdaDdbDdfDe0De1De2De3De4DebDecDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC05eD68C9c8D89C26aD6eD7eD8eD9eDaeDbeDceDdeDeeCf66Db3C45bD57C8beD32Da5C6b6D99Da9Ce34D56C37bD18CeccD2bC26bD5eCabaDddC58eD87CefeD2cDcdC493DcbCf33Dd6C26bD1aD1bCbdbD2dCf77D83D92C38dDe5CbceD22C8a8D3cCf56Dd7De9C37cD11D12D13D14D15D16D17CfddD74C66bD45Cf88D65C7aeD58Db6CfeeD3aDc3C483D6bCf22D39De8C16dD97CacaD6cCf66D37C38dDb5CaceDd4C7b6DaaCf55D73Da3Db4CfccDa2C26bD1cD1dD1eD2eD3eD4eCc9bDe6C7aeD67CeefD25C5a4D7aD8aCf33De7C36bD19CcdcD3dCf77D63C38eDc5CeeeD7dDadC8b8D5bDdcCfeeDa4Dc6DeaCfaaD2aC8aeD79CfffD8bDedC484D4cCf12D47C05eD78D88C9c9DbbCf66D82D93Cf44D64CcecD6aC8beDa7C6aeD44D96C4a3DbaCe23D46CcebDb9C48dD33CcdfD21C8b7D9aCf99D54C594DccCbdbDcaC38eD34CacfD98C8b7D7bCeddD28CfaaD72Cf33D55C27dDa6CcdcD4dCf88D48C48eDd5CdefD23CfbbD29C8beD35Ce55Dc4"{

	Dialog.create("Set parameters");
	Dialog.addNumber("Time between frames (min):", 20);
	Dialog.addNumber("Cyan Channel =", 5);
	Dialog.addNumber("Green Channel =", 4);
	Dialog.addNumber("Red Channel = ", 2);
	Dialog.addNumber("Far-Red =", 1);
	Dialog.addNumber("Brightfield =", 3);
	Dialog.addString("Normalise?", "01010");
	Dialog.show();
	time_step = Dialog.getNumber();
	ccyan = Dialog.getNumber();
	cgreen = Dialog.getNumber();
	cred = Dialog.getNumber();
	cfred = Dialog.getNumber();
	cbright = Dialog.getNumber();
	norm_c = Dialog.getString();
    
//if the results table is empty prompt for a results table
	if (isOpen("Results")) {
	}

	else {
		waitForUser("There is no Results table open please select a tracking table or press cancel");
		table = getInfo("window.name");
		selectWindow(table);
		tdir = getDirectory("temp");
		saveAs("Text", tdir+Image+"Tracking_Results.xls");
		open(tdir+Image+"Tracking_Results.xls");
	}

//get the track numbers in an array to use as the index
	track_number = newArray();
	t_num = 0;

	for (w=0; w<nResults; w++) {
		if ((getResult("Track", w) > t_num)||(getResult("Track", w) < t_num)) {
			t_num = getResult("Track", w);
			track_number = Array.concat(track_number, t_num);	
		}
	}

//loop through each track and make the intensity plot
    for (q=0; q<track_number.length; q++) {
    	print("Normalised, zeroed data for track #"+track_number[q]+"(Time,Cyan,Green,Red,F.Red,Bright)");
    	setBatchMode(true);

//Set time between frames here   

        channels = newArray();
        if (cred > 0) {channels =  Array.concat(channels,cred);}
        if (cgreen > 0) {channels =  Array.concat(channels,cgreen);}
        if (ccyan > 0) {channels =  Array.concat(channels,ccyan);}
        if (cbright > 0) {channels =  Array.concat(channels,cbright);}
        if (cfred > 0) {channels =  Array.concat(channels,cfred);}
        Array.getStatistics(channels, min, max, mean, stdDev);

//Get number of channels
        max_ch = max;

//Get min and max Frames
		min_frame=0;
		max_frame=0;
		for (d=0; d<nResults(); d++) {
    		if (getResult("Frame",d)>max_frame) {
     			max_frame = getResult("Frame",d);
    	}
    	else {};
			}

		min_frame=max_frame;
		for (e=0; e<nResults(); e++) {
    		if (getResult("Frame",e)<min_frame) {
     			min_frame = getResult("Frame",e);
    			}
    	else{};
	}

//Set up the graph
	//Plot.create("Track"+track_number[q]+" Normalised Intensity Plot", "Time (minutes)", "Normalised Integrated Density");
	//Plot.setFrameSize(800, 400);
	//Plot.setLimits((min_frame*time_step), (max_frame*time_step), 0, 5000);
	//Plot.setLineWidth(1);

//Extract values and plot on graph

	red_profile = newArray();
	red_time = newArray();
	green_profile = newArray();
	green_time = newArray();
	cyan_profile = newArray();
	cyan_time = newArray();
	bright_profile = newArray();
	bright_time = newArray();
	fred_profile = newArray();
	fred_time = newArray();


//Get red
	if (cred>0){
		time1=0;
		profile1=0;
		for (i=0; i<nResults(); i++){
			if ((getResult("Ch",i)==cred)&&(getResult("Track", i) == track_number[q])){
				time1 = (getResult("Frame",i))*time_step;
				red_time = Array.concat(red_time,time1);
				profile1 = getResult("RawIntDen",i);
				red_profile = Array.concat(red_profile,profile1);
				}
			}


//smooth and normalise red and zero time
        smooth(red_profile);
        if (substring(norm_c, cred-1, cred) == 1) {
        	normalise(red_profile);
        }
        zero_time(red_time);

//Set up the graph
	Plot.create("Track"+track_number[q]+" Normalised Intensity Plot", "Time (minutes)", "Normalised Integrated Density");
	Plot.setFrameSize(800, 400);
	Array.getStatistics(red_time, min, max, mean, stdDev);
	Plot.setLimits(0, max, 0, 1);
	Plot.setLineWidth(1);

	//plot red        
        Plot.setColor("red");
        Plot.setLineWidth(1);
        Plot.add("circles", red_time, red_profile);
        Plot.add("lines", red_time, red_profile);
       }

//get green
	if (cgreen>0){
		time1=0;
		profile1=0;
		for (i=0; i<nResults(); i++){
			if ((getResult("Ch",i)==cgreen)&&(getResult("Track", i) == track_number[q])){
				time1 = (getResult("Frame",i))*time_step;
				green_time = Array.concat(green_time,time1);
				profile1 = getResult("RawIntDen",i);
				green_profile = Array.concat(green_profile,profile1);
				}
			}

//smooth and normalise green and zero time
        smooth(green_profile);
        if (substring(norm_c, cgreen-1, cgreen) == 1) {
        	normalise(green_profile);
        }
        zero_time(green_time);

//plot green        
        Plot.setColor("green");
        Plot.setLineWidth(1);
        Plot.add("circles", green_time, green_profile);
        Plot.add("lines", green_time, green_profile);
        }

//get bright
if (cbright > 0){

	time1=0;
	profile1=0;
	for (i=0; i<nResults(); i++){
		if ((getResult("Ch",i)==cbright)&&(getResult("Track", i) == track_number[q])){
			time1 = (getResult("Frame",i))*time_step;
			bright_time = Array.concat(bright_time,time1);
			profile1 = getResult("RawIntDen",i);
			bright_profile = Array.concat(bright_profile,profile1);
			}
		}


//smooth and normalise bright and zero time
        smooth(bright_profile);
        if (substring(norm_c, cbright-1, cbright) == 1) {
        	normalise(bright_profile);
        }
        zero_time(bright_time);
        
//plot bright        
        Plot.setColor("darkgray");
        Plot.setLineWidth(1);
        Plot.add("circles", bright_time, bright_profile);
        Plot.add("lines", bright_time, bright_profile);
        }

//get cyan
	if (ccyan > 0){
		time1=0;
		profile1=0;
		for (i=0; i<nResults(); i++){
			if ((getResult("Ch",i)==ccyan)&&(getResult("Track", i) == track_number[q])){
				time1 = (getResult("Frame",i))*time_step;
				cyan_time = Array.concat(cyan_time,time1);
				profile1 = getResult("RawIntDen",i);
				cyan_profile = Array.concat(cyan_profile,profile1);
				}
			}

//smooth and normalise fred and zero time
        smooth(cyan_profile);
        if (substring(norm_c, ccyan-1, ccyan) == 1) {
        	normalise(cyan_profile);
        }
        zero_time(cyan_time);

//plot cyan        
        Plot.setColor("cyan");
        Plot.setLineWidth(1);
        Plot.add("circles", cyan_time, cyan_profile);
        Plot.add("lines", cyan_time, cyan_profile);  
        }

//Get fred
	if (cfred>0){
		time1=0;
		profile1=0;
		for (i=0; i<nResults(); i++){
			if ((getResult("Ch",i)==cfred)&&(getResult("Track", i) == track_number[q])){
				time1 = (getResult("Frame",i))*time_step;
				fred_time = Array.concat(fred_time,time1);
				profile1 = getResult("RawIntDen",i);
				fred_profile = Array.concat(fred_profile,profile1);
				}
			}

//smooth and normalise fred and zero time
        smooth(fred_profile);
        if (substring(norm_c, cfred-1, cfred) == 1) {
        	normalise(fred_profile);
        }
        zero_time(fred_time);

//plot fred        
        Plot.setColor("magenta");
        Plot.setLineWidth(1);
        Plot.add("circles", fred_time, fred_profile);
        
        Plot.add("lines", fred_time, fred_profile);
        }
		
		setBatchMode(false);
		Plot.show;
		Array.print(fred_time);
		Array.print(cyan_profile);
		Array.print(green_profile);
		Array.print(red_profile);
		Array.print(fred_profile);
		Array.print(bright_profile);

//make an image

    	selectWindow("Track"+track_number[q]+" Normalised Intensity Plot");
    	run("Select All");	
		run("Copy");
		run("Close");
		run("Internal Clipboard");
		selectWindow("Clipboard");
		rename("Normalised Intensity Plot Track "+track_number[q]);
        
  }
}

macro "Parse to mdf2 Action Tool - CfffD00D0eD0fD10D14D15D16D17D18D19D1aD1bD1cD1eD1fD20D24D27D2aD2eD2fD30D34D37D3aD3eD3fD40D44D45D46D47D48D49D4aD4bD4cD4eD4fD50D54D57D5aD5eD5fD60D64D67D6aD6eD6fD70D74D75D76D77D78D79D7aD7bD7cD7eD7fD80D84D87D8aD8eD8fD90D94D97D9aD9eD9fDa0Da4Da5Da6Da7Da8Da9DaaDabDacDaeDafDb0Db4Db7DbaDbeDbfDc0Dc4Dc7DcaDceDcfDd0Dd4Dd5Dd6Dd7Dd8Dd9DdaDdbDdcDdeDdfDe0DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC9c9D5bD6bD85D86D95D96C7adD07D61C8adD02C68bD3dCf66D2bD3bC6beD28D29D38D39D55D56D65D66CbcdD01De1C58bDe6CdddD25D26D35D36D58D59D68D69D8bD9bDb5Db6DbbDc5Dc6DcbC7adD03D04D05D06D13D21D23D31D33D41D43D51D53D63D73D83D93Da3Db3Dc3Dd3C9beD12D22D32D42D52D62D72D82D92Da2Db2Dc2Dd2C79cD91Da1Cfd6Db8Db9Dc8Dc9CeeeD8cD9cDbcDccC57aD9dC89cDd1C9bdD11C69cD0aD0bD0cDb1Dc1Cfa7D88D89D98D99CdedD5cD6cC68bD4dDe4De5C79dD08D09D71D81CfccD2cD3cC68cD1dC58bD5dC57bD6dD7dD8dDe7De8De9C8acD0dDedC68cD2dDe3C79cDe2"
{
	convert_to_mdf2();
}

function fucci_measure(image, x, y, dia) {
//measures each channel in a hyperstack and returns in an array

	x1=x-(dia/2);
    y1=y-(dia/2);
	
	run("Set Measurements...", "  mean center integrated stack display redirect=None decimal=4");
	selectWindow(image);
	Stack.getDimensions(width, height, channels, slices, frames);

	for (i=1; i<=channels; i++) {
		Stack.setDisplayMode("color");
		Stack.setChannel(i);
		makeOval(x1, y1, dia, dia);
		run("Measure");	
		}
}

function zero_time (array) {
	length = array.length;
	Array.getStatistics(array, min, max, mean, stdDev);
	for (i=0; i<(length); i++){
		array[i] = array[i]-min;   
	}
	return array;
}

function smooth(array) {

//smooth
	length = array.length;
	for (j=1; j<(length-1); j++){
		array[j] = (array[j-1]+array[j]+array[j+1])/3; // smooth   
	}

	return array;
}

function normalise(array) {

	length = array.length;

//normalise the results
	Array.getStatistics(array, min, max, mean, stdDev);
	for (k=0; k<(length); k++){    
		array[k] = ((array[k]-min)/(max-min)); // normalise 
	}
	return array;
}

function get_s_dist(x, y, xvalues, yvalues) {
//get the shortest distance between x,y and the values in xarray, yarray
	
//check the arrays are the same length
	if (xvalues.length == yvalues.length){	
		shortest = 100000;
		for (i=0; i<xvalues.length; i++) {
			xdist = x - xvalues[i];
			ydist = y - yvalues[i];
			dist1 = sqrt((xdist*xdist)+(ydist*ydist));
			if (dist1 < shortest) {
				shortest = dist1;//*cal;
				com_roi_x = xvalues[i];
				com_roi_y = yvalues[i];
			}
		}
	}
	else {
		exit("The arrays are different lengths are these xy coorinates?");
	}
}


function get_skel_xy(image) {
//return an array of x and y positions for the skeleton of a selection

	selectWindow(image);
//check for a selection
	sel = selectionType();
	if (sel == -1) {exit("There is no line or area selection");}
	if ( sel == 10 || sel == 5 || sel == 6 || sel == 7){run("Line to Area");}

			run("Colors...", "foreground=white background=white selection=cyan");
			getDimensions(width, height, channels, slices, frames);
			newImage("skeleton", "8-bit black", width, height, 1);
			run("Restore Selection");
			run("Cut");
			run("Make Binary");
			run("Skeletonize");
			run("Points from Mask");
			getSelectionCoordinates(xpoints, ypoints);
			if (isOpen("skeleton")) {
				selectWindow("skeleton");
				run("Close");
				}
			selectWindow(image);
			run("Restore Selection");
	}


function convert_to_mdf2(){

//check how many channels there are with min and max values in Ch

chans = newArray("red","green","blue","bright");
nchans = 0;
for (z=0; z<nResults; z++) {
	if (getResult("Ch", z)>nchans) {
		nchans = getResult("Ch", z);
	}
}

//close the log
if (isOpen("Log")) {
	selectWindow("Log");
	run("Close");
}

//get the track numbers in an array to use as the index
	track_number = newArray();
	t_num = 0;

	for (w=0; w<nResults; w++) {
		if ((getResult("Track", w) > t_num)||(getResult("Track", w) < t_num)) {
			t_num = getResult("Track", w);
			track_number = Array.concat(track_number, t_num);	
			}
		}

	print("MTrackJ 1.2.0 Data File");
	print("Assembly 1");


//write to cluster 1

	print("Cluster 1");

	for (i=0; i<track_number.length; i++){
		print("Track "+track_number[i]);
		count=0;
		for (j=0; j<nResults; j++) {
		
			if ((getResult("Track", j) == track_number[i])&&(getResult("Ch", j)==1)){
				count = count+1;

				x = getResult("XM", j);
				y = getResult("YM", j);
				z =	getResult("Slice", j);
				t = getResult("Frame", j);
				c = getResult("Ch", j);

				for (k=0; k<nchans; k++) {
					chans[k]= getResult("RawIntDen", j+k);
					}
				
				//class = getResultString("Class", j);			
				print("Point "+count+" "+x+" "+y+" "+z+" "+t+" "+c+" "+chans[0]+" "+chans[1]+" "+chans[2]+" "+chans[3]);
			
				}
		
			}
		}
	print("End of MTrackJ Data File");
}

function crop_new (image, x, y, size){
//Interactice crop macro
	
//check dimensions
	Stack.getDimensions(width, height, channels, slices, frames);
	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(view);
	swidth = size;
	sheight = size;
	type = bitDepth();
	//print(type);

	if (isOpen("Substack")) { } else {
		newImage("Substack", "8-bit composite-mode", swidth, sheight, channels, 1, frames);
		run(type+"-bit");
		Stack.setChannel(cred);
		run("Red");
		Stack.setChannel(cgreen);
		run("Green");
		Stack.setChannel(ccyan);
		run("Cyan");
		Stack.setChannel(cbright);
		run("Grays");
		Stack.setChannel(cfred);
		run("Magenta");
		Stack.setDisplayMode("composite");
		Stack.setActiveChannels(view);
	}

	setBatchMode(true);

	selectWindow(image);
	Stack.getPosition(channel, slice, frames);

	for (i=1; i<=channels; i++) {
		selectWindow(image);
		Stack.setChannel(i);
		makeRectangle(x-(swidth/2), y-(sheight/2), swidth, sheight);
		run("Copy");
		selectWindow("Substack");
		Stack.setFrame(frames);
		Stack.setChannel(i);
		run("Paste");
	}
	
	selectWindow(image);
	setBatchMode(false);
	}

//Icons used courtesy of: http://www.famfamfam.com/lab/icons/silk/