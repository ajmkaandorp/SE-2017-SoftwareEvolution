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


public str getUnitVolumeScore(list[int] linesPerUnit) {
// What scoring metrics to use here?
	sizeScores = getUnitVolumeHist(linesPerUnit);
	tot = sum(sizeScores); 
	if(sizeScores[1] < tot/4. && sizeScores[2]==0 && sizeScores[3]==0) return "++";
	if(sizeScores[1] < tot/10.*3 && sizeScores[2] < tot/20. && sizeScores[3]==0) return "+";
	if(sizeScores[1] < tot/10.*4 && sizeScores[2] < tot/10. && sizeScores[3]==0) return "o";
	if(sizeScores[1] < tot/10.*5 && sizeScores[2] < tot/20.*3 && sizeScores[3] < tot/20.) return "-";
	return "--";
}

public list[int] getUnitVolumeHist(list[int] linesPerUnit){
// Bins the calculated volumes to a volume catagory list.
// What scoring metrics to use here?
	list[int] sizeScores =[0,0,0,0]; 
	for(lines <- linesPerUnit){ // Why not use switch here?
		if(lines <= 10) sizeScores[0] += 1;
		if(10 < lines && lines <= 20) sizeScores[1] += 1;
		if(20 < lines && lines <= 50) sizeScores[2] += 1;
		if(lines > 50) sizeScores[3] += 1;
	}
	return sizeScores;
}


public int calcTotalVolume(set[loc] locations) {
	int volume = 0;
	for(location <- locations) 
		volume += calcVolume(location);
	return volume;
}


public list[int] calcIndividualVolume(set[loc] locations) {
// Calculates the volume of code at each of the given locations (or, unit volume).
	list[int] volumes = [];
	for(location <- locations){
		volumes += [calcVolume(location)];
	}
	return volumes;
}


public int calcVolume(loc location){
// Counts and returns the lines of code at the given location.
    // Replaces strings with dummy strings, removes comments and white space.
    str file = removeUnwantedStrings(readFile(location));
    file = removeUnwantedComments(file);
    file = replaceAll(file," ","");
    file = replaceAll(file,"\t","");
    file += "\r\n"; // To also count the last line, in case a \r\n would be missing there.
	int n = 0;
	int newline = 0;
	// Counts line length for every line by looking at the distance between \r\n's. If the line is not
	// empty, it adds one to the line count.
 	for(int i <- [0 .. size(file)-1]){
  		if(file[i]+file[i+1] =="\r\n"){
   			str line = substring(file,newline,i);
   			newline = i+2;			
   			if(size(line)>0) n+=1;
   			
			//if(size(line)>0) {n+=1; iprintln(toString([n])+"ADDED "+line); // For diagnostics
			//}else{iprintln(toString([n])+"NOT "+line);}	
		}
	}
	return n;
}

public str removeUnwantedStrings(str content) {
// Removes string content, for if there's a "/*" or something on a line, so that removeUnwantedComments
// no longer picks up on it.
	return visit (content) { 
		case /\".*?\"|\'.*?\'/ => "\"STRING\""
	}
}

//src: https://stackoverflow.com/questions/40257662/how-to-remove-whitespace-from-a-string-in-rascal
public str removeUnwantedComments(str content) {
// Removes all comments in a given string.
	return visit (content) { 
		case /\/\*[\s\S]*?\*\/|\/\/.*/ => "" // removes comments, partial thanks to Rocco
	}
}
