//Fucci tools is designed to manaually track Fucci labelled cells in time lapse sequences
//Tracking is manual but the are a number of useful features including creating substack on the fly
//and tracking a reference object at the same time

//Global variables for cell tracking
var gtrack = 1;
var track  = 1;
var number = 1;

//Global variables for mitosis tracking
var is_mother = true;//are we on a mother track or a daughter track?
var daughter = "";//this is either a or b and is appended to gtrack in the results table
var mitosis_frame = "";//remember when the mitosis happened so we can go back to track the second daughter
var mitosis_x = 0; //remember where the mitosis happened so we can go back to track the second daughter
var mitosis_y = 0; //remember where the mitosis happened so we can go back to track the second daughter
var mitosis = "";//string to print to table
//var last_line = "";//keep record of last entry in 
var posx = 0;//position you click
var posy = 0;//position you click

//Global calibration variables
var time_step = 10;//this is the image acquisition rate in minutes
var cal = 0.619;//This is the resolution of the image in micron/px
var dia = 10;//This is the diameter of the ROI where the intensity measurements are made in the nucleus

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
var pro_norm = "11111";
var pro_crop = 50;
var pro_track = false;
var pro_track_step = 10;
var	pro_diameter = 10;

//global variables for measuring cilia
var	c_length = 0;
var	c_f_length = 0;
var	c_straightness = 0;
var	c_kurtosis = 0;
var	c_skewness = 0;
var	c_angle = 0;

//Gloabal variables for intensities
var mean_intensities = newArray(0,0,0,0,0);
//var int_densities = newArray(0,0,0,0,0);

//Variables for plot dialog
var check_labels = newArray("Cyan","Green","Red","Magenta","Grays", "Cilia Length");
var check_defaults = newArray(false,true,true,false,false, true);
var check_plot = newArray(0,0,0,0,0,0);

//Variables for plot types
var type_labels = newArray("Single","Montage","Interpolated Mean","Interpolated Cilia Length","Interpolated Fucci with Cilia Overlay");
var type_defaults = newArray(false,true,false,false,false);
var type_plot = newArray(0,0,0,0,0);

macro "Initialize Action Tool - CeefD25D4cD52Dd6CdddD18CfffD00D01D02D03D0cD0dD0eD0fD10D11D1eD1fD20D27D28D2fD30D35D3aD3fD44D4bD53D5cD72D82Da3DacDb4DbbDc0Dc5DcaDcfDd0Dd7DdfDe0De1DeeDefDf0Df1Df2Df3DfcDfdDfeDffCcccDd4CfffD26D39D62D7dD92Db3Dc4Dc6Dd8CdefD22D2dDd2DddCaaaDe7CeffD04D0bD29D37D38D40D45D4fD54D55D64D6cD73D7bD83D8aD8dD99D9cDa8Db0DbfDc9Df4DfbCdefD5bD6aD6bDa9Db7Db8CcdfD14D41Db1CfffD12D1dD21D2eD34D36D43D63D93Dd1DdeDe2DedCdefD05D0aD13D1cD31D3eD50D5fDa0DafDc1DceDe3DecDf5DfaC58cD97CeefD46D47D56D65D84CdeeD9dCbdfDebCbcdDadCeefD49D4aD58D59D5aD67D68D69D6dD7cD8cDa5Da6Db5Db6Dc7Dc8CcefD06D09D60D6fD90D9fDf6Df9C58cD75D76D77D78D79D86D87D88CeefD48D57D66D94D95Da4CddeD24D42Dd5CcdeD3dCbbcD3cDe6C9aaDbdCeeeD2aCbdfD07D08D70D7fD80D8fDf7Df8CaceD96CeffD3bCdddD71CccdDe5CabbDe9C999D7eD8eCdefD8bD9aD9bDaaDabDb9DbaCcdfD1bDe4CbcdDcdDdcCddeD15D51CcdeD1aDa1Dc2Dd3CbbdDaeCaabD9eDdbCeeeDa2CbdeDa7DbeCdddD17D19D81CccdDc3CaabD6eC9aaDccCdefD23D32CcdfD4eCbcdDdaCcdeD2cCaaaDe8CbceD74D85CddeD16D33D61D91CcddD5dDb2CbbbD4dCbcdD5eDeaCdeeDbcDcbDd9CccdD2b"
{
//check there is an image open and if not exit
	image_list = getList("image.titles");
	if (image_list.length == 0) {
    exit("There are no images open");
	}

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

	//print(pro_track+"!!");
	
//Get location of fucci_tools_profile and load the settings
	profile_path = getDirectory("macros");
	get_profile(profile_path);
	//print(pro_diameter);
	
	//print(pro_track+"!!"pro_track);

//prompt for calibration of image
	Dialog.create("Please define your acquisition parameters*");
	Dialog.addMessage("Set the scale and time step for your dataset");
	Dialog.addNumber("Time Step (min):", pro_time_step);
	Dialog.addNumber("Scale (um/px):", pro_scale);
	Dialog.addNumber("Diameter of nucleus ROI (px):", pro_diameter);
	Dialog.addMessage("Set the order of the channels in your dataset (0 = not used)");
	Dialog.addNumber("Cyan Channel =", pro_channel_order[0]);
	Dialog.addNumber("Green Channel =", pro_channel_order[1]);
	Dialog.addNumber("Red Channel = ", pro_channel_order[2]);
	Dialog.addNumber("Far-Red =", pro_channel_order[3]);
	Dialog.addNumber("Brightfield =", pro_channel_order[4]);
	Dialog.addMessage("Which channels would you like to view while you track?");
	Dialog.addString("View while tracking?", pro_view);
	//Dialog.addString("Normalise?", pro_norm);
	Dialog.addMessage("Define the dimensions of the substack");	
	Dialog.addNumber("Substack crop size", pro_crop);
	Dialog.addMessage("Would you like to track a cilia? How often?");
	Dialog.addCheckbox("Track Cilia", pro_track);
	Dialog.addNumber("Track Cilia time step", pro_track_step);
	Dialog.addMessage("Which channels would you like to view while measuring the cilia?");
	Dialog.addString("View while measuring?", pro_view2);
	Dialog.addMessage("*It is advised to use a fucci_tools_profile.txt config file");	
	Dialog.show();
	time_step = Dialog.getNumber();
	cal = Dialog.getNumber();
	dia = Dialog.getNumber();
	ccyan = Dialog.getNumber();
	cgreen = Dialog.getNumber();
	cred = Dialog.getNumber();
	cfred = Dialog.getNumber();
	cbright = Dialog.getNumber();
	view = Dialog.getString();	
	norm_c = pro_norm;
	csize = Dialog.getNumber();
	moving_roi = Dialog.getCheckbox();
	m_time_step = Dialog.getNumber();
	view2 = Dialog.getString();

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

macro "Interactive Measure Tool - C8aeD3aD49D4aC37dD7fCfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3eD3fD40D41D42D43D50D51D52D53D58D59D5aD5bD5cD5dD5eD60D61D62D68D6eD70D71D77D78D7eD84D87D88D8eD8fD91D93D96D97D98D9eD9fDa3Da6Db0Db1Db2Db3Db4Db5Db6Dc0Dc1Dc2Dc3Dc4Dc5Dc6Dc7Dd0Dd1Dd2Dd3Dd4Dd5Dd6Dd7Dd8DdfDe0De1De2De3De4De5De6De7De8DeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfdDfeDffC777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C9beD57C888D28D46D55D82C481Dd9C8beD75D94C58dC6a3D69Da8C9beD85Da4C999D27D36D37D38D54D63D64D72D73D74D83C280DaeDfaC48dD3dD4dC8beCac8D9cDcaC593DadC8beD66C69dD47D65C777D45C7aeD5fD6fC270DafDecDfbC48dD4eC9c8DbdDccC592D6cC59dD67C6a4DdaCbc9D7aC380D9dC48dCac9D7bD7cD8aD9aDaaDb9C5a3DebC69eC8b6DbcC170DbfDceDddDdeDedDfcC47dD4fC592D6dC59dC7a3Da7C380DeaCac8D8cC6a3D6aD79D89C69eD76D86D95Da5C8b6DabDbbDcbC9c8DdbC693D6bD99Db7C59eD3cD4cC7a5Da9C381De9C6a4DcdC7aeD3bD48D4bC9b7DbaC491D7dC59eC7a4Dc9C5a4DbeC6aeC8b6D8bD9bC592Dc8C9c8DacC8b5Db8C481D8dC6a4Ddc" {
	
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
			print(f, "\\Headings: \tImage_ID\tTrack\tMother?\tFrame\tX\tY\tCh1_Mean\tCh2_Mean\tCh3_Mean\tCh4_Mean\tCh5_Mean\tCilia_COMX\tCilia_COMY\tDistance_to_Cilia_(um)\tLength\tFeret\tStraightness\tKurt\tSkew\tAngle");
		}   
    
    autoUpdate(false);
    getCursorLoc(x, y, z, flags);
    crop_new(Image, x, y, csize);

//get nearest distance to the skeleton
	posx = x;
	posy = y;
	
//measure fucci
    fucci_measure(Image, x, y, dia);

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
	setTool("Interactive Measure Tool");
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
	print(f,(number++)+"\t"+Image+"\t"+track+"\t"+is_mother+"\t"+(frame)+"\t"+x+"\t"+y+"\t"+mean_intensities[0]+"\t"+mean_intensities[1]+"\t"+mean_intensities[2]+"\t"+mean_intensities[3]+"\t"+mean_intensities[4]+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+c_length+"\t"+c_f_length+"\t"+c_straightness+"\t"+c_kurtosis+"\t"+c_skewness+"\t"+c_angle);
	//last_line = ""+(frame)+"\t"+x+"\t"+y+"\t"+mean_intensities[0]+"\t"+mean_intensities[1]+"\t"+mean_intensities[2]+"\t"+mean_intensities[3]+"\t"+mean_intensities[4]+"\t"+int_densities[0]+"\t"+int_densities[1]+"\t"+int_densities[2]+"\t"+int_densities[3]+"\t"+int_densities[4]+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+c_length+"\t"+c_f_length+"\t"+c_straightness+"\t"+c_kurtosis+"\t"+c_skewness+"\t"+c_angle;
	  
}


