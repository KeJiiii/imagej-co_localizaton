
for (times = 0; times < 4 ; times++) {
	
	selection=times%5;
	choice=newArray("1","2","3","4","5");
	filedirec=newArray("1","2");
	Dialog.create("Fluorescent Image Quantitative Analysis  ");
		Dialog.addMessage("Enter your setting here:");
		Dialog.addChoice("       Step", choice,choice[selection]);
		Dialog.addChoice("       Folder Hierarchy", filedirec,filedirec[0]);
		//Dialog.addMessage("1. open by Bioforamt and save");
		//Dialog.addMessage("2. open by Olympus viewer and save");
		Dialog.addMessage("1. Image preprocessing");
		Dialog.addMessage("2. Subtract background");
		Dialog.addMessage("3. Select skin");
		Dialog.addMessage("4. Remove skins");
		Dialog.addMessage("5. Analysis and data export");
	
		
	Dialog.show();
	user_choice=Dialog.getChoice();
	user_dirc=Dialog.getChoice();
	fa_path = getDirectory("Choose the Input Directory");
	fa_file_list=getFileList(fa_path);	
	user_input();

	//function 
	function splitchannel(title,file){
		selectWindow(title);
		run("Split Channels");
		for (k = 0; k < 2; k++){
			kk = "C"+k+1+"-"+title;
			//selectWindow(kk);
			//run("Subtract Background...", "rolling=200 stack");
			selectWindow(kk);
			setMinAndMax(0, 4095);
			saveAs("Tiff", filelocation+"Com_"+file+"_C"+k+1);
			//selectWindow(file+"_C"+k+1+".tif");
			//run("Z Project...", "projection=[Average Intensity] all");
			//saveAs("Tiff", filelocation+"AVG_"+file+"_C"+k+1);
		}
		close("*");
	}
	
	
	function combine(fishnumber,filelocation,file){
		for (i = 0; i < fishnumber; i++){
			if (i+1 < 10){
				new_i="0"+i+1;
			}
				else {
					new_i=i+1;
			}
			b=filelocation+file+new_i+".tif";
			print("b========"+b);
			open(b);
			rename(i);
		}
		if (fishnumber == 1){
			title = file+1+".tif";
			file = file;
			splitchannel(title,file);
		}
		if (fishnumber > 1){
			run("Combine...", "stack1="+"0"+" stack2="+"1");
			if 	(fishnumber > 2){
				for (j = 2; j < fishnumber; j++)
				{
					
					run("Combine...", "stack1=[Combined Stacks]"+" stack2="+j);
				}
			}
			title = "Combined Stacks";
			file = file;	
			splitchannel(title,file);
		}
	}
	
	
	
	
	function stitching(select_path,x,y,Z_method,file_form) { 
	// function description
		n=0;
		
		for (l = 0; l < son_file_list.length; l++){
			if (endsWith(son_file_list[l],"0001."+file_form)){
				n=n+1;
				path=select_path;
				file_names=substring(son_file_list[l], 0, lengthOf(son_file_list[l])-5)+"{i}."+file_form;
				file_name_main=substring(son_file_list[l], 0, lengthOf(son_file_list[l])-9);
				run("Grid/Collection stitching", "type=[Grid: column-by-column] order=[Down & Right                ] grid_size_x="+x+" grid_size_y="+y+" tile_overlap=10 first_file_index_i=1 directory="+path+" file_names="+file_names+" output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] regression_threshold=0.30 max/avg_displacement_threshold=2.50 absolute_displacement_threshold=3.50 compute_overlap computation_parameters=[Save computation time (but use more RAM)] image_output=[Fuse and display]");
				//run("Subtract Background...", "rolling=200 stack");
				saveAs("tiff", select_path+"stitch_"+file_name_main+".tif");
				run("Z Project...", "projection=["+Z_method+"] all");
				method=substring(Z_method, 0, 3)+"_";
				saveAs("tiff", select_path+method+file_name_main+".tif");
				run("Close All");
			}
		}
		if (combine_c == "yes"){
			//print("method======"+substring(Z_method, 0, 3));
			file=method+substring(file_name_main, 0, lengthOf(file_name_main)-2);
			combine(n,select_path,file);
		} 
	}
	
	function open_by_Bio(select_path,Z_method,file_form) { 
		for (j = 0; j < son_file_list.length; j++){
			if (endsWith(son_file_list[j],file_form)){
				Cycle_name = son_file_list[j];
				file_name_main=substring(son_file_list[j], 0, lengthOf(son_file_list[j])-9);
				//run("Viewer", "open="+select_path+Cycle_name); 
				run("Bio-Formats Importer", "open="+select_path+Cycle_name+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	          
				saveAs("tiff", select_path+"stitch_"+file_name_main+".tif");
				run("Z Project...", "projection=["+Z_method+"] all");
				method=substring(Z_method, 0, 3)+"_";
				saveAs("tiff", select_path+method+file_name_main+".tif");
				close("*");
			}
		}
		if (combine_c == "yes"){
			//print("method======"+substring(Z_method, 0, 3));
			file=method+substring(file_name_main, 0, lengthOf(file_name_main)-2);
			combine(n,select_path,file);
		} 
	}
	
	
	function open_by_oly(select_path,son_file_list) { 
		for (j = 0; j < son_file_list.length; j++){
			if (endsWith(son_file_list[j],"oir")){
				Cycle_name = son_file_list[j];
				name_main=substring(Cycle_name,0,lengthOf(Cycle_name)-4);
				run("Viewer", "open="+select_path+Cycle_name);  //使用奥林巴斯插件，很慢
				//run("Bio-Formats Importer", "open="+select_path+Cycle_name+" autoscale color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	            //上面这行是imagej 自带插件bioformat,速度比较快，但是处理cycle 多时间文件容易报错。	
				//run("Subtract Background...", "rolling=50 stack");
				saveAs("Tiff", select_path+name_main+".tif");
				run("Z Project...", "projection=[Sum Slices]");
				saveAs("Tiff", select_path+"Sum_"+name_main+".tif");
				close("*");
			}
		}
	}
	
	
	function subtract(select_path,son_file_list) { 
		for (l = 0; l < son_file_list.length; l++){
			if (startsWith(son_file_list[l],"stitch") && endsWith(son_file_list[l],".tif")){
				open(select_path+son_file_list[l]);
				filename=substring(son_file_list[l], 0, lengthOf(son_file_list[l])-3);
				raw=getTitle();
				//selectWindow(raw);
				//run("Subtract Background...", "rolling=200 stack");
				//run("Save");
				selectWindow(raw);
				roiManager ("Reset"); 
				waitForUser ("Add a background ROI.");
				run("Select None");
				run("Duplicate...", "duplicate channels=1");
				rename("C1");
				selectWindow("C1");
				roiManager ("Select",0);
				//run("Measure Stack...");// for static data
				run("Measure Stack...", "channels slices frames order=czt(default)"); // for kinetic timelampse data		
				Table.sort("Mean");
				C1_value=getResult("Mean");
				C1_value=parseInt(C1_value)+1;
				run("Clear Results");
				selectWindow(raw);
				run("Select None");
				run("Duplicate...", "duplicate channels=2");
				rename("C2");
				selectWindow("C2");
				roiManager ("Select",0);
				//run("Measure Stack...");
				run("Measure Stack...", "channels slices frames order=czt(default)"); // for kinetic timelampse data
				Table.sort("Mean");
				C2_value=getResult("Mean");
				C2_value=parseInt(C2_value)+1;
				run("Clear Results");
				selectWindow("C1");
				run("Select None");
				run("Subtract...", "value="+C1_value+" stack");
				selectWindow("C2");
				run("Select None");
				run("Subtract...", "value="+C2_value+" stack");
				run("Merge Channels...", "c1=[C1] c2=[C2] create");
				saveAs("Tiff", select_path+"Sub_"+C1_value+"_"+C2_value+"_"+filename+"tif");
				roiManager ("Reset"); 
				run("Close All");
			}
		}
	}
	
	function subtract_by_rolling(select_path,son_file_list,radiu) { 
		for (j = 0; j < son_file_list.length; j++){
			if (startsWith(son_file_list[j],"stitch")){
				Cycle_name = son_file_list[j];
				open(select_path+Cycle_name); 
				run("Subtract Background...", "rolling="+radiu+" stack");
				saveAs("Tiff", select_path+"Sub_roll_"+Cycle_name);
				//run("Z Project...", "projection=[Sum Slices]");
				//saveAs("Tiff", select_path+"Sum_"+name_main+".tif");
				close("*");
			}
		}
	}
	
	
	
	function goto(slices,filename,select_path) { 
		waitForUser ("Add a ROI per slice to circle all positive cells");
		n=roiManager ("Count");
		if (n== slices){
			roiManager("Save", select_path+filename+"zip");
			roiManager ("Reset"); 
			close("*");
		} else {
			yesno=newArray("YES","NO");
			Dialog.create("Note!");
			Dialog.addMessage("Selected ROI num is not consistent with the slice number. \ncheck the ROI again.  ");
			Dialog.addRadioButtonGroup("   Completed?", yesno,1,2,"NO");
			Dialog.addMessage("Note:\nAnswer NO will continue to circle ROI ");		
			Dialog.show();
			roi=Dialog.getRadioButton();
			if (roi=="NO"){
				goto(slices,filename,select_path);
			}else {
				roiManager("Save", select_path+filename+"zip");
				roiManager ("Reset"); 
				close("*");
			}
		}
		
	}
	function interpolate(filename,select_path){
		waitForUser ("Add a ROI per slice to circle all positive cells");
		run("Select All");
		roiManager("Interpolate ROIs");
		roiManager("Save", select_path+filename+"zip");
		roiManager ("Reset"); 
		close("*");
	}
	
	function generate_roi_remove(select_path,son_file_list,color_ratio_low,color_ratio_high,color_ratio_brightness) { 
		
		for (l = 0; l < son_file_list.length; l++){
			if (startsWith(son_file_list[l],"Sub") && endsWith(son_file_list[l],".tif")){
				open(select_path+son_file_list[l]);
				raw=getTitle();
				run("Duplicate...", "duplicate channels=1");
				img1=getTitle();
				selectWindow(raw);
				run("Duplicate...", "duplicate channels=2");
				img2=getTitle();
				run("Color Ratio Plus v1", "image1=["+img1+"] image2=["+img2+"] background1=0 clipping_value1=0 background2=0 clipping_value2=0 multiplication=1 color_scale_low="+color_ratio_low+" color_scale_high="+color_ratio_high+" brightness="+color_ratio_brightness);
				selectWindow("Color Ratio");
				getDimensions(width, height, channels, slices, frames);
				filename=substring(son_file_list[l], 0, lengthOf(son_file_list[l])-3);
				
				//selectWindow(raw);
				//run("Subtract Background...", "rolling=200 stack");
				//run("Save");
				selectWindow(raw);
				roiManager ("Reset"); 
				//goto(slices,filename,select_path);
				interpolate(filename,select_path);	
			}
		}
	}
	
	function remove_by_roi(select_path,filelist) { 
		for (j = 0; j < filelist.length; j++) {
			if (endsWith(filelist[j], ".zip")){
				roiManager ("Reset");
				
				//open(select_path+filelist[j]);
				roiManager("Open", select_path+filelist[j]);
				imgname=substring(filelist[j],0,lengthOf(filelist[j])-4)+".tif";
				open(select_path+imgname);
				run("Select None");
				img=getTitle();
				run("Duplicate...", "duplicate channels=1");
				channel1=getTitle();
				selectWindow(img);
				run("Duplicate...", "duplicate channels=2");
				channel2=getTitle();
				run("Colors...", "foreground=black background=black selection=yellow");
				n=roiManager ("Count");
				selectWindow(channel1);
				for (i = 0; i < n; i++){
					selectWindow(channel1);
					roiManager("Select", i);
					run("Clear Outside", "slice");
					selectWindow(channel2);
					roiManager("Select", i);
					run("Clear Outside", "slice");
				}
				selectWindow(channel1);
				saveAs("Tiff", select_path+"M_C1_"+imgname);
				rename(111);
				run("Z Project...", "projection=[Sum Slices] all");
				saveAs("Tiff", select_path+"Z_M_C1_"+imgname);
				selectWindow(channel2);
				run("Select None");
				saveAs("Tiff", select_path+"M_C2_"+imgname);
				rename(222);
				run("Z Project...", "projection=[Sum Slices] all");
				saveAs("Tiff", select_path+"Z_M_C2_"+imgname);

				run("Merge Channels...", "c1=111 c2=222 create");
				saveAs("Tiff", select_path+"rem_"+imgname);
			
				roiManager ("Reset");
				close("*");
				//new_list=getFileList("select_path");
				//merge(select_path,new_list);
			}
		}
	}
	
	function merge(select_path,filelist) { 
		for (j = 0; j < filelist.length; j++) {
			if (startsWith(filelist[j], "M_C1")){
				open(select_path+filelist[j]);
				run("Select None");
				rename(111);
				c2_name="M_C2_"+substring(filelist[j],5,lengthOf(filelist[j]));
				open(select_path+c2_name);
				run("Select None");
				rename(222);
				run("Merge Channels...", "c1=111 c2=222 create");
				saveAs("Tiff", select_path+"Manual_"+substring(filelist[j],5,lengthOf(filelist[j])));
			}
			close("*");
		}
	}
	
	function get_color_threshold_mask(inputstacks,Hue,braightness) {
		selectWindow(inputstacks);
		getDimensions(width, height, channels, slices, frames);
		print(slices);
		for (n = 0; n < slices; n++) {
			selectWindow(inputstacks);
			run("Duplicate...", "duplicate range="+n+1+"-"+n+1+" use");
			a=getTitle();
			min=newArray(3);
			max=newArray(3);
			filter=newArray(3);
			selectWindow(a);
			run("HSB Stack");
			run("Convert Stack to Images");
			selectWindow("Hue");
			rename("0");
			selectWindow("Saturation");
			rename("1");
			selectWindow("Brightness");
			rename("2");
			min[0]=0;
			max[0]=Hue;
			filter[0]="pass";
			min[1]=0;
			max[1]=255;
			filter[1]="pass";
			min[2]=braightness;
			max[2]=255;
			filter[2]="pass";
			for (i=0;i<3;i++){
			  selectWindow(""+i);
			  setThreshold(min[i], max[i]);
			  run("Convert to Mask");
			  if (filter[i]=="stop")  run("Invert");
			}
			imageCalculator("AND create", "0","1");
			imageCalculator("AND create", "Result of 0","2");
			for (i=0;i<3;i++){
			  selectWindow(""+i);
			  close();
			}
			selectWindow("Result of 0");
			close();
			selectWindow("Result of Result of 0");
			rename("flow_"+n+1);
		}
		run("Images to Stack", "name=Stack title=flow_");
	}
	
	
	function get_particle(select_path,son_file_list) { 
		for (l = 0; l < son_file_list.length; l++){
			if (startsWith(son_file_list[l],"rem") && endsWith(son_file_list[l],"tif")){
				// from BLk data to color threshold mask,raw mean the window,not the directory
				print("son_file============================="+son_file_list[l]);
				open(select_path+son_file_list[l]);
				
				raw=getTitle();
				filename=substring(raw,0,lengthOf(raw)-4);
				for (i = 1; i < 3; i++){
					selectWindow(raw);
					run("Duplicate...", "duplicate channels="+i);
					run("Gaussian Blur 3D...", "x=1 y=1 z=1");
					run("8-bit");
					setAutoThreshold("Otsu dark");
					run("Convert to Mask", "method=Otsu background=Dark calculate");  //这里 313不能有black 但是笔记本可以
					 
					run("Watershed", "stack");
					rename(i);
				}
				imageCalculator("AND create stack", "1","2");
				rename(3);
				
				selectWindow(1);
				roiManager("reset");
				run("Analyze Particles...", "size="+scale+"-Infinity circularity="+circle1+"-"+circle2+" display clear include add in_situ stack");
				n_1 = roiManager("count");
				roiManager("reset");
				selectWindow(2);
				run("Analyze Particles...", "size="+scale+"-Infinity circularity="+circle1+"-"+circle2+" display clear include add in_situ stack");
				n_2 = roiManager("count");
				roiManager("reset");
				selectWindow(3);
				run("Analyze Particles...", "size="+scale+"-Infinity circularity="+circle1+"-"+circle2+" display clear include add in_situ stack");
				n_3 = roiManager("count");
				run("Clear Results");
				selectWindow(raw);
				run("Duplicate...", "duplicate channels=1");
				roiManager("Show All");
				roiManager("Measure");
				selectWindow("Results");
				ch1_array=Table.getColumn("Mean");
				run("Clear Results");
				selectWindow(raw);
				run("Duplicate...", "duplicate channels=2");
				roiManager("Show All");
				roiManager("Measure");
				ch2_array=Table.getColumn("Mean");
				roiManager("Show All");
				roiManager("Save", select_path+"ROI_"+n_1+"_"+n_2+"_"+n_3+"_"+filename+".zip");
				run("Clear Results");
				
				//
				Table.create ("ratio_results");
				Table.setColumn("Ch1", ch1_array);
				ratio_array=ch1_array;
				for (i=0;i<ch1_array.length;i++){
					ratio_array[i]=ch1_array[i]/ch2_array[i];
				}
				
				Table.setColumn("Ch2", ch2_array);
				Table.setColumn("Ch1/Ch2", ratio_array);
				saveAs("ratio_results", select_path+"list_ratio_"+filename+".csv");
				run("Clear Results");
				run("Close");
				roiManager("reset");
				close("*");
				
				
			}
		}
	}
	
	
	function remove_zskin(fix,select_channel,move,save_dir,threshold,Fill,Erode) { 
		mergestring="";
		open(fix); 
		reference=getTitle();
		getDimensions(width, height, channels, Znumber, frames);
		print("channels====="+channels);
		open(move);
		raw= getTitle();
		if (select_channel=="Ch1") run("Duplicate...", "duplicate=1");
		if (select_channel=="Ch2") run("Duplicate...", "duplicate=2");
		if (select_channel=="color_ratio") {
			selectWindow(raw);
			run("Duplicate...", "duplicate channels=1");
			Ch1=getTitle();
			selectWindow(raw);
			run("Duplicate...", "duplicate channels=2");
			Ch2=getTitle();
			run("Color Ratio Plus v1", "image1=["+Ch1+"] image2=["+Ch2+"] background1=0 clipping_value1=0 background2=0 clipping_value2=0 multiplication=1 color_scale_low="+color_ratio_low+" color_scale_high="+color_ratio_high+" brightness="+color_ratio_brightness);
			selectWindow("Color Ratio");
		}
		mask=getTitle();
		selectWindow(mask);
		
		run("8-bit");
		mask1 = getTitle();
		run("Gaussian Blur...", "sigma=4 stack");
		//run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
		//run("Find Edges", "stack");

		setAutoThreshold("Otsu dark");
		setThreshold(threshold, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask", "method=Otsu background=Dark black");
		
		for (i = 0; i < Fill; i++) {
			run("Fill Holes", "stack");
			run("Dilate", "stack");
			run("Fill Holes", "stack");
		}
		
		for (i = 0; i < Erode; i++) {
			run("Erode", "stack");
		}
		selectWindow(mask1);
		mergestring="";
		for (i = 0; i < channels; i++) {
			mergestring=mergestring+"c"+i+1+"=["+mask1+"] ";
		}
		print("mergestring====="+mergestring);
		run("Merge Channels...", mergestring+" create");
		Mask2 = getTitle();
		selectWindow(Mask2);
		run("Divide...", "value=255.000 stack");
		imageCalculator("Multiply create stack", reference,Mask2);
		reference1=getTitle();
		selectImage(reference1);
		saveAs("tiff", save_dir+"Auto_"+reference1);
		close("*");
	}
	
	
	
	
	
	
	//open images by bioformat or olympus viewer 
	/*
	if (user_choice==1){
		print("open by Bioforamt and save");
		open_by_Bio(select_path,son_file_list);
		
	}
	if (user_choice==2){
		print("open by Olympus viewer and save");
		open_by_oly(select_path,son_file_list)
		
	}
	*/
	
	function user_input(){
		if (user_choice==1){
			print("Image preprocessing");
			yesno=newArray("yes","no");
			file_form=newArray("oir","tif","nd2");
			z_method=newArray("Average Intensity","Max Intensity","Min Intensity","Sum Slices","Standard Deviation","Median");
			Dialog.create("Stitching parameters");
				Dialog.addMessage("Type  =  column by column");
				Dialog.addMessage("Order =  down by right");
				Dialog.addNumber("Grid size x", 1);
				Dialog.addNumber("Grid size y", 2);
				Dialog.addChoice("       File format", file_form,file_form[0]);
				Dialog.addChoice("       Z-projection Methods", z_method,z_method[3]);
				//Dialog.addRadioButtonGroup("Combine images?", yesno,1,2,"no");
				Dialog.addMessage("Please note that the Stitching is based on the plugin:\nGrid/Collection stitching. Preibisch et al, Bioinformatics(2009)");
			Dialog.show();
			file_form=Dialog.getChoice();
			Z_method=Dialog.getChoice();
			x=Dialog.getNumber;
			y=Dialog.getNumber;
			//combine_c=Dialog.getRadioButton();
			combine_c="no";

			if (user_dirc==2){
				for (f = 0; f < fa_file_list.length; f++){
					select_path = fa_path+fa_file_list[f];
					son_file_list=getFileList(select_path);
					if ((x!=1) || ( y!=1)){stitching(select_path,x,y,Z_method,file_form);} else{open_by_Bio(select_path,Z_method,file_form);}
					
				}
			}
			else{
				select_path = fa_path;
				son_file_list=getFileList(select_path);
				if ((x!=1) || ( y!=1)){stitching(select_path,x,y,Z_method,file_form);} else{open_by_Bio(select_path,Z_method,file_form);}
			}
			
		
		}
		
		
		
		if (user_choice==2){
			print("Subtract background");
			yesno=newArray("yes","no");
			Dialog.create("Subtract parameters");
				Dialog.addRadioButtonGroup("Subtract backgroud by Rolling ball?", yesno,1,2,"no");
				Dialog.addNumber("    Radius (pixels)", 200);
				Dialog.addMessage("If the answer is YES,please add Rolling ball radius \nIf the answer is NO,backgroud will be subtracted by your ROIs");
				Dialog.addMessage("Note:\nOnly read files that start with (stitch_) ");
			Dialog.show();
			radiu=Dialog.getNumber;
			sub=Dialog.getRadioButton();

			if (user_dirc==2){
				for (f = 0; f < fa_file_list.length; f++){
					select_path = fa_path+fa_file_list[f];
					son_file_list=getFileList(select_path);
					if (sub=="no"){
						subtract(select_path,son_file_list);
					}
					if (sub=="yes"){
						subtract_by_rolling(select_path,son_file_list,radiu);
					}
				}
			}
			else{
				select_path = fa_path;
				son_file_list=getFileList(select_path);
				if (sub=="no"){
					subtract(select_path,son_file_list);
				}
				if (sub=="yes"){
					subtract_by_rolling(select_path,son_file_list,radiu);
				}
			}

		}
		
		
		if (user_choice==3){
			print("Remove skins");
			Dialog.create("Select skin parameters");
				Dialog.addMessage("This parameters will be need to generate color ratio images");
				Dialog.addNumber("Color Ratio--low value", 0);
				Dialog.addNumber("Color Ratio--high value", 2);
				Dialog.addNumber("Color Ratio--brightness", 300);
				Dialog.addMessage("Note:\nOnly read files that start with (Sub_) ");		
			Dialog.show();
			color_ratio_low=Dialog.getNumber;
			color_ratio_high=Dialog.getNumber;
			color_ratio_brightness=Dialog.getNumber;
			if (user_dirc==2){
				for (f = 0; f < fa_file_list.length; f++){
					select_path = fa_path+fa_file_list[f];
					son_file_list=getFileList(select_path);
					generate_roi_remove(select_path,son_file_list,color_ratio_low,color_ratio_high,color_ratio_brightness);
					//select_path = fa_path+fa_file_list[f];
					//son_file_list=getFileList(select_path);
					//remove_by_roi(select_path,son_file_list);
				}
			}
			else{
				select_path = fa_path;
				son_file_list=getFileList(select_path);
				generate_roi_remove(select_path,son_file_list,color_ratio_low,color_ratio_high,color_ratio_brightness);
				//select_path = fa_path;
				//son_file_list=getFileList(select_path);
				//remove_by_roi(select_path,son_file_list);
			}
			
			
		}
		
		if (user_choice==4){
			print("Remove skin");
			yesno=newArray("yes","no");
			Channel_choice=newArray("Ch1","Ch2","color_ratio");
			Dialog.create("Remove skin parameters");
				Dialog.addRadioButtonGroup("Remove skin by ROIs?", yesno,1,2,"no");
				Dialog.addMessage("If the answer is NO,\nParameters will be needed to automatically remove the skin");
				Dialog.addChoice("       Which channel?", Channel_choice,Channel_choice[0]);
				Dialog.addNumber("minimum threshold", 3);
				Dialog.addNumber("Fill times", 20);
				Dialog.addNumber("Erode times", 35);
				Dialog.addNumber("color ratio low", 0);
				Dialog.addNumber("color ratio high", 2);
				Dialog.addNumber("color ratio brightness", 400);
				Dialog.addMessage("Note:\nOnly read files that start with (Sub_) ");
			Dialog.show();
			rem=Dialog.getRadioButton();
			select_channel=Dialog.getChoice();
			threshold=Dialog.getNumber;
			Fill=Dialog.getNumber;
			Erode=Dialog.getNumber;
			color_ratio_low=Dialog.getNumber;
			color_ratio_high=Dialog.getNumber;
			color_ratio_brightness=Dialog.getNumber;

			if (user_dirc==2){
				for (f = 0; f < fa_file_list.length; f++){
					select_path = fa_path+fa_file_list[f];
					son_file_list=getFileList(select_path);
					if(rem=="yes"){
						remove_by_roi(select_path,son_file_list);
					}
					if(rem=="no"){
						for (l = 0; l < son_file_list.length; l++){
							if (startsWith(son_file_list[l],"stitch") && endsWith(son_file_list[l],".tif")){
								fix=select_path+son_file_list[l];
								move=select_path+son_file_list[l];
								save_dir=select_path+"remove_auto/";
								File.makeDirectory(select_path+"remove_auto/");
								remove_zskin(fix,select_channel,move,save_dir,threshold,Fill,Erode);
							}
							close("*");
						}
					}
				}
			}
			else{
				select_path = fa_path;
				son_file_list=getFileList(select_path);
				if(rem=="yes"){
					remove_by_roi(select_path,son_file_list);
				}
				if(rem=="no"){
					for (l = 0; l < son_file_list.length; l++){
						if (startsWith(son_file_list[l],"stitch") && endsWith(son_file_list[l],".tif")){
							fix=select_path+son_file_list[l];
							move=select_path+son_file_list[l];
							save_dir=select_path+"remove_auto/";
							File.makeDirectory(select_path+"remove_auto/");
							remove_zskin(fix,select_channel,move,save_dir,threshold,Fill,Erode);
						}
						close("*");
					}
				}
			}
		}
		
		
		
		if (user_choice==5){
			print("Analysis and data export");
			//Channel_choice=newArray("Ch1","Ch2","color_ratio");
			//species_choice=newArray("cell","fish");
			Dialog.create("Analyze Particle parameter");
				//Dialog.addChoice("       Experimental subject", species_choice,species_choice[1]);
				//Dialog.addChoice("       Which channel to use to get particles?", Channel_choice,Channel_choice[0]);
				Dialog.addMessage("Enter your setting here:");
				//Dialog.addNumber("color ratio low", 0);
				//Dialog.addNumber("color ratio high", 2);
				//Dialog.addNumber("color ratio brightness", 400);
				//Dialog.addNumber("color threshold Hue", 160);
				//Dialog.addNumber("color threshold brightness", 100);
				Dialog.addNumber("particle size", 50);
				Dialog.addNumber("particle shape mini", 0.3);
				Dialog.addNumber("particle shape max", 1);
				//Dialog.addNumber("GBsigma", 1);
				
				//Dialog.addMessage("Note:\nOnly read files that start with (Manual_) ");
			Dialog.show();
			//color_ratio_low=Dialog.getNumber;
			//color_ratio_high=Dialog.getNumber;
			//color_ratio_brightness=Dialog.getNumber;
			//Hue=Dialog.getNumber;
			//braightness=Dialog.getNumber;
			scale=Dialog.getNumber;
			circle1=Dialog.getNumber;
			circle2=Dialog.getNumber;
			//GBsigma=Dialog.getNumber;
			//species_results=Dialog.getChoice();
			//select_channel=Dialog.getChoice();


			if (user_dirc==2){
				for (f = 0; f < fa_file_list.length; f++){
					select_path = fa_path+fa_file_list[f];
					son_file_list=getFileList(select_path);
					get_particle(select_path,son_file_list);
				}
			}
			else{
				select_path = fa_path;
				son_file_list=getFileList(select_path);
				get_particle(select_path,son_file_list);
			}
			waitForUser("End");
		}
	}	
}