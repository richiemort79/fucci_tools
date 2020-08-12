//Fucci tools is designed to manaually track Fucci labelled cells in time lapse sequences
//Tracking is manual but the are a number of useful features including creating substack on the fly
//and tracking a reference object at the same time

//Global variables for cell tracking
var gtrack = 1;
var track  = 1;
var number = 1;

//Global variables for mitosis tracking
var is_seed = true;//are we on a seed track or a daughter track?
var daughter = "";//this is either a or b and is appended to gtrack in the results table
var mitosis_frame = "";//remember when the mitosis happened so we can go back to track the second daughter
var mitosis_x = 0; //remember where the mitosis happened so we can go back to track the second daughter
var mitosis_y = 0; //remember where the mitosis happened so we can go back to track the second daughter
var mitosis = "";//string to print to table
var last_line = "";//keep record of last entry in 
var posx = 0;//position you click
var posy = 0;//position you click

//Global calibration variables
var time_step = 10;//this is the image acquisition rate in minutes
var cal = 0.619;//This is the resolution of the image in micron/px

//Global variables for cilia tracking
var shortest = 100000;
var	xpoints = newArray();//the extent of the ROI
var ypoints = newArray();//the extent of the ROI
var dist = 0;

var com_roi_x = 0; 
var com_roi_y = 0; 

//Global variable for results table
var f = "";

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
var view2 = "10000";

//Global variables for the fucci_tools_profile.txt file
var pro_time_step = 10;
var pro_scale = 0.83;
var pro_number_channels = 5;
var	pro_channels = newArray("Cyan","Green","Red","Magenta","Grays");
var pro_channel_order = newArray(1,2,3,4,5);
var pro_view = "01100";
var pro_view2 = "10000";
var pro_norm = "01100";
var pro_crop = 50;
var pro_track = false;
var pro_track_step = 10;

//global variables for measuring cilia
var	c_length = 0;
var	c_f_length = 0;
var	c_straightness = 0;
var	c_kurtosis = 0;
var	c_skewness = 0;
var	c_angle = 0;

//Gloabal variables for intensities
var mean_intensities = newArray(0,0,0,0,0);
var int_densities = newArray(0,0,0,0,0);

