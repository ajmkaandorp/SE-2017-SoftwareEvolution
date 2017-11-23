module metrics::vol

import lang::java::jdt::m3::Core;
import String;
import IO;
import List;

public str getVolumeScore(int amountLines) {
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


public str getUnitVolumeScores(list[int] unitVolumes){
// Calculates SIG scores for unit volumes.
// Scores are based on https://docs.sonarqube.org/display/SONARQUBE45/SIG+Maintainability+Model+Plugin
	unitVolumesHist = getUnitVolumesHist(unitVolumes);
	int tot = sum(unitVolumesHist);
	if(unitVolumesHist[1] < tot/4. && unitVolumesHist[2]==0 && unitVolumesHist[3]==0) return "++";
	if(unitVolumesHist[1] < tot/10.*3 && unitVolumesHist[2] < tot/20. && unitVolumesHist[3]==0) return "+";
	if(unitVolumesHist[1] < tot/10.*4 && unitVolumesHist[2] < tot/10. && unitVolumesHist[3]==0) return "o";
	if(unitVolumesHist[1] < tot/10.*5 && unitVolumesHist[2] < tot/20.*3 && unitVolumesHist[3] < tot/20.) return "-";
	return "--";
}

public list[int] getUnitVolumesHist(list[int] unitVolumes){
// Bins the list of the volumes of individual units of code.
// Bin sizes based on https://docs.sonarqube.org/display/SONARQUBE45/SIG+Maintainability+Model+Plugin
	list[int] unitVolumesHist =[0,0,0,0]; 
	for(unitVolume <- unitVolumes){
		if(unitVolume < 11) unitVolumesHist[0] += 1;
		if(10 < unitVolume && unitVolume < 51) unitVolumesHist[1] += 1;
		if(50 < unitVolume && unitVolume < 101) unitVolumesHist[2] += 1;
		if(unitVolume > 100) unitVolumesHist[3] += 1;
	}
	return unitVolumesHist;
}

public list[str] calcVolumeMethod(loc location) {
	// Replaces strings with dummy strings, removes comments and white space.
    str filteredContent = removeUnwantedStrings(readFile(location));
    filteredContent = removeUnwantedComments(filteredContent);
    filteredContent = replaceAll(filteredContent," ","");
    filteredContent = replaceAll(filteredContent,"\t","");
    filteredContent += "\r\n"; // To also count the last line, in case a \r\n would be missing there.
	return split("\n", filteredContent);
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
// First removes unwanted content, then counts \r\n's that have code in between.

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
