module metrics::vol

import lang::java::jdt::m3::Core;
import String;
import IO;
import List;

public str getVolumeScore(int amountLines) {
	// reader score amount of lines * 1000 
	if(amountLines <= 66000) {
		return "++";
	} else if(amountLines <= 246000) {
		return "+";
	} else if(amountLines <= 665000) {
		return "o";
	} else if(amountLines <= 1310000) {
		return "-";
	}
	return "--";
}


public int calcVolumeClasses(list[loc] classes) {
	int n = 0;
	for(projectClass <- classes) {
		n += calcVolume(projectClass);
	}
	return n;
}

public list[str] calcVolumeMethod(loc location) {
	//str content = readFile(location);
	str content = replaceAll(readFile(location)," ","");
	str filteredContent = removeUnwantedContent(content);
	return split("\n", filteredContent);
}

//public int calcTotalVolume(loc project) {
//	int volume = 0;
//
//	M3 m3project = createM3FromEclipseProject(project);
//	for(location <- m3project)
//		volume += calcVolume(location);
//	return volume;
//}

public int calcTotalVolume(set[loc] locations) {
	int volume = 0;
	for(location <- locations) 
		volume += calcVolume(location);
	return volume;
}

public list[str] calcMethodVolume(loc location) {
	
}

public tuple[list[int],list[loc]] calcIndividualVolume(set[loc] locations) {
// Calculates the volume of code at each of the given locations (also works for methods).
	list[int] volumes = [];
	//int n = 0;  //for diagnostics
	list[loc] loclist = [];
	for(location <- locations){
		//if(n==0) iprintln(location);  //also diagnostics
		//n+=1;  //for the same diagnostics as before
		volumes += [calcVolume(location)];
		loclist += location;
	}
	return <volumes, loclist>;
}

public int calcVolume(loc location){
    // remove white space
    str file = replaceAll(readFile(location)," ","");
    file = replaceAll(file,"\t","");
    file += "\r\n";
	//str file = removeUnwantedContent(readFile(location));
	int n = 0;
	int newline = 0;
 	for(int i <- [0 .. size(file)-1]){
  		if(file[i]+file[i+1] =="\r\n"){
   			str line = substring(file,newline,i);
   			newline = i+2;
   			
   			if(size(line)>0 && /\w/:=line[0]) {n+=1;
   			}else{if(size(line)>1 && line[0] == "}" && /\w/:=line[1]) {n+=1;
   				}
			}
			
   //			if(size(line)>0 && /\w/:=line[0]) {n+=1; iprintln("ADDED "+line);
   //			}else{if(size(line)>1 && line[0] == "}" &&/\w/:=line[1]) {n+=1; iprintln("ADDED "+line);
			//	}else{iprintln("NOT "+line);}
			//}
		}
	}
	if(newline == 0) n = 1;
	return n;
}


//src: https://stackoverflow.com/questions/40257662/how-to-remove-whitespace-from-a-string-in-rascal
public str removeUnwantedContent(str content) {
// doesnt really work yet
//19/11: Fixed, removed whitespace, left comments
	return visit (content) { 
		case /\/\/.*/ => "" //remove single comments
		case /\/\*.*?\*\//s => "" // remove multi line comments
	}
}