macro "Initialize Action Tool - CeefD25D4cD52Dd6CdddD18CfffD00D01D02D03D0cD0dD0eD0fD10D11D1eD1fD20D27D28D2fD30D35D3aD3fD44D4bD53D5cD72D82Da3DacDb4DbbDc0Dc5DcaDcfDd0Dd7DdfDe0De1DeeDefDf0Df1Df2Df3DfcDfdDfeDffCcccDd4CfffD26D39D62D7dD92Db3Dc4Dc6Dd8CdefD22D2dDd2DddCaaaDe7CeffD04D0bD29D37D38D40D45D4fD54D55D64D6cD73D7bD83D8aD8dD99D9cDa8Db0DbfDc9Df4DfbCdefD5bD6aD6bDa9Db7Db8CcdfD14D41Db1CfffD12D1dD21D2eD34D36D43D63D93Dd1DdeDe2DedCdefD05D0aD13D1cD31D3eD50D5fDa0DafDc1DceDe3DecDf5DfaC58cD97CeefD46D47D56D65D84CdeeD9dCbdfDebCbcdDadCeefD49D4aD58D59D5aD67D68D69D6dD7cD8cDa5Da6Db5Db6Dc7Dc8CcefD06D09D60D6fD90D9fDf6Df9C58cD75D76D77D78D79D86D87D88CeefD48D57D66D94D95Da4CddeD24D42Dd5CcdeD3dCbbcD3cDe6C9aaDbdCeeeD2aCbdfD07D08D70D7fD80D8fDf7Df8CaceD96CeffD3bCdddD71CccdDe5CabbDe9C999D7eD8eCdefD8bD9aD9bDaaDabDb9DbaCcdfD1bDe4CbcdDcdDdcCddeD15D51CcdeD1aDa1Dc2Dd3CbbdDaeCaabD9eDdbCeeeDa2CbdeDa7DbeCdddD17D19D81CccdDc3CaabD6eC9aaDccCdefD23D32CcdfD4eCbcdDdaCcdeD2cCaaaDe8CbceD74D85CddeD16D33D61D91CcddD5dDb2CbbbD4dCbcdD5eDeaCdeeDbcDcbDd9CccdD2b"
{

//Must be set up for black background
run("Options...", "iterations=1 count=1 black edm=Overwrite do=Nothing");

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

	print(pro_track+"!!");
	
//Get location of fucci_tools_profile and load the settings
	profile_path = getDirectory("macros");
	get_profile(profile_path);

	//print(pro_track+"!!"pro_track);

//prompt for calibration of image
	Dialog.create("Please set calibration values");
	Dialog.addMessage("Set the scale and time step for the time-lapse");
	Dialog.addNumber("Time Step (min):", pro_time_step);
	Dialog.addNumber("Scale (um/px):", pro_scale);
	Dialog.addMessage("Set the order of the channels in your image (0 = no Channel)");
	Dialog.addNumber("Cyan Channel =", pro_channel_order[0]);
	Dialog.addNumber("Green Channel =", pro_channel_order[1]);
	Dialog.addNumber("Red Channel = ", pro_channel_order[2]);
	Dialog.addNumber("Far-Red =", pro_channel_order[3]);
	Dialog.addNumber("Brightfield =", pro_channel_order[4]);
	Dialog.addString("View while tracking?", pro_view);
	Dialog.addString("View while measuring?", pro_view2);
	Dialog.addString("Normalise?", pro_norm);
	Dialog.addMessage("Define the dimensions of the substack");	
	Dialog.addNumber("Substack crop size", pro_crop);
	Dialog.addMessage("Do you want to track a reference object?");
	Dialog.addCheckbox("Moving ROI", pro_track);
	Dialog.addNumber("Moving ROI time step", pro_track_step);	
	Dialog.show();
	time_step = Dialog.getNumber();
	cal = Dialog.getNumber();
	ccyan = Dialog.getNumber();
	cgreen = Dialog.getNumber();
	cred = Dialog.getNumber();
	cfred = Dialog.getNumber();
	cbright = Dialog.getNumber();
	view = Dialog.getString();
	view2 = Dialog.getString();
	norm_c = Dialog.getString();
	csize = Dialog.getNumber();
	moving_roi = Dialog.getCheckbox();
	m_time_step = Dialog.getNumber();

//set luts dynamically from profile parameters
	for (i=0; i<pro_channel_order.length; i++) {
		if (pro_channel_order[i] > 0) {
			Stack.setChannel(pro_channel_order[i]);
			run(pro_channels[i]);
		}
	}

	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(view);
	run("Remove Overlay");
	run("Colors...", "foreground=white background=white selection=green");
	run("Overlay Options...", "stroke=green width=0 fill=none");
}