macro "Add Track Action Tool - CfffD00D01D02D03D04D05D06D07D0bD0cD0dD0eD0fD10D11D12D13D14D15D16D17D19D1bD1cD1dD1eD1fD20D21D22D23D24D25D26D2bD2cD2dD2eD2fD30D31D32D33D34D39D3aD3bD3cD3dD3eD3fD40D41D42D43D50D51D52D53D60D61D62D68D69D6aD70D71D77D78D79D7aD7bD7cD7dD84D87D88D89D8aD8bD8cD8dD8eD8fD91D93D94D97D98D99D9fDa3Da4Da7Da8Db0Db1Db2Db3Db4Db8DbcDc0Dc1Dc2Dc3Dc4DcbDccDcdDd0Dd1Dd2Dd3Dd4DdcDe0De1De2De3De4De5Df0Df1Df2Df3Df4Df5DffC37dD7fC777D45C69dD47D65C777D08D09D0aD18D1aD29D2aD35D44D56D80D81D90D92Da0Da1Da2C48dD6bDb7Dc7Dd6Cbd9DabDbaDbbDceDecC8beD5eD75C582DaeDeaDeeC48dD4dD6cDc8Dd7Dd8De6De7Df6C999D27D36D37D38D54D63D64D72D73D74D83C7aeD48D4bC8b6DadDbeDdbDdeDebDedC59dDb5Dc5C9beD57C361D9dC48dD4eDf7C888D28D46D55D82C69eDa5C58dD6dDc6Dd5Cbd9DacC684Dc9C8aeD49D4aD58D59C8b6DdaC59dD67C9beD5bD5cD5dD85C47dD4fD7eDe8Df8Df9C69eD76D86Da6C8beD5aD66C473De9C7aeD5fD6fC8beD95C473D9cC6aeD6eCdebDcaC8a6DaaC59eD96Db6C59eD4cC695Da9Db9C584D9bDd9C8b6DbdDddC685D9a"
{
    gtrack++;
    counter=1;
    if (isOpen("Substack")) { 
    	selectWindow("Substack"); 
    	rename("Track_"+(gtrack-1)+daughter+"_Substack");
    } else {}
    
    //gtrack++;
	is_mother = true;//are we on a mother track or a daughter track?
 	daughter = "";//this is either a or b and is appended to gtrack in the results table
	mitosis_frame = 0;//remember when the mitosis happened so we can go back to track the second daughter
	mitosis = "";//forget this string
    //waitForUser("A new track ("+gtrack+") has been added to the analysis. Please select the tracking button and continue");
    setSlice(1);
	run("Colors...", "foreground=white background=white selection=green");
	run("Overlay Options...", "stroke=green width=0 fill=none");
	run("Remove Overlay");
	waitForUser("A new track ("+gtrack+") has been added to the analysis. If it exists the substack has been renamed as Track_"+gtrack-1+"_Substack. Please select the tracking button and continue");
}


macro "Add Mitosis Action Tool - CfffD00D01D02D03D04D05D06D07D08D09D0aD0cD0dD0eD0fD10D11D12D13D14D15D16D17D1dD1eD1fD20D21D22D23D24D25D2eD2fD30D31D32D33D34D3fD40D41D42D43D44D4fD50D51D52D53D5eD5fD60D69D6aD6dD6eD6fD70D78D79D7aD7cD7dD7eD7fD80D88D89D8aD8cD8dD8eD8fD90D99D9aD9dD9eD9fDa0Da1Da2Da3DaeDafDb0Db1Db2Db3Db4DbfDc0Dc1Dc2Dc3Dc4DcfDd0Dd1Dd2Dd3Dd4Dd5DdeDdfDe0De1De2De3De4De5De6De7DedDeeDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfcDfdDfeDffC8c8Db7C6b6D27D28CacaDfbC494DaaC9c9D98C7b7D6bD72D76D82D83CbeaD3eC483D63Dd7Dd8C9c8D56D57D66Db9DbaDcaDcbDccC7b7D46D77D86CadaD1cC6a6D67D95DdcC9d9D48C8c7D1bD2cD4dCefeD35C373D61C8c8D2bD3dDc9C7b6D58D65D9bDabDacDbdDc7DcdCadaD4bD4cDceC695DebC9c9DddC7c7D73CcdcDa4C484D94C8a7Db5CbdaD7bC6a6DdbCad9D38D39D49D4aD6cCefeD18D19D1aDeaC372D71C8b8DecC6b6D29Cad9D3aC5a5D36C9c9D47D9cDbbDbcC8c7D5bCbdbDd6C484Dd9CadaD2dD3bD3cD5dCefeDe9C373D62D93Da5Dc6CadaD8bC6a5D5aCac9D68DadC8c7D5cD74D84D85Da6Da7CeeeDc5De8C494D55Da9DdaCbdaD4eC7a7D87C272D81D92C8c8D37D75D96Db8Dc8C594D64CbebD0bC6a5D97Da8Db6CdedD54C9b8D45C7b6D2aCadaDbeC5a5D59CcecD26"
{	
	is_mother = false;//are we on a mother track or a daughter track?

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
	//mitosis = last_line;
	//print(f,(number++)+"\t"+Image+"\t"+gtrack+daughter+"\t"+is_seed+"\t"+mitosis);
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
	setSlice(mitosis_frame+1);
	makePoint(mitosis_x, mitosis_y);
    //run("Colors...", "foreground=white background=white selection=cyan");
    run("Enlarge...", "enlarge=25");
    //run("Add Selection...");
	
	waitForUser("The track has switched to "+gtrack+daughter);
	//print(f,(number++)+"\t"+Image+"\t"+gtrack+daughter+"\t"+is_seed+"\t"+mitosis);
}