macro "Interactive Measure Channel Tool - C8aeD3aD49D4aC37dD7fCfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3eD3fD40D41D42D43D50D51D52D53D58D59D5aD5bD5cD5dD5eD60D61D62D68D6eD70D71D77D78D7eD84D87D88D8eD8fD91D93D96D97D98D9eD9fDa3Da6Db0Db1Db2Db3Db4Db5Db6Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8DdfDe0De1De2De3De4De5De6De7De8DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfdDfeDffC777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C9beD57C888D28D46D55D82C481Dd9C8beD75D94C58dC6a3D69Da8C9beD85Da4C999D27D36D37D38D54D63D64D72D73D74D83C280DaeDfaC48dD3dD4dC8beCac8D9cDcaC593DadC8beD66C69dD47D65C777D45C7aeD5fD6fC270DafDecDfbC48dD4eC9c8DbdDccC592D6cC59dD67C6a4DdaCbc9D7aC380D9dC48dCac9D7bD7cD8aD9aDaaDb9C5a3DebC69eC8b6DbcC170DbfDceDddDdeDedDfcC47dD4fC592D6dC59dC7a3Da7C380DeaCac8D8cC6a3D6aD79D89C69eD76D86D95Da5C8b6DabDbbDcbC9c8DdbC693D6bD99Db7C59eD3cD4cC7a5Da9C381De9C6a4DcdC7aeD3bD48D4bC9b7DbaC491D7dC59eC7a4Dc9C5a4DbeC6aeC8b6D8bD9bC592Dc8C9c8DacC8b5Db8C481D8dC6a4Ddc" {
	
//get dimensions and watch for clicks
    Stack.getDimensions(width, height, channels, slices, frames);		
    Stack.setDisplayMode("composite");
    Stack.setActiveChannels(view);

//some variables
	track = toString(gtrack)+toString(daughter);
    //print(track);
    slice = getSliceNumber();
    
    width = getWidth();
    height = getHeight();

//draws the tracking table
    requires("1.41g");
	title1 = Image+"_Tracking Table";
	title2 = "["+title1+"]";
	f = title2;

	if (isOpen(title1)) {
	}
		else {
			run("Table...", "name="+title2+" width=1000 height=300");
			print(f, "\\Headings: \tImage_ID\tTrack\tSeed\tFrame\tX\tY\tCh1_Mean\tCh2_Mean\tCh3_Mean\tCh4_Mean\tCh5_Mean\tCh1_Int\tCh2_Int\tCh3_Int\tCh4_Int\tCh5_Int\tCilia_COMX\tCilia_COMY\tDistance_to_Cilia_(um)\tLength\tFeret\tStraightness\tKurt\tSkew\tAngle");
		}   
    
    autoUpdate(false);
    getCursorLoc(x, y, z, flags);
    crop_new(Image, x, y, csize);

//get nearest distance to the skeleton
	posx = x;
	posy = y;
	
//measure fucci
    fucci_measure(Image, x, y, 10);

//measure cilia if option is selected in dialog
	//if ((moving_roi == true) && (counter>1) && ((counter/m_time_step)%1)==0) {//checks for an integer value ie divisible by 10
	if (moving_roi == true){
		run("Select None");
		setTool("polyline");
		Stack.setDisplayMode("composite");
		Stack.setActiveChannels(view2);
		run("Hide Overlay");
		waitForUser("Select a Region of Interest", "Please define the Cilia and press OK, or press OK");
		run("Show Overlay");
		measure_cilia();
		get_skel_xy(Image);
		posx = x;
		posy = y;
		get_s_dist(x, y, xpoints, ypoints);
		dist = shortest;
	
	} else {
		status = "";
	}

//return back to measure/track tool
	setTool("Interactive Measure Channel Tool");
    makeOval(x-1,y-1,3,3);
	run("Add Selection...");
	makePoint(x, y);
    wait(300);
    run("Enlarge...", "enlarge=5");
    counter++;
    Stack.getPosition(channel, slice, frame);
    Stack.setPosition(channel, slice, frame+1);
    Stack.setDisplayMode("composite");
    Stack.setActiveChannels(view);

//print results to the tracking table
	print(f,(number++)+"\t"+Image+"\t"+track+"\t"+is_seed+"\t"+(frame)+"\t"+x+"\t"+y+"\t"+mean_intensities[0]+"\t"+mean_intensities[1]+"\t"+mean_intensities[2]+"\t"+mean_intensities[3]+"\t"+mean_intensities[4]+"\t"+int_densities[0]+"\t"+int_densities[1]+"\t"+int_densities[2]+"\t"+int_densities[3]+"\t"+int_densities[4]+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+c_length+"\t"+c_f_length+"\t"+c_straightness+"\t"+c_kurtosis+"\t"+c_skewness+"\t"+c_angle);
	last_line = ""+(frame)+"\t"+x+"\t"+y+"\t"+mean_intensities[0]+"\t"+mean_intensities[1]+"\t"+mean_intensities[2]+"\t"+mean_intensities[3]+"\t"+mean_intensities[4]+"\t"+int_densities[0]+"\t"+int_densities[1]+"\t"+int_densities[2]+"\t"+int_densities[3]+"\t"+int_densities[4]+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+c_length+"\t"+c_f_length+"\t"+c_straightness+"\t"+c_kurtosis+"\t"+c_skewness+"\t"+c_angle;
	  
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
    gtrack++;
	is_seed = true;//are we on a seed track or a daughter track?
 	daughter = "";//this is either a or b and is appended to gtrack in the results table
	mitosis_frame = 0;//remember when the mitosis happened so we can go back to track the second daughter
	mitosis = "";//forget this string
    waitForUser("A new track ("+gtrack+") has been added to the analysis. Please select the tracking button and continue");
    setSlice(1);
	run("Colors...", "foreground=white background=white selection=green");
	run("Overlay Options...", "stroke=green width=0 fill=none");
	run("Remove Overlay");
}


macro "Add Mitosis Action Tool - CfffD00D01D02D03D04D05D06D07D08D09D0aD0cD0dD0eD0fD10D11D12D13D14D15D16D17D1dD1eD1fD20D21D22D23D24D25D2eD2fD30D31D32D33D34D3fD40D41D42D43D44D4fD50D51D52D53D5eD5fD60D69D6aD6dD6eD6fD70D78D79D7aD7cD7dD7eD7fD80D88D89D8aD8cD8dD8eD8fD90D99D9aD9dD9eD9fDa0Da1Da2Da3DaeDafDb0Db1Db2Db3Db4DbfDc0Dc1Dc2Dc3Dc4DcfDd0Dd1Dd2Dd3Dd4Dd5DdeDdfDe0De1De2De3De4De5De6De7DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfcDfdDfeDffC8c8Db7C6b6D27D28CacaDfbC494DaaC9c9D98C7b7D6bD72D76D82D83CbeaD3eC483D63Dd7Dd8C9c8D56D57D66Db9DbaDcaDcbDccC7b7D46D77D86CadaD1cC6a6D67D95DdcC9d9D48C8c7D1bD2cD4dCefeD35C373D61C8c8D2bD3dDc9C7b6D58D65D9bDabDacDbdDc7DcdCadaD4bD4cDceC695DebC9c9DddC7c7D73CcdcDa4C484D94C8a7Db5CbdaD7bC6a6DdbCad9D38D39D49D4aD6cCefeD18D19D1aDeaC372D71C8b8DecC6b6D29Cad9D3aC5a5D36C9c9D47D9cDbbDbcC8c7D5bCbdbDd6C484Dd9CadaD2dD3bD3cD5dCefeDe9C373D62D93Da5Dc6CadaD8bC6a5D5aCac9D68DadC8c7D5cD74D84D85Da6Da7CeeeDc5De8C494D55Da9DdaCbdaD4eC7a7D87C272D81D92C8c8D37D75D96Db8Dc8C594D64CbebD0bC6a5D97Da8Db6CdedD54C9b8D45C7b6D2aCadaDbeC5a5D59CcecD26"
{	
	is_seed = false;//are we on a seed track or a daughter track?

	if (isOpen("Substack")) { 
    	selectWindow("Substack"); 
    	rename("Track_"+track+"_Substack");
    } else {}
	
	if (daughter == "") {
		daughter = "a";//this is either a or b and is appended to gtrack in the results table
		run("Colors...", "foreground=white background=white selection=red");
		run("Overlay Options...", "stroke=red width=0 fill=none");
	} else if (daughter == "a"){
		daughter = "b";
		run("Colors...", "foreground=white background=white selection=yellow");
		run("Overlay Options...", "stroke=yellow width=0 fill=none");
	}
	mslice = getSliceNumber();
	mitosis_frame = mslice;//remember when the mitosis happened so we can go back to track the second daughter
	mitosis_x =	posx;
	mitosis_y = posy;
	waitForUser("A mitosis has been recorded and the track has switched to "+gtrack+daughter);
	//get the last line of the table to use as the first timepoint
	mitosis = last_line;
	print(f,(number++)+"\t"+Image+"\t"+gtrack+daughter+"\t"+is_seed+"\t"+mitosis);
	//need to remember location and get an ROI for that
}