macro "Normalised Intensity Plot Action Tool - CfffD5dCf01D38CfffD00D01D02D03D04D05D06D07D08D09D0aD0bD0cD0dD0eD0fD10D1fD20D24D26D27D2fD30D31D36D3bD3fD40D41D42D43D49D4aD4bD4fD50D51D52D53D59D5aD5fD60D61D62D66D69D6dD6fD70D71D75D76D77D7cD7fD80D81D84D85D86D8cD8dD8fD90D91D94D95D9bD9cD9dD9fDa0Da1Da8DabDacDafDb0Db1Db2Db7Db8DbcDbdDbfDc0Dc1Dc2Dc7Dc8Dc9DcfDd0Dd1Dd2Dd3Dd8Dd9DdaDdbDdfDe0De1De2De3De4DebDecDefDf0Df1Df2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeDffC05eD68C9c8D89C26aD6eD7eD8eD9eDaeDbeDceDdeDeeCf66Db3C45bD57C8beD32Da5C6b6D99Da9Ce34D56C37bD18CeccD2bC26bD5eCabaDddC58eD87CefeD2cDcdC493DcbCf33Dd6C26bD1aD1bCbdbD2dCf77D83D92C38dDe5CbceD22C8a8D3cCf56Dd7De9C37cD11D12D13D14D15D16D17CfddD74C66bD45Cf88D65C7aeD58Db6CfeeD3aDc3C483D6bCf22D39De8C16dD97CacaD6cCf66D37C38dDb5CaceDd4C7b6DaaCf55D73Da3Db4CfccDa2C26bD1cD1dD1eD2eD3eD4eCc9bDe6C7aeD67CeefD25C5a4D7aD8aCf33De7C36bD19CcdcD3dCf77D63C38eDc5CeeeD7dDadC8b8D5bDdcCfeeDa4Dc6DeaCfaaD2aC8aeD79CfffD8bDedC484D4cCf12D47C05eD78D88C9c9DbbCf66D82D93Cf44D64CcecD6aC8beDa7C6aeD44D96C4a3DbaCe23D46CcebDb9C48dD33CcdfD21C8b7D9aCf99D54C594DccCbdbDcaC38eD34CacfD98C8b7D7bCeddD28CfaaD72Cf33D55C27dDa6CcdcD4dCf88D48C48eDd5CdefD23CfbbD29C8beD35Ce55Dc4"{
{
	//Get location of fucci_tools_profile and load the settings
	profile_path = getDirectory("macros");
	get_profile(profile_path);
	
	Dialog.create("Plotting parameters");
	Dialog.addNumber("Time Step (min):", pro_time_step);
	Dialog.addNumber("Cyan Channel =", pro_channel_order[0]);
	Dialog.addNumber("Green Channel =", pro_channel_order[1]);
	Dialog.addNumber("Red Channel = ", pro_channel_order[2]);
	Dialog.addNumber("Far-Red =", pro_channel_order[3]);
	Dialog.addNumber("Brightfield =", pro_channel_order[4]);
	//Dialog.addString("Normalise?", pro_norm);
	Dialog.addCheckbox("Print to Log?", false);
	Dialog.addMessage("Choose the tracks you wish to plot:");
	Dialog.addCheckbox("Plot mothers?", false);
	Dialog.addCheckbox("Plot daugters?", true);
	Dialog.addMessage("Choose the features you wish to plot:");
  	Dialog.addCheckboxGroup(3,2,check_labels,check_defaults);
  	Dialog.addMessage("Choose the plot types you wish to see:");
  	Dialog.addCheckboxGroup(5,1,type_labels,type_defaults);
	Dialog.show();
	time_step = Dialog.getNumber();
	ccyan = Dialog.getNumber();
	cgreen = Dialog.getNumber();
	cred = Dialog.getNumber();
	cfred = Dialog.getNumber();
	cbright = Dialog.getNumber();
	norm_c = pro_norm;//Dialog.getString();
	log_p = Dialog.getCheckbox();
	plot_m = Dialog.getCheckbox();
	plot_d = Dialog.getCheckbox();

	for (i=0; i<check_defaults.length; i++) {
		 doplot = Dialog.getCheckbox();
		 addToArray(doplot, check_plot, i); 
	}
	for (i=0; i<type_defaults.length; i++) {
		 plot_type = Dialog.getCheckbox();
		 addToArray(plot_type, type_plot, i); 
	}
    
//if the results table is empty prompt for a results table
	if (isOpen("Results")) {}

	else {
		waitForUser("There is no Results table open please select a tracking table or press cancel");
		table = getInfo("window.name");
		selectWindow(table);
		tdir = getDirectory("temp");
		saveAs("Text", tdir+"Results.xls");
		run("Close");
		open(tdir+"Results.xls");
	}

//START WITH INDIVIDUAL PLOTS
	if (type_plot[0]==true || type_plot[1]==true) {

		setBatchMode(true);

//add a daughter column to the results table
		for (i=0; i<nResults; i++) {
			if (getResult("Mother?", i) == 0) {
				setResult("Daughter?", i, 1);		
			}
		}

//get the track numbers in an array to use as the index - skips mother track or daughter track if selected
 		if (plot_m == true && plot_d == true) {
			track_number = list_no_repeats ("Results", "Track");//plot all
 		} else if (plot_m == false && plot_d == true) {
			track_number = list_no_repeats_skip ("Results", "Track", "Mother?");//skip mothers
 		} else if (plot_m == true && plot_d == false){
			track_number = list_no_repeats_skip ("Results", "Track", "Daughter?");//skip daughter
 		} else if (plot_m == false && plot_d == false){
 			exit("No tracks selected for plotting");
 			}

//loop through each track and make the intensity plot for the individual plots
		for (q=0; q<track_number.length; q++) {
				
//print the normalised data to the log if log-p = true
    		if (log_p == true) {
    			print("Normalised, zeroed data for track #"+track_number[q]+"(Time,Cyan,Green,Red,F.Red,Bright, C. Length)");
    		}

//Get number of channels
    	    max_ch = pro_number_channels;

//Extract values and plot on graph
			plot_time = newArray;
			red_profile = newArray();
			green_profile = newArray();
			cyan_profile = newArray();
			bright_profile = newArray();
			fred_profile = newArray();
			cilia_length = newArray();

//Get the data into arrays a track at a time to work on - channel number is stored in pro_channel_order[2]
		for (i=0; i<nResults(); i++){
			if (getResultString("Track", i) == toString(track_number[q])){	
				image_id = getResultString("Image_ID",i);
				plot_time = Array.concat(plot_time, getResult("Frame",i)*time_step);
				if (pro_channel_order[0]>0) {cyan_profile = Array.concat(cyan_profile, getResult("Ch"+pro_channel_order[0]+"_Mean",i));} else {cyan_profile = Array.concat(cyan_profile, 0);}
				if (pro_channel_order[1]>0) {green_profile = Array.concat(green_profile, getResult("Ch"+pro_channel_order[1]+"_Mean",i));} else {green_profile = Array.concat(green_profile, 0);}
				if (pro_channel_order[2]>0) {red_profile = Array.concat(red_profile, getResult("Ch"+pro_channel_order[2]+"_Mean",i));} else {red_profile = Array.concat(red_profile, 0);}
				if (pro_channel_order[3]>0) {fred_profile = Array.concat(fred_profile, getResult("Ch"+pro_channel_order[3]+"_Mean",i));} else {fred_profile = Array.concat(fred_profile, 0);}
				if (pro_channel_order[4]>0) {bright_profile = Array.concat(bright_profile, getResult("Ch"+pro_channel_order[4]+"_Mean",i));} else {bright_profile = Array.concat(bright_profile, 0);}
				if (check_plot[5]==1) {cilia_length = Array.concat(cilia_length, getResult("Length",i));}		
				}
		}
	
//smooth the data for plotting
			if (pro_channel_order[0]>0) {smooth(cyan_profile);}
			if (pro_channel_order[1]>0) {smooth(green_profile);}
			if (pro_channel_order[2]>0) {smooth(red_profile);}
			if (pro_channel_order[3]>0) {smooth(fred_profile);}
			if (pro_channel_order[4]>0) {smooth(bright_profile);}
			if (check_plot[5]==1) {smooth(cilia_length);}

//normalise the data for plotting    
    	   	if (pro_channel_order[0] == 0) {} else if (substring(norm_c, 0, 1) == 1) {normalise(cyan_profile);}
			if (pro_channel_order[1] == 0) {} else if (substring(norm_c, 1, 2) == 1) {normalise(green_profile);}
			if (pro_channel_order[2] == 0) {} else if (substring(norm_c, 2, 3) == 1) {normalise(red_profile);}
			if (pro_channel_order[3] == 0) {} else if (substring(norm_c, 3, 4) == 1) {normalise(fred_profile);}
			if (check_plot[5]==1) {normalise(cilia_length);}

//start all the plots from t=0
        	zero_time(plot_time);

//Set up the graph
			Plot.create(image_id+" Track"+track_number[q]+" Normalised Intensity Plot", "Time (minutes)", "Normalised Intensity");
			Plot.setFrameSize(400, 200);
			Array.getStatistics(plot_time, min, max, mean, stdDev);
			Plot.setLimits(0, max, 0, 1);
			Plot.setLineWidth(1);
			Plot.setBackgroundColor("Gray");

//Plot the data 
			if (pro_channel_order[0]>0 && check_plot[0]==1) {
				Plot.setColor("cyan");
       			Plot.add("circles", plot_time, cyan_profile);
        		Plot.add("lines", plot_time, cyan_profile);
        		//Plot.update()
				}
			if (pro_channel_order[1]>0 && check_plot[1]==1) {
				Plot.setColor("green");
       			Plot.add("circles", plot_time, green_profile);
        		Plot.add("lines", plot_time, green_profile);
        	//Plot.update()
				}
			if (pro_channel_order[2]>0 && check_plot[2]==1) {
				Plot.setColor("red");
       			Plot.add("circles", plot_time, red_profile);
   		     	Plot.add("lines", plot_time, red_profile);
        	//Plot.update()
				}
			if (pro_channel_order[3]>0 && check_plot[3]==1) {
				Plot.setColor("magenta");
      	 		Plot.add("circles", plot_time, fred_profile);
        		Plot.add("lines", plot_time, fred_profile);
        		//Plot.update()
				}
			if (pro_channel_order[4]>0 && check_plot[4]==1) {
				Plot.setColor("gray");
    	   		Plot.add("circles", plot_time, bright_profile);
        		Plot.add("lines", plot_time, bright_profile);
        		//Plot.update()
				}
			if (check_plot[5]==1) {
				Plot.setColor("cyan");
				Plot.setLineWidth(1);
   	    		Plot.add("circles", plot_time, cilia_length);
 		       	Plot.add("lines", plot_time, cilia_length);
        	//Plot.update()
				}
			Plot.show;
			run("Set... ", "zoom=100"); 
				
//Print the smoothed normalised data to the log	if log_p == true	
			if (log_p == true) { 
				Array.print(plot_time);
				if (pro_channel_order[0]>0) {Array.print(cyan_profile);}
				if (pro_channel_order[1]>0) {Array.print(green_profile);}
				if (pro_channel_order[2]>0) {Array.print(red_profile);}
				if (pro_channel_order[3]>0) {Array.print(fred_profile);}
				if (pro_channel_order[4]>0) {Array.print(bright_profile);}
				if (check_plot[5]==1) {Array.print(cilia_length);}
			}

//make an image

    		selectWindow(image_id+" Track"+toString(track_number[q])+" Normalised Intensity Plot");
   		 	run("Select All");	
			run("Copy");
			run("Close");
			run("Internal Clipboard");
			selectWindow("Clipboard");
			rename("Normalised Intensity Plot Track "+track_number[q]);

			}		
		run("Images to Stack", "name=[Individual Plots Stack] title=[] use");
		Stack.getDimensions(width, height, channels, slices, frames);
		setBatchMode(false);	
		
		if (type_plot[1] == true) {
			run("Canvas Size...", "width=483 height=275 position=Top-Left");
			ncols = round((slices/4)+1);
			nrows = 4;
			run("Make Montage...", "columns=&ncols rows=&nrows scale=1 border=0 label keep");
			selectWindow("Montage");
			rename("Individual Plots Montage");	
			}

		if (type_plot[0] == false) {	
			selectWindow("Individual Plots Stack");
			run("Close");
		
		}
	}


//THEN INTERPOLATED PLOTS

//make the arrays and results table for the interpolated plots
	if (type_plot[2]==true) {
		setBatchMode(true);

//get the track numbers in an array to use as the index - skips mother track or daughter track if selected
 		if (plot_m == true && plot_d == true) {
			track_number = list_no_repeats ("Results", "Track");//plot all
 		} else if (plot_m == false && plot_d == true) {
			track_number = list_no_repeats_skip ("Results", "Track", "Mother?");//skip mothers
 		} else if (plot_m == true && plot_d == false){
			track_number = list_no_repeats_skip ("Results", "Track", "Daughter?");//skip daughter
 		} else if (plot_m == false && plot_d == false){
 			exit("No tracks selected for plotting");
 			}
		
		//interpolated data will have 100 interpolated time points
		int_plot_time = newArray("0");
		
		for (i=1; i<100; i++) {
			int_plot_time = Array.concat(int_plot_time, 1+int_plot_time[i-1]);
		}

//draws the interpolated tracking table
    	requires("1.41g");
		title1 = "Normalised Interpolated Data";
		title2 = "["+title1+"]";
		g = title2;

		if (isOpen(g)) {
			selectWindow(g);
			run("Close");
		}
			else {
				run("Table...", "name="+title2+" width=1000 height=300");
				print(g, "\\Headings: \tImage_ID\tTrack\tInt_Time\tCyan\tGreen\tRed\tFar_Red\tBright\tCilia_Length");
			}  

//loop through each track and resample the data for 100 time steps
		for (q=0; q<track_number.length; q++) {

			//Get number of channels
    	    max_ch = pro_number_channels;

//Extract values and plot on graph
			plot_time = newArray;
			red_profile = newArray();
			green_profile = newArray();
			cyan_profile = newArray();
			bright_profile = newArray();
			fred_profile = newArray();
			cilia_length = newArray();

//Get the data into arrays a track at a time to work on - channel number is stored in pro_channel_order[2]
		for (i=0; i<nResults(); i++){
			if (getResultString("Track", i) == toString(track_number[q])){	
				image_id = getResultString("Image_ID",i);
				plot_time = Array.concat(plot_time, getResult("Frame",i)*time_step);
				if (pro_channel_order[0]>0) {cyan_profile = Array.concat(cyan_profile, getResult("Ch"+pro_channel_order[0]+"_Mean",i));} else {cyan_profile = Array.concat(cyan_profile, 0);}
				if (pro_channel_order[1]>0) {green_profile = Array.concat(green_profile, getResult("Ch"+pro_channel_order[1]+"_Mean",i));} else {green_profile = Array.concat(green_profile, 0);}
				if (pro_channel_order[2]>0) {red_profile = Array.concat(red_profile, getResult("Ch"+pro_channel_order[2]+"_Mean",i));} else {red_profile = Array.concat(red_profile, 0);}
				if (pro_channel_order[3]>0) {fred_profile = Array.concat(fred_profile, getResult("Ch"+pro_channel_order[3]+"_Mean",i));} else {fred_profile = Array.concat(fred_profile, 0);}
				if (pro_channel_order[4]>0) {bright_profile = Array.concat(bright_profile, getResult("Ch"+pro_channel_order[4]+"_Mean",i));} else {bright_profile = Array.concat(bright_profile, 0);}
				cilia_length = Array.concat(cilia_length, getResult("Length",i));	
				}
		}
	
//smooth the data for plotting
			if (pro_channel_order[0]>0) {smooth(cyan_profile);}
			if (pro_channel_order[1]>0) {smooth(green_profile);}
			if (pro_channel_order[2]>0) {smooth(red_profile);}
			if (pro_channel_order[3]>0) {smooth(fred_profile);}
			if (pro_channel_order[4]>0) {smooth(bright_profile);}
			smooth(cilia_length);

//normalise the data for plotting    
    	   	if (pro_channel_order[0] == 0) {} else if (substring(norm_c, 0, 1) == 1) {normalise(cyan_profile);}
			if (pro_channel_order[1] == 0) {} else if (substring(norm_c, 1, 2) == 1) {normalise(green_profile);}
			if (pro_channel_order[2] == 0) {} else if (substring(norm_c, 2, 3) == 1) {normalise(red_profile);}
			if (pro_channel_order[3] == 0) {} else if (substring(norm_c, 3, 4) == 1) {normalise(fred_profile);}
			normalise(cilia_length);

//resample the data
			cyan_profile = Array.resample(cyan_profile,100);
			green_profile = Array.resample(green_profile,100);
			red_profile = Array.resample(red_profile,100);
			fred_profile = Array.resample(fred_profile,100);
			bright_profile = Array.resample(bright_profile,100);
			cilia_length = Array.resample(cilia_length,100);
		
//write the data to the new table
			for (i=0; i<int_plot_time.length; i++) {
				print(g,(number++)+"\t"+image_id+"\t"+track_number[q]+"\t"+int_plot_time[i]+"\t"+cyan_profile[i]+"\t"+green_profile[i]+"\t"+red_profile[i]+"\t"+fred_profile[i]+"\t"+bright_profile[i]+"\t"+cilia_length[i]);	
			}
		}

//open THE INTERPOLATED DATA as a results table
		selectWindow("Results");
		IJ.renameResults("Results2");
		selectWindow("Normalised Interpolated Data");
		tdir = getDirectory("temp");
		saveAs("Text", tdir+"Results.xls");
		run("Close");
		open(tdir+"Results.xls");

//get the mean data for each channel into an array
		if (pro_channel_order[0]>0) {
			cyan_profile = mean_index(track_number,"Track", "Cyan", 100);
			cyan_profile = normalise(cyan_profile);
			}
		if (pro_channel_order[1]>0) {
			green_profile = mean_index(track_number,"Track","Green", 100);
			green_profile = normalise(green_profile);
			}
		if (pro_channel_order[2]>0) {
			red_profile = mean_index(track_number,"Track", "Red", 100);
			red_profile = normalise(red_profile);
			}
		if (pro_channel_order[3]>0) {
			fred_profile = mean_index(track_number,"Track","Far_Red", 100);
			fred_profile = normalise(fred_profile);
			}
		if (pro_channel_order[4]>0) {
			bright_profile = mean_index(track_number,"Track","Bright", 100);
			bright_profile = normalise(bright_profile);
			}
		if (check_plot[5]==1) {
			cilia_length = mean_index(track_number,"Track","Cilia_Length", 100);
			cilia_length = normalise(cilia_length);
			}

//get the confidence interval for each channel into an array
		if (pro_channel_order[0]>0) {cyan_profile_ci = conf_index(track_number,"Track","Cyan", 100);}
		if (pro_channel_order[1]>0) {green_profile_ci = conf_index(track_number,"Track","Green", 100);}
		if (pro_channel_order[2]>0) {red_profile_ci = conf_index(track_number,"Track","Red", 100);}
		if (pro_channel_order[3]>0) {fred_profile_ci = conf_index(track_number,"Track","Far_Red", 100);}
		if (pro_channel_order[4]>0) {bright_profile_ci = conf_index(track_number,"Track","Bright", 100);}
		if (check_plot[5]==1) {cilia_length_ci = conf_index(track_number,"Track","Cilia_Length", 100);}

//time is just 0-100
		plot_time = newArray("0");
		for (i=1; i<100; i++) {
			plot_time = Array.concat(plot_time, 1+plot_time[i-1]);
		}

//plot the data - Set up the graph
		Plot.create("Interpolated Plot", "Time (% total)", "Normalised Intensity");
		Plot.setFrameSize(400, 200);
		Array.getStatistics(plot_time, min, max, mean, stdDev);
		Plot.setLimits(0, max, 0, 1);
		Plot.setLineWidth(1);
		Plot.setBackgroundColor("gray");

//Plot the data 
		if (pro_channel_order[0]>0 && check_plot[0]==1) {
			Plot.setColor("cyan");
       		Plot.add("circles", plot_time, cyan_profile);
        	Plot.add("lines", plot_time, cyan_profile);
        	Plot.add("error bars", plot_time, cyan_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[1]>0 && check_plot[1]==1) {
			Plot.setColor("green");
       		Plot.add("circles", plot_time, green_profile);
        	Plot.add("lines", plot_time, green_profile);
        	Plot.add("error bars", plot_time, green_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[2]>0 && check_plot[2]==1) {
			Plot.setColor("red");
       		Plot.add("circles", plot_time, red_profile);
        	Plot.add("lines", plot_time, red_profile);
        	Plot.add("error bars", plot_time, red_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[3]>0 && check_plot[3]==1) {
			Plot.setColor("magenta");
       		Plot.add("circles", plot_time, fred_profile);
        	Plot.add("lines", plot_time, fred_profile);
        	Plot.add("error bars", plot_time, fred_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[4]>0 && check_plot[4]==1) {
			Plot.setColor("gray");
       		Plot.add("circles", plot_time, bright_profile);
        	Plot.add("lines", plot_time, bright_profile);
        	Plot.add("error bars", plot_time, bright_profile_ci);
        	//Plot.update()
			}
		if (check_plot[5]==1) {
			Plot.setColor("cyan");
			Plot.setLineWidth(1);
       		Plot.add("circles", plot_time, cilia_length);
        	Plot.add("lines", plot_time, cilia_length);
        	Plot.add("error bars", plot_time, cilia_length_ci);
        	//Plot.update()
			}
		Plot.show;
		run("Set... ", "zoom=100"); 

		selectWindow("Results");
		IJ.renameResults("Normalised Interpolated Data");
		selectWindow("Results2");
		IJ.renameResults("Results");
	setBatchMode(false);	
}
		
//THEN INTERPOLATED CILIA PLOTS
	if (type_plot[3] == true && check_plot[5]==1){
			
		setBatchMode(true);

//get the track numbers in an array to use as the index - skips mother track or daughter track if selected
 		if (plot_m == true && plot_d == true) {
			track_number = list_no_repeats ("Results", "Track");//plot all
 		} else if (plot_m == false && plot_d == true) {
			track_number = list_no_repeats_skip ("Results", "Track", "Mother?");//skip mothers
 		} else if (plot_m == true && plot_d == false){
			track_number = list_no_repeats_skip ("Results", "Track", "Daughter?");//skip daughter
 		} else if (plot_m == false && plot_d == false){
 			exit("No tracks selected for plotting");
 			}
	
//draws the interpolated cilia length table
    	requires("1.41g");
		title1 = "Interpolated Cilia Length";
		title2 = "["+title1+"]";
		h = title2;

		if (isOpen(h)) {
			selectWindow(h);
			run("Close");
		}
			else {
				run("Table...", "name="+title2+" width=1000 height=300");
				print(h, "\\Headings: \tImage_ID\tTrack\tCilia_Time\tCilia_Length");
			}  

		//interpolated data will have 100 interpolated time points
		cilia_plot_time = newArray("0");
		
		for (i=1; i<100; i++) {
			cilia_plot_time = Array.concat(cilia_plot_time, 1+cilia_plot_time[i-1]);
		}
		
//loop through each track and resample the data for 100 time steps
		for (q=0; q<track_number.length; q++) {


			cilia_length = newArray();

			for (i=0; i<nResults(); i++){
				if (getResultString("Track", i) == toString(track_number[q])){	
					image_id = getResultString("Image_ID",i);
					cilia_length = Array.concat(cilia_length, getResult("Length",i));}		
				}

			//Array.print(cilia_length);


//trim and resample the cilia length data and write to new table if plot_type[2] = true
				
			cilia_length = trim_resample_array(cilia_length,100);
	//		Array.print(cilia_length);



//normalise and smooth cilia length

			cilia_length = normalise(cilia_length);
		//	Array.print(cilia_length);

//write the data to the new table
					for (i=0; i<cilia_plot_time.length; i++) {
						print(h,(number++)+"\t"+image_id+"\t"+track_number[q]+"\t"+cilia_plot_time[i]+"\t"+cilia_length[i]);
					}	


		}

//open THE INTERPOLATED CILIA LENGTHS AS A RESULTS TABLE
		selectWindow("Results");
		IJ.renameResults("Results2");
		selectWindow("Interpolated Cilia Length");
		tdir = getDirectory("temp");
		saveAs("Text", tdir+"Results.xls");
		run("Close");
		open(tdir+"Results.xls");

//get the data - time is just 0-100
	plot_time = newArray("0");
		for (i=1; i<100; i++) {
			plot_time = Array.concat(plot_time, 1+plot_time[i-1]);
		}
		
//get the data
		if (check_plot[5]==1) {
			cilia_length = mean_index(track_number,"Track", "Cilia_Length", 100);
			cilia_length = normalise(cilia_length);
			}
		if (check_plot[5]==1) {cilia_length_ci = conf_index(track_number,"Track","Cilia_Length", 100);}

//plot the data
		//Set up the graph
		Plot.create("Interpolated Cilia Length", "Time (% of total)", "Normalised Cilia Length");
		Plot.setFrameSize(400, 200);
		Array.getStatistics(plot_time, min, max, mean, stdDev);
		Plot.setLimits(0, max, 0, 1);
		Plot.setLineWidth(1);
		Plot.setBackgroundColor("Gray");

//Plot the data 
		if (check_plot[5]==1) {
			Plot.setColor("cyan");
			Plot.setLineWidth(1);
       		Plot.add("circles", plot_time, cilia_length);
        	Plot.add("lines", plot_time, cilia_length);
        	Plot.add("error bars", plot_time, cilia_length_ci);
			}
			Plot.show;
			run("Set... ", "zoom=100"); 
			
//Tidy up the tables
		selectWindow("Results");
		IJ.renameResults("Interpolated Cilia Length");
		selectWindow("Results2");
		IJ.renameResults("Results");
		setBatchMode(false);
	}

//THEN INTERPOLATED PLOT WITH OVERLAY CILIA

//make the arrays and results table for the interpolated plots
	if (type_plot[4]==true) {
		
		setBatchMode(true);

//get the track numbers in an array to use as the index - skips mother track or daughter track if selected
 		if (plot_m == true && plot_d == true) {
			track_number = list_no_repeats ("Results", "Track");//plot all
 		} else if (plot_m == false && plot_d == true) {
			track_number = list_no_repeats_skip ("Results", "Track", "Mother?");//skip mothers
 		} else if (plot_m == true && plot_d == false){
			track_number = list_no_repeats_skip ("Results", "Track", "Daughter?");//skip daughter
 		} else if (plot_m == false && plot_d == false){
 			exit("No tracks selected for plotting");
 			}
		
//interpolated data will have 100 interpolated time points
		int_plot_time = newArray("0");
		
		for (i=1; i<100; i++) {
			int_plot_time = Array.concat(int_plot_time, 1+int_plot_time[i-1]);
		}

//Array.print(int_plot_time);
//draws the interpolated tracking table
    	requires("1.41g");
		title1 = "Normalised Interpolated Data";
		title2 = "["+title1+"]";
		g = title2;

		if (isOpen(g)) {
			selectWindow(g);
			run("Close");
		}
			else {
				run("Table...", "name="+title2+" width=1000 height=300");
				print(g, "\\Headings: \tImage_ID\tTrack\tInt_Time\tCyan\tGreen\tRed\tFar_Red\tBright\tCilia_Length");
			}  

//get the start and end of each cilia in an array to match track_number

	cilia_start = newArray();
	cilia_end = newArray();


//loop through each track and resample the data for 100 time steps
		for (q=0; q<track_number.length; q++) {

			//Get number of channels
    	    max_ch = pro_number_channels;

//Extract values and plot on graph
			plot_time = newArray;
			red_profile = newArray();
			green_profile = newArray();
			cyan_profile = newArray();
			bright_profile = newArray();
			fred_profile = newArray();
			cilia_length = newArray();

//Get the data into arrays a track at a time to work on - channel number is stored in pro_channel_order[2]
		for (i=0; i<nResults(); i++){
			if (getResultString("Track", i) == toString(track_number[q])){	
				image_id = getResultString("Image_ID",i);
				plot_time = Array.concat(plot_time, getResult("Frame",i)*time_step);
				if (pro_channel_order[0]>0) {cyan_profile = Array.concat(cyan_profile, getResult("Ch"+pro_channel_order[0]+"_Mean",i));} else {cyan_profile = Array.concat(cyan_profile, 0);}
				if (pro_channel_order[1]>0) {green_profile = Array.concat(green_profile, getResult("Ch"+pro_channel_order[1]+"_Mean",i));} else {green_profile = Array.concat(green_profile, 0);}
				if (pro_channel_order[2]>0) {red_profile = Array.concat(red_profile, getResult("Ch"+pro_channel_order[2]+"_Mean",i));} else {red_profile = Array.concat(red_profile, 0);}
				if (pro_channel_order[3]>0) {fred_profile = Array.concat(fred_profile, getResult("Ch"+pro_channel_order[3]+"_Mean",i));} else {fred_profile = Array.concat(fred_profile, 0);}
				if (pro_channel_order[4]>0) {bright_profile = Array.concat(bright_profile, getResult("Ch"+pro_channel_order[4]+"_Mean",i));} else {bright_profile = Array.concat(bright_profile, 0);}
				if (check_plot[5]==1) {cilia_length = Array.concat(cilia_length, getResult("Length",i));}		
				}
		}

		
//smooth the data for plotting
			if (pro_channel_order[0]>0) {smooth(cyan_profile);}
			if (pro_channel_order[1]>0) {smooth(green_profile);}
			if (pro_channel_order[2]>0) {smooth(red_profile);}
			if (pro_channel_order[3]>0) {smooth(fred_profile);}
			if (pro_channel_order[4]>0) {smooth(bright_profile);}
			if (check_plot[5]==1) {smooth(cilia_length);}

//normalise the data for plotting    
    	   	if (pro_channel_order[0] == 0) {} else if (substring(norm_c, 0, 1) == 1) {normalise(cyan_profile);}
			if (pro_channel_order[1] == 0) {} else if (substring(norm_c, 1, 2) == 1) {normalise(green_profile);}
			if (pro_channel_order[2] == 0) {} else if (substring(norm_c, 2, 3) == 1) {normalise(red_profile);}
			if (pro_channel_order[3] == 0) {} else if (substring(norm_c, 3, 4) == 1) {normalise(fred_profile);}
			if (check_plot[5]==1) {normalise(cilia_length);}

//resample the data
			cyan_profile = Array.resample(cyan_profile,100);
			green_profile = Array.resample(green_profile,100);
			red_profile = Array.resample(red_profile,100);
			fred_profile = Array.resample(fred_profile,100);
			bright_profile = Array.resample(bright_profile,100);
			cilia_length = Array.resample(cilia_length,100);
		
//write the data to the new table
			for (i=0; i<int_plot_time.length; i++) {
				print(g,(number++)+"\t"+image_id+"\t"+track_number[q]+"\t"+int_plot_time[i]+"\t"+cyan_profile[i]+"\t"+green_profile[i]+"\t"+red_profile[i]+"\t"+fred_profile[i]+"\t"+bright_profile[i]+"\t"+cilia_length[i]);	
			}

		c_start = get_start(cilia_length);		
		c_end = get_end(cilia_length);
		cilia_start = Array.concat(cilia_start, int_plot_time[c_start]);		
		cilia_end = Array.concat(cilia_end, int_plot_time[c_end]);
			
		}

//open THE INTERPOLATED DATA as a results table
		selectWindow("Results");
		IJ.renameResults("Results2");
		selectWindow("Normalised Interpolated Data");
		tdir = getDirectory("temp");
		saveAs("Text", tdir+"Results.xls");
		run("Close");
		open(tdir+"Results.xls");

//get the new track list as some tracks may have been thrown out
	track_number = list_no_repeats ("Results", "Track");

//get the mean data for each channel into an array
		if (pro_channel_order[0]>0) {
			cyan_profile = mean_index(track_number,"Track", "Cyan", 100);
			cyan_profile = normalise(cyan_profile);
			}
		if (pro_channel_order[1]>0) {
			green_profile = mean_index(track_number,"Track","Green", 100);
			green_profile = normalise(green_profile);
			}
		if (pro_channel_order[2]>0) {
			red_profile = mean_index(track_number,"Track", "Red", 100);
			red_profile = normalise(red_profile);
			}
		if (pro_channel_order[3]>0) {
			fred_profile = mean_index(track_number,"Track","Far_Red", 100);
			fred_profile = normalise(fred_profile);
			}
		if (pro_channel_order[4]>0) {
			bright_profile = mean_index(track_number,"Track","Bright", 100);
			bright_profile = normalise(bright_profile);
			}
		if (check_plot[5]==1) {
			cilia_length = mean_index(track_number,"Track","Cilia_Length", 100);
			cilia_length = normalise(cilia_length);
			}

//get the confidence interval for each channel into an array
		if (pro_channel_order[0]>0) {cyan_profile_ci = conf_index(track_number,"Track","Cyan", 100);}
		if (pro_channel_order[1]>0) {green_profile_ci = conf_index(track_number,"Track","Green", 100);}
		if (pro_channel_order[2]>0) {red_profile_ci = conf_index(track_number,"Track","Red", 100);}
		if (pro_channel_order[3]>0) {fred_profile_ci = conf_index(track_number,"Track","Far_Red", 100);}
		if (pro_channel_order[4]>0) {bright_profile_ci = conf_index(track_number,"Track","Bright", 100);}
		if (check_plot[5]==1) {cilia_length_ci = conf_index(track_number,"Track","Cilia_Length", 100);}

//time is just 0-100
		plot_time = newArray("0");
		for (i=1; i<100; i++) {
			plot_time = Array.concat(plot_time, 1+plot_time[i-1]);
		}

//plot the data - Set up the graph
		Plot.create("Interpolated Plot and Cilia Overlay", "Time (% of total)", "Normalised Intensity");
		Plot.setFrameSize(400, 200);
		Array.getStatistics(plot_time, min, max, mean, stdDev);
		Plot.setLimits(0, max, 0, 1);
		Plot.setLineWidth(1);
		Plot.setBackgroundColor("gray");

//Plot the data 
		if (pro_channel_order[0]>0 && check_plot[0]==1) {
			Plot.setColor("cyan");
       		Plot.add("circles", plot_time, cyan_profile);
        	Plot.add("lines", plot_time, cyan_profile);
        	Plot.add("error bars", plot_time, cyan_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[1]>0 && check_plot[1]==1) {
			Plot.setColor("green");
       		Plot.add("circles", plot_time, green_profile);
        	Plot.add("lines", plot_time, green_profile);
        	Plot.add("error bars", plot_time, green_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[2]>0 && check_plot[2]==1) {
			Plot.setColor("red");
       		Plot.add("circles", plot_time, red_profile);
        	Plot.add("lines", plot_time, red_profile);
        	Plot.add("error bars", plot_time, red_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[3]>0 && check_plot[3]==1) {
			Plot.setColor("magenta");
       		Plot.add("circles", plot_time, fred_profile);
        	Plot.add("lines", plot_time, fred_profile);
        	Plot.add("error bars", plot_time, fred_profile_ci);
        	//Plot.update()
			}
		if (pro_channel_order[4]>0 && check_plot[4]==1) {
			Plot.setColor("gray");
       		Plot.add("circles", plot_time, bright_profile);
        	Plot.add("lines", plot_time, bright_profile);
        	Plot.add("error bars", plot_time, bright_profile_ci);
        	//Plot.update()
			}
		if (check_plot[5]==1) {

			y_point = 0;
			y_points = newArray();
			for (i=0; i<track_number.length; i++) {
				
			y_point = y_point + 1/(track_number.length+1);
			y_points = Array.concat(y_points,y_point);
			Plot.setColor("cyan");
			Plot.setLineWidth(1);
       		Plot.drawLine(cilia_start[i], y_point, cilia_end[i], y_point);
       		
			}
			Plot.add("circle", cilia_start, y_points);
			Plot.add("circle", cilia_end, y_points);
		}
		Plot.show;
		run("Set... ", "zoom=100"); 

		selectWindow("Results");
		IJ.renameResults("Normalised Interpolated Data");
		selectWindow("Results2");
		IJ.renameResults("Results");
	}
	setBatchMode(false);
	
}

macro "Reanalyze Action Tool - Cad8DccCd54D9bCed8D88C676DdfC7adDd2Cbc5D99CefeD1cD1eDa1Db1Dc1Dd1De1C666D07D08D09D0aD0bD0cD0dD2fD3fD4fD5fD6fD7fD8fD9fDa0DafDb0DbfDc0DcfDd0DefDf2Df3Df4Df5Df6Df7Df8Df9DfaDfbDfcDfdDfeCdd8D37Caa5D7cCfe9D68C8c6D5bCbceDa7Ccc4D73CfffD11D15D16D17D18D19D1aD21D61D81D91C665D02D03D04D05D06D0eD1fD20D30D40D50D60D70D80D90C79cDd3Cf55D54Cff8D64C8b6D7bC9bdDd7Cac8DbdCfffD12D13D14D1bD31D41D51D71CcdaDb8Cd85D8cCffaD26D48C8c7DdbCdedD4eD5eD6eD7eD8eD9eDceDe7De8DeaDebDecDeeCcd7Dd8C565D01D10De0Df1Cad8D4cD6aCb85D79Cee8D23D36D47D58C8bdDa3C9c7D5cCefeD1dCcd9D2bCb96DdaCeeaD29CcddDa8Cdd5D75D98C8adDb5Cf66D66Cee9D25D38D49C9beDa5Dc4Cac8D5dDddCdedD2eD3eDe3De4De5De6DedCd96Dd9CffbD2aC9c7D3bCdd7Dc9Cad8DcdCe64D55Cee8D52C8adD92Dd4C9c7D7aCcd9Da9Caa7D9dCff9D22D24D46CaceDa4Dc6Ccc5D72C7adDc3Cf65D43Cff8D62C9beD94C9c8D4bDdcCdecDbeCe85DcaCffaD28Cdd7D33D57D86Cbd9D4dCc85D7dC9beDb4Cbc7D59Ccd9D84Cca7D6dCdedDe2Cdd6D74CabbD83Ce76DadCabeDd6Cbc8D8dCea5DbaCdedDdeCed7D76Cac8D3dCe54D9cCfd8D44C8adDb2Cbb7D97Cde8DaaCaa6D9aCff9D27Ccc5Db9C79dDb3Ce55D78CabdDb7Dc7Cd95D53Cb85DbbC9bdDc5C9c7D3cD6bDbcCbdaD2dCba7D8bC9bdD95Cf76D42Ce96D65Ced7D56Cad8D6cCd74DabCee8D34D45C8aeDc2C9c7D5aCdd8D39C9b7DcbCcc5D85C8adD93Dd5Ce75D77CdecDe9Ce96D67Cad9D2cCd76D89C9beDa2Cdd9Dc8Cca7DacCbdfDa6Cdd6D87CbccD96Cf77D8aCaceDb6Ceb6D32CeedDaeCdd7D35C9c7D69Cbe9D4aCde9D3aCaceD82Cee7D63"
{
//re run an analysis using the x,y coordinates in the results table e.g. either with tweaked parameters or on a processed version of the original data
//requires an open results table and the corresponding image
//first run intialise and tweak parameters or load a processed dataset

//check the imageIds match
	testID = getTitle();
	dataID = getResultString("Image_ID", 1);
	
	if (testID == dataID) {}
		else {
			choice = getBoolean("The Image name does not match the ImageID in the results table, continue?");
			}
	
	if (choice == 0) {exit("Please load matching datasets");} 
		else {
			if (choice == 1) {}
		}


//get dimensions
    Stack.getDimensions(width, height, channels, slices, frames);		
    Stack.setDisplayMode("composite");
    Stack.setActiveChannels(11111);

//draws the tracking table
    requires("1.41g");
	title1 = Image+"_Tracking Table";
	title2 = "["+title1+"]";
	f = title2;

	if (isOpen(title1)) {
	}
		else {
			run("Table...", "name="+title2+" width=1000 height=300");
			print(f, "\\Headings: \tImage_ID\tTrack\tMother?\tFrame\tX\tY\tCh1_Mean\tCh2_Mean\tCh3_Mean\tCh4_Mean\tCh5_Mean\tCilia_COMX\tCilia_COMY\tDistance_to_Cilia_(um)\tLength\tFeret\tStraightness\tKurt\tSkew\tAngle");
		}   

	setBatchMode(true);
//get the x and y values into two arrays
	old_x_values = newArray();
	old_y_values = newArray();
	old_frames = newArray();
	for (i=0; i<nResults; i++) {
		x = getResult("X", i);	
		y = getResult("Y", i);
		fr = getResult("Frame", i);
		old_x_values = Array.concat(old_x_values, x);
		old_y_values = Array.concat(old_y_values, y);
		old_frames = Array.concat(old_frames, fr);
	}

//save and close the results table
	dir = File.directory();
	selectWindow("Results");
	saveAs("Results", dir+"Results.csv");

//get the mean intensities into arrays
	c_one_means = newArray();
	c_two_means = newArray();
	c_three_means = newArray();
	c_four_means = newArray();
	c_five_means = newArray();
	
//loop through x and y and remeasure the channels
	for (i=0; i<old_x_values.length; i++) {
		x = old_x_values[i];	
		y = old_y_values[i];
		
//measure fucci
		setSlice(old_frames[i]);
    	fucci_measure(Image, x, y, dia);
    	c_one_means = Array.concat(c_one_means, mean_intensities[0]);
		c_two_means = Array.concat(c_two_means, mean_intensities[1]);
		c_three_means = Array.concat(c_three_means, mean_intensities[2]);
		c_four_means = Array.concat(c_four_means, mean_intensities[3]);
		c_five_means = Array.concat(c_five_means, mean_intensities[4]);
	}
	setBatchMode(false);

//reopen the Results table
	open(dir+"Results.csv");
	
//loop through the results table and make a new table from above	
	for (i=0; i<nResults; i++) {
//print results to the tracking table
		//print(f,(number++)+"\t"+(getResult("Image_ID", i))+"\t"+(getResult("Track",i))+"\t"+(getResult("Mother?",i))+"\t"+(getResult("Frame",i))+"\t"+(old_x_values[i])+"\t"+(old_y_values[i])+"\t"+(c_one_means[i])+"\t"+(c_two_means[i])+"\t"+(c_three_means[i])+"\t"+(c_four_means[i])+"\t"+(c_five_means[i])+"\t"+(getResult("Cilia_COMX",i))+"\t"+(getResult("Cilia_COMY",i))+"\t"+(getResult("Distance_to_Cilia_(um))",i)+"\t"+(getResult("Length",i))+"\t"+(getResult("Feret",i))+"\t"+(getResult("Straightness",i))+"\t"+(getResult("Kurt",i))+"\t"+(getResult("Skew",i))+"\t"+(getResult("Angle",i)));
	//	print(f,(number++)+"\t"+Image+"\t"+track+"\t"+is_mother+"\t"+(frame)+"\t"+x+"\t"+y+"\t"+mean_intensities[0]+"\t"+mean_intensities[1]+"\t"+mean_intensities[2]+"\t"+mean_intensities[3]+"\t"+mean_intensities[4]+"\t"+com_roi_x+"\t"+com_roi_y+"\t"+dist+"\t"+c_length+"\t"+c_f_length+"\t"+c_straightness+"\t"+c_kurtosis+"\t"+c_skewness+"\t"+c_angle);
	
	print(f,
    number++ + "\t" + 
    getResultString("Image_ID", i) + "\t" + 
    getResultString("Track", i) + "\t" + 
    getResult("Mother?", i) + "\t" + 
    getResult("Frame", i) + "\t" + 
    old_x_values[i] + "\t" + 
    old_y_values[i] + "\t" + 
    c_one_means[i] + "\t" + 
    c_two_means[i] + "\t" + 
    c_three_means[i] + "\t" + 
    c_four_means[i] + "\t" + 
    c_five_means[i] + "\t" + 
    getResult("Cilia_COMX", i) + "\t" + 
    getResult("Cilia_COMY", i) + "\t" + 
    getResult("Distance_to_Cilia_(um)", i) + "\t" + 
    getResult("Length", i) + "\t" + 
    getResult("Feret", i) + "\t" + 
    getResult("Straightness", i) + "\t" + 
    getResult("Kurt", i) + "\t" + 
    getResult("Skew", i) + "\t" + 
    getResult("Angle", i));
	
	
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
		//addToArray(getResult("IntDen", 0), int_densities, i-1);
		selectWindow("Results");
		run("Close");
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

//get the track numbers in an array to use as the index
	track_number = list_no_repeats ("Results", "Track");
	mothers_and_daughters = newArray();
	
	for (i = 0; i < track_number.length; i++) {
		track_string = track_number[i];
		len = track_string.length;
		key = substring(track_string,len-1);
	
		if (key == "a" || key== "b") {
			mothers_and_daughters = Array.concat(mothers_and_daughters,0);
			} else {
			mothers_and_daughters = Array.concat(mothers_and_daughters,1);
			}
	}
	
//close the log
	if (isOpen("Log")) {
		selectWindow("Log");
		run("Close");
	}
	
	print("MTrackJ 1.2.0 Data File");
	print("Assembly 1");

//write the mothers to cluster 1

	print("Cluster 1 (Mothers)");

	for (i=0; i<track_number.length; i++){
		if (mothers_and_daughters[i]==1) {
			print("Track "+i+1);
		}
		count=0;
		for (j=0; j<nResults; j++) {
			
			if ((getResultString("Track", j) == track_number[i])&&(getResult("Mother?", j)==1)){
				count = count+1;

				x = getResult("X", j);
				y = getResult("Y", j);
				z =	1;
				t = getResult("Frame", j);
				c = 1;
				ch1 = getResult("Ch1_Mean", j);
				ch2 = getResult("Ch2_Mean", j);
				ch3 = getResult("Ch3_Mean", j);
				ch4 = getResult("Ch4_Mean", j);
				ch5 = getResult("Ch5_Mean", j);
						
				print("Point "+count+" "+x+" "+y+" "+z+" "+t+" "+c+" "+ch1+" "+ch2+" "+ch3+" "+ch4);
				}
			}
		}
		
//write the daughters to cluster 2

	print("Cluster 2 (Daughters)");

	for (i=0; i<track_number.length; i++){
		if (mothers_and_daughters[i]==0) {
			print("Track "+i+1);
		}
		count=0;
		for (j=0; j<nResults; j++) {
		
			if ((getResultString("Track", j) == track_number[i])&&(getResult("Mother?", j)==0)){
				count = count+1;

				x = getResult("X", j);
				y = getResult("Y", j);
				z =	1;
				t = getResult("Frame", j);
				c = 1;
				ch1 = getResult("Ch1_Mean", j);
				ch2 = getResult("Ch2_Mean", j);
				ch3 = getResult("Ch3_Mean", j);
				ch4 = getResult("Ch4_Mean", j);
				ch5 = getResult("Ch5_Mean", j);
			
				print("Point "+count+" "+x+" "+y+" "+z+" "+t+" "+c+" "+ch1+" "+ch2+" "+ch3+" "+ch4);
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
		newImage("Substack", "8-bit composite-mode", swidth, sheight, pro_number_channels, slices, frames);
		run(type+"-bit");

	selectWindow("Substack");
//set luts dynamically from profile parameters
		for (i=0; i<pro_channel_order.length; i++) {
			if (pro_channel_order[i] > 0) {
				Stack.setChannel(pro_channel_order[i]);
				run(pro_channels[i]);
			}
		}
	selectWindow("Substack");
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
			pro_diameter = substring(row[11],15,lengthOf(row[11]));
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

function list_no_repeats_skip (table, heading, skip) {
//Returns an array of the entries in a column without repeats to use as an index

//make the no_repeats array
	no_repeats = newArray();

//Check whether the table exists
	if (isOpen(table)) {

//get the entries in the column without repeats
		
		var done = false; // used to prematurely terminate loop
		for (i=0; i<nResults && !done; i++) {
			if (getResult(skip,i) == 0) {
			no_repeats = Array.concat(no_repeats, getResultString(heading, i));
			done = true;
		} else {}
		}

//exit if there are no tracks to plot
		if (no_repeats.length < 1) {
			exit("There are no tracks that meet your criteria to plot");
		}

		
		for (i=0; i<nResults; i++) {
			occurence = getResultString(heading, i);
			skip_flag = getResultString(skip, i);
			
			for (j=0; j<no_repeats.length; j++) {
				if (occurence != no_repeats[j] && skip_flag == 0) {
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

function trim_resample_array (array, length) {

//find the first number above 0 in the array and trim all but one 0 do the same at the end

	array2 = newArray();

//explicitly make a new array to get aorund bug with reversing arrays
	for (i=0; i<array.length; i++) {
		array2 = Array.concat(array2,array[i]);
	}
		
	var done = false; // used to prematurely terminate loop 
	for (i=0; i<array.length && !done; i++) {
		if (array[i] > 0){
				start = i-1;
				done = true;
				} else {
					start = 0;
				}
	}

	array2 = Array.reverse(array2); 
	
	var done = false; // used to prematurely terminate loop 
	for (i=0; i<array2.length && !done; i++) {
		if (array2[i] > 0){
				end = i-1;
				done = true;
				} else {
					end = 0;
				}
	}
	end = array2.length-end;
	array = Array.slice(array,start,end);
	array = Array.resample(array, length);
	return array;
}

function mean_index (index, column1, column2, length) {
//returns the means for a results table column split by an array of index - assumes all datasets are the same length (length)

    mean_values = newArray();
	
	for (i=0; i<length; i++) {
		mean_values = Array.concat(mean_values, 0);
		variance = Array.concat(variance, 0);
	}

//get the identifiers from column2 to usee as the index
	//index = list_no_repeats_skip ("Results", column1, "Seed");
	count = index.length;

//get the mean values into an array
	for (i=0; i<index.length; i++) {
		var done = false;
		for (j=0; j<nResults() && !done; j++){
		if (getResultString(column1, j) == toString(index[i])){
			start = j;
			done = true;
			}
		}	
		values = newArray();
		
		for (k=start; k<start+mean_values.length; k++) {
			values = Array.concat(values,getResult(column2,k));
		}
		
//is the array valid or is it full of NaN in which case discard and subtract 1 from count

		if (toString(values[0]) == "NaN") {count = count -1;} else {
		
			for (l=0; l<mean_values.length; l++) {
				mean = mean_values[l] + values[l];
				addToArray(mean, mean_values, l);
			}
		}
	}

	if (toString(values[0]) == "NaN") {} else {

		for (i=0; i<mean_values.length; i++) {
			mean = mean_values[i] / count;
			addToArray(mean, mean_values, i);
		}
	}
	return mean_values;
}

function conf_index (index, column1, column2, length) {
//returns the 95%CI for a results table column split by an array of index values - assumes all datasets are the same length (length)

    mean_values = newArray();
	confidence = newArray();
	variance = newArray();
	standard_deviation =newArray();
	standard_error = newArray();
	
	for (i=0; i<length; i++) {
		mean_values = Array.concat(mean_values, 0);
		variance = Array.concat(variance, 0);
	}

//get the identifiers from column2 to use as the index
	//index = list_no_repeats_skip ("Results", column1, "Seed");
	count = index.length;

//get the mean values into an array
	for (i=0; i<index.length; i++) {
		var done = false;
		for (j=0; j<nResults() && !done; j++){
		if (getResultString(column1, j) == toString(index[i])){
			start = j;
			done = true;
			}
		}

		values = newArray();
		
		for (k=start; k<start+mean_values.length; k++) {
			values = Array.concat(values,getResult(column2,k));
		}

//is the array valid or is it full of NaN in which case discard and subtract 1 from count
		if (toString(values[0]) == "NaN") {count = count -1;} else {
		
			for (l=0; l<mean_values.length; l++) {
				mean = mean_values[l] + values[l];
				addToArray(mean, mean_values, l);
			}
		}
	}
	if (toString(values[0]) == "NaN") {} else {
		
		for (i=0; i<mean_values.length; i++) {
			mean = mean_values[i] / count;
			addToArray(mean, mean_values, i);
		}
	}
	
//get the variance into an array
		for (i=0; i<index.length; i++) {
		var done = false;
		for (j=0; j<nResults() && !done; j++){
		if (getResultString(column1, j) == toString(index[i])){
			start = j;
			done = true;
			}
		}
		values = newArray();
		
		for (k=start; k<start+variance.length; k++) {
			values = Array.concat(values,getResult(column2,k));
		}

//is the array valid or is it full of NaN in which case discard
		if (toString(values[0]) == "NaN") {} else {
		
			for (l=0; l<variance.length; l++) {
				value = (values[l] - mean_values[l]) * (values[l] - mean_values[l]);
				value2 = variance[l] + value;
				addToArray(value2, variance, l);
			}
		}
	}
	if (toString(values[0]) == "NaN") {} else { 	
		for (i=0; i<variance.length; i++) {
			standard_deviation = Array.concat(standard_deviation, sqrt(variance[i]));
		}

		for (i=0; i<standard_deviation.length; i++) {
			standard_error = Array.concat(standard_error, standard_deviation[i]/sqrt(count));
		}

		for (i=0; i<standard_error.length; i++) {
			confidence = Array.concat(confidence, standard_error[i]*1.96);
		}
	}
	return confidence;
}

function get_start(array) {

//find the first entry above 0 in the array and return index
var done = false; // used to prematurely terminate loop 
	for (i=0; i<array.length && !done; i++) {
		if (array[i] > 0){
				start = i;
				done = true;
				} else {
					start = 0;
				}
	}

	return start;
}

function get_end(array) {
//find the last entry above 0 in the array and return index

//explicitly make a new array to get aorund bug with reversing arrays
	for (i=0; i<array.length; i++) {
		array2 = Array.concat(array2,array[i]);
	}
	array2 = Array.reverse(array2);
	
	var done = false; // used to prematurely terminate loop 
	for (i=0; i<array2.length && !done; i++) {
		if (array2[i] > 0){
				end = i+2;
				done = true;
				} else {
					end = 0;
				}
	}
	end = array2.length-end;
	return end;
}

//Icons used courtesy of: http://www.famfamfam.com/lab/icons/silk/