macro "Switch Daughter Action Tool - CcdcD98C696DbcCfffD00D01D02D07D08D0dD0eD0fD10D11D12D17D18D1dD1eD1fD20D21D22D27D28D2dD2eD2fD30D31D32D3dD3eD3fD40D41D42D4dD4eD4fD50D51D52D5dD5eD5fD60D61D62D6dD6eD6fD70D71D72D7dD7eD7fD80D81D82D8dD8eD8fD90D91D92D9dD9eD9fDa0Da1Da7Da8DaeDafDb0DbfDc0Dc1DceDcfDd0Dd1Dd2Dd7Dd8DddDdeDdfDe0De1De2De3De6De7De8De9DecDedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC594D0bD29D39Db2CcdcD6cDadC9c9DabDbbDcaC383D4cCcebD14D15D24D34C8b8D8bC5a4D0aD93CdedDa2CacaD47D48C464DdcCcdcD97C7b7D5aC695De5CdedD63C9c9D8aD9aC474DdbC9c8D1aD1bD2aD84D85D95Da4Da5Db4DcbC6a5Da3CfffD37D38CbdaD66D67C362Db8C7b6D83D86C595D59D75D76D96Db6Dc6Dd4Dd5C9c9D54D94D9bDaaDbaC483D2cC8c8D2bD3aDb5Dc4C5a5D09D26CadaD56D78C474Dc8DccC7b7Db3C695D5cD7bCac9D65D73C584D6aD99C6b5D03D04D05D13D23D33CbebD25D35D44D45C262Da9C6a6D49D5bD64D74C595Dd6C483D3cD87Da6C8c8D3bD4aDc5C5a4D19CadaD68D79C373D88C8a8D7cC484DdaC6b5D06CbdbD55C373Db7C494D0cD1cC6a5D16D43C474DeaDebC8b7D46D53Db1Cad9D7aC585Dc9C252D9cC6a6Dd3C8c8D4bC474D8cDd9C8b7D69D77D89C575DbeC363DacC484D58C363DcdC5a5D36C484Dc7C6a5Dc3C373D6bC585Db9C696De4C7b7D57C6a6Dc2"
{

	if (isOpen("Substack")) { 
    	selectWindow("Substack"); 
    	rename("Track_"+track+"_Substack");
    } else {}
	
	if (daughter == "") {
		daughter = "a";//this is either a or b and is appended to gtrack in the results table
	} else if (daughter == "a"){
		daughter = "b";
	}
	selectWindow(Image);
	run("Colors...", "foreground=white background=white selection=yellow");
	run("Overlay Options...", "stroke=yellow width=0 fill=none");
	setSlice(mitosis_frame);
	makePoint(mitosis_x, mitosis_y);
    //run("Colors...", "foreground=white background=white selection=cyan");
    run("Enlarge...", "enlarge=25");
    //run("Add Selection...");
	
	waitForUser("The track has switched to "+gtrack+daughter);
	print(f,(number++)+"\t"+Image+"\t"+gtrack+daughter+"\t"+is_seed+"\t"+mitosis);
}

macro "Normalised Intensity Plot Action Tool - CfffD5dCf01D38CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D1fD20D24D26D27D2fD30D31D36D3bD3fD40D41D42D43D49D4aD4bD4fD50D51D52D53D59D5aD5fD60D61D62D66D69D6dD6fD70D71D75D76D77D7cD7fD80D81D84D85D86D8cD8dD8fD90D91D94D95D9bD9cD9dD9fDa0Da1Da8DabDacDafDb0Db1Db2Db7Db8DbcDbdDbfDc0Dc1Dc2Dc7Dc8Dc9DcfDd0Dd1Dd2Dd3Dd8Dd9DdaDdbDdfDe0De1De2De3De4DebDecDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC05eD68C9c8D89C26aD6eD7eD8eD9eDaeDbeDceDdeDeeCf66Db3C45bD57C8beD32Da5C6b6D99Da9Ce34D56C37bD18CeccD2bC26bD5eCabaDddC58eD87CefeD2cDcdC493DcbCf33Dd6C26bD1aD1bCbdbD2dCf77D83D92C38dDe5CbceD22C8a8D3cCf56Dd7De9C37cD11D12D13D14D15D16D17CfddD74C66bD45Cf88D65C7aeD58Db6CfeeD3aDc3C483D6bCf22D39De8C16dD97CacaD6cCf66D37C38dDb5CaceDd4C7b6DaaCf55D73Da3Db4CfccDa2C26bD1cD1dD1eD2eD3eD4eCc9bDe6C7aeD67CeefD25C5a4D7aD8aCf33De7C36bD19CcdcD3dCf77D63C38eDc5CeeeD7dDadC8b8D5bDdcCfeeDa4Dc6DeaCfaaD2aC8aeD79CfffD8bDedC484D4cCf12D47C05eD78D88C9c9DbbCf66D82D93Cf44D64CcecD6aC8beDa7C6aeD44D96C4a3DbaCe23D46CcebDb9C48dD33CcdfD21C8b7D9aCf99D54C594DccCbdbDcaC38eD34CacfD98C8b7D7bCeddD28CfaaD72Cf33D55C27dDa6CcdcD4dCf88D48C48eDd5CdefD23CfbbD29C8beD35Ce55Dc4"{

	Dialog.create("Set parameters");
	Dialog.addNumber("Time Step (min):", pro_time_step);
	Dialog.addNumber("Cyan Channel =", pro_channel_order[0]);
	Dialog.addNumber("Green Channel =", pro_channel_order[1]);
	Dialog.addNumber("Red Channel = ", pro_channel_order[2]);
	Dialog.addNumber("Far-Red =", pro_channel_order[3]);
	Dialog.addNumber("Brightfield =", pro_channel_order[4]);
	Dialog.addString("Normalise?", pro_norm);
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
	track_number = list_no_repeats ("Results", "Track");

//loop through each track and make the intensity plot
    for (q=0; q<track_number.length; q++) {
    
    	print("Normalised, zeroed data for track #"+track_number[q]+"(Time,Cyan,Green,Red,F.Red,Bright)");

//Get number of channels
        max_ch = pro_number_channels;

//Extract values and plot on graph
		plot_time = newArray;
		red_profile = newArray();
		green_profile = newArray();
		cyan_profile = newArray();
		bright_profile = newArray();
		fred_profile = newArray();

//Get red, the red channel number is stored in pro_channel_order[2]
	for (i=0; i<nResults(); i++){
		if (getResultString("Track", i) == toString(track_number[q])){	
			plot_time = Array.concat(plot_time, getResult("Frame",i)*time_step);
			if (pro_channel_order[0]>0) {cyan_profile = Array.concat(cyan_profile, getResult("Ch"+pro_channel_order[0]+"_Mean",i));}
			if (pro_channel_order[1]>0) {green_profile = Array.concat(green_profile, getResult("Ch"+pro_channel_order[1]+"_Mean",i));}
			if (pro_channel_order[2]>0) {red_profile = Array.concat(red_profile, getResult("Ch"+pro_channel_order[2]+"_Mean",i));}
			if (pro_channel_order[3]>0) {fred_profile = Array.concat(fred_profile, getResult("Ch"+pro_channel_order[3]+"_Mean",i));}
			if (pro_channel_order[4]>0) {bright_profile = Array.concat(bright_profile, getResult("Ch"+pro_channel_order[4]+"_Mean",i));}
			}
	}
	
//smooth the data for plotting
        if (pro_channel_order[0]>0) {smooth(cyan_profile);}
		if (pro_channel_order[1]>0) {smooth(green_profile);}
		if (pro_channel_order[2]>0) {smooth(red_profile);}
		if (pro_channel_order[3]>0) {smooth(fred_profile);}
		if (pro_channel_order[4]>0) {smooth(bright_profile);}

//normalise the data for plotting    
        if (pro_channel_order[0]>0 && substring(norm_c, 0, 1) == 1) {normalise(cyan_profile);}
		if (pro_channel_order[1]>0 && substring(norm_c, 1, 2) == 1) {normalise(green_profile);}
		if (pro_channel_order[2]>0 && substring(norm_c, 2, 3) == 1) {normalise(red_profile);}
		if (pro_channel_order[3]>0 && substring(norm_c, 3, 4) == 1) {normalise(fred_profile);}
		if (pro_channel_order[4]>0 && substring(norm_c, 4, 5) == 1) {normalise(bright_profile);}

//start all the plots form t=0
        zero_time(plot_time);

//Set up the graph
		Plot.create("Track"+track_number[q]+" Normalised Intensity Plot", "Time (minutes)", "Normalised Integrated Density");
		Plot.setFrameSize(800, 400);
		Array.getStatistics(plot_time, min, max, mean, stdDev);
		Plot.setLimits(0, max, 0, 1);
		Plot.setLineWidth(1);

//Plot the data 
		if (pro_channel_order[0]>0) {
			print("!!!");
			Plot.setColor("cyan");
       		Plot.add("circles", plot_time, cyan_profile);
        	Plot.add("lines", plot_time, cyan_profile);
        	//Plot.update()
			}
		if (pro_channel_order[1]>0) {
			print("!!!");
			Plot.setColor("green");
       		Plot.add("circles", plot_time, green_profile);
        	Plot.add("lines", plot_time, green_profile);
        	//Plot.update()
			}
		if (pro_channel_order[2]>0) {
			print("!!!");
			Plot.setColor("red");
       		Plot.add("circles", plot_time, red_profile);
        	Plot.add("lines", plot_time, red_profile);
        	//Plot.update()
			}
		if (pro_channel_order[3]>0) {
			print("!!!");
			Plot.setColor("magenta");
       		Plot.add("circles", plot_time, fred_profile);
        	Plot.add("lines", plot_time, fred_profile);
        	//Plot.update()
			}
		if (pro_channel_order[4]>0) {
			print("!!!");
			Plot.setColor("gray");
       		Plot.add("circles", plot_time, bright_profile);
        	Plot.add("lines", plot_time, bright_profile);
        	//Plot.update()
			}
		Plot.show;
				
//Print the smoothed normalised data to the log		
		Array.print(plot_time);
		if (pro_channel_order[0]>0) {Array.print(cyan_profile);}
		if (pro_channel_order[1]>0) {Array.print(green_profile);}
		if (pro_channel_order[2]>0) {Array.print(red_profile);}
		if (pro_channel_order[3]>0) {Array.print(fred_profile);}
		if (pro_channel_order[4]>0) {Array.print(bright_profile);}
    }

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
//measures each channel in a hyperstack and updates the global variables
//*************modifiy for varying channel number************************

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
		addToArray(getResult("Mean", 0), mean_intensities, i-1);
		addToArray(getResult("IntDen", 0), int_densities, i-1);
		selectWindow("Results");
		run("Close");
		}
		
	//	ch1_mean = getResult("Mean", 0);
	//	ch2_mean = getResult("Mean", 1);
	//	ch3_mean = getResult("Mean", 2);
	//	ch4_mean = getResult("Mean", 3);
	//	ch5_mean = getResult("Mean", 4);
	//	ch1_int = getResult("IntDen", 0);
	//	ch2_int = getResult("IntDen", 1);
	//	ch3_int = getResult("IntDen", 2);
	//	ch4_int = getResult("IntDen", 3);
	//	ch5_int = getResult("IntDen", 4);	
	//	selectWindow("Results");
	//	run("Close");
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
	if (sel == -1) {}//exit("There is no line or area selection");}
	if ( sel == 10 || sel == 5 || sel == 6 || sel == 7){run("Line to Area");}

			//run("Colors...", "foreground=white background=white selection=cyan");
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

function measure_cilia() {

	sel = selectionType();
	if (sel == -1) {
		//exit("There is no line or area selection");
		c_length = 0;
		c_f_length = 0;
		c_straightness = 0;
		c_kurtosis = 0;
		c_skewness = 0;
		c_angle = 0;
		} else {
		run("Set Measurements...", "display redirect=None decimal=4");
		run("Measure");
		c_length = getResult("Length",0);
		selectWindow("Results");
		run("Close");
		run("Line to Area");
		run("Set Measurements...", "shape feret's skewness kurtosis display redirect=None decimal=4");
		run("Measure");
		c_f_length = getResult("Feret", 0);
		c_straightness = c_f_length/c_length;
		c_kurtosis = getResult("Kurt", 0);
		c_skewness = getResult("Skew", 0);
		c_angle = getResult("FeretAngle", 0);
		run("Restore Selection");
		selectWindow("Results");
		run("Close");
	}
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
		//newImage("Substack", "8-bit composite-mode", swidth, sheight, pro_number_channels, 1, frames);
		newImage("Substack", "8-bit composite-mode", swidth, sheight, channels, slices, frames);
		run(type+"-bit");

//set luts dynamically from profile parameters
		for (i=0; i<pro_channel_order.length; i++) {
			if (pro_channel_order[i] > 0) {
				Stack.setChannel(pro_channel_order[i]);
				run(pro_channels[i]);
			}
		}

	Stack.setDisplayMode("composite");
	Stack.setActiveChannels(view);
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

function get_profile(profile_path) {
//extracts the parameters needed for fucci_tools form fucci_tools_profile.txt if present in /Macros
	profile = profile_path+"fucci_tools_profile.txt";
	
		if (File.exists(profile) == "0") {
			print("No fucci_tools_profile.txt in your /Macros directory using defaults.............");
		} else {

//open the file as a string
			filestring = File.openAsString(profile); 
			row = split(filestring, "\n");
			
//get the values form the file
			pro_time_step = substring(row[0],16,lengthOf(row[0]));
			pro_scale = substring(row[1],12,lengthOf(row[1]));
			pro_number_channels = substring(row[2],22,lengthOf(row[2]));
			
			channels = substring(row[3],15,lengthOf(row[3]));
			channels1 = split(channels,",");
			
			//make order array
			for (i=0; i<lengthOf(channels1); i++) {
				addToArray(channels1[i],pro_channels,i);
			}	
			
			order = substring(row[4],20,lengthOf(row[4]));
			//make order array
			for (i=0; i<lengthOf(order); i++) {
				addToArray(substring(order,i,i+1),pro_channel_order,i);
			}	
			
			pro_view = substring(row[5],11,lengthOf(row[5]));
			pro_norm = substring(row[6],11,lengthOf(row[6]));
			pro_crop = substring(row[7],11,lengthOf(row[7]));
			pro_track = substring(row[8],12,lengthOf(row[8]));
			pro_track_step = substring(row[9],17,lengthOf(row[9]));
			pro_view2 = substring(row[10],12,lengthOf(row[10]));
	}
}

function addToArray(value, array, position) {
//allows one to update existing values in an array
//adds the value to the array at the specified position, expanding if necessary - returns the modified array
//From Richard Wheeler - http://www.richardwheeler.net/contentpages/text.php?gallery=ImageJ_Macros&file=Array_Tools&type=ijm
    
    if (position < lengthOf(array)) {
        array[position]=value;
    } else {
        temparray = newArray(position+1);
        for (i=0; i<lengthOf(array); i++) {
            temparray[i]=array[i];
        }
        temparray[position]=value;
        array=temparray;
    }
    return array;
}

function list_no_repeats (table, heading) {
//Returns an array of the entries in a column without repeats to use as an index

//Check whether the table exists
	if (isOpen(table)) {

//get the entries in the column without repeats
		no_repeats = newArray(getResultString(heading, 0));

		for (i=0; i<nResults; i++) {
			occurence = getResultString(heading, i);
			for (j=0; j<no_repeats.length; j++) {
				if (occurence != no_repeats[j]) {
					flag = 0;
				} else {
						flag = 1;
					}
				}
			
			if (flag == 0) {
				occurence = getResultString(heading, i);
				no_repeats = Array.concat(no_repeats, occurence);	
			}
		}
	} else {
		Dialog.createNonBlocking("Error");
		Dialog.addMessage("No table with the title "+table+" found.");
		Dialog.show();
	}
	return no_repeats;
}

//Icons used courtesy of: http://www.famfamfam.com/lab/icons/silk/