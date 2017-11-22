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

public str getUnitVolumeScores(list[int] unitVolumes){
	unitVolumesHist = getUnitVolumesHist(unitVolumes);
	int tot = sum(unitVolumesHist);
	if(unitVolumesHist[1] < tot/4. && unitVolumesHist[2]==0 && unitVolumesHist[3]==0) return "++";
	if(unitVolumesHist[1] < tot/10.*3 && unitVolumesHist[2] < tot/20. && unitVolumesHist[3]==0) return "+";
	if(unitVolumesHist[1] < tot/10.*4 && unitVolumesHist[2] < tot/10. && unitVolumesHist[3]==0) return "o";
	if(unitVolumesHist[1] < tot/10.*5 && unitVolumesHist[2] < tot/20.*3 && unitVolumesHist[3] < tot/20.) return "-";
	return "--";
}

public list[int] getUnitVolumesHist(list[int] unitVolumes){
	list[int] unitVolumesHist =[0,0,0,0]; 
	for(unitVolume <- unitVolumes){
		if(unitVolume < 11) unitVolumesHist[0] += 1;
		if(10 < unitVolume && unitVolume < 21) unitVolumesHist[1] += 1;
		if(20 < unitVolume && unitVolume < 51) unitVolumesHist[2] += 1;
		if(unitVolume > 50) unitVolumesHist[3] += 1;
	}
	return unitVolumesHist;
}

public int calcTotalVolume(set[loc] locations) {
	int volume = 0;
	for(location <- locations) 
		volume += calcVolume(location);
	return volume;
}

public list[int] calcIndividualVolume(set[loc] locations) {
// Calculates the volume of code at each of the given locations (also works for methods).
	list[int] volumes = [];
	for(location <- locations){
		volumes += [calcVolume(location)];
	}
	return volumes;
}

public list[str] calcVolumeMethod(loc location) {
    str filteredContent = removeUnwantedStrings(readFile(location));
    filteredContent = removeUnwantedComments(filteredContent);
    filteredContent = replaceAll(filteredContent," ","");
    filteredContent = replaceAll(filteredContent,"\t","");
    filteredContent += "\r\n";
    
	return split("\n", filteredContent);
}


public int calcVolume(loc location){
    // remove white space
    str file = removeUnwantedStrings(readFile(location));
    file = removeUnwantedComments(file);
    file = replaceAll(file," ","");
    file = replaceAll(file,"\t","");
    file += "\r\n";
	int n = 0;
	int newline = 0;
 	for(int i <- [0 .. size(file)-1]){
  		if(file[i]+file[i+1] =="\r\n"){
   			str line = substring(file,newline,i);
   			newline = i+2;
   			
   			if(size(line)>0) n+=1;

			//if(size(line)>0) {n+=1; iprintln(toString([n])+"ADDED "+line);
			//}else{iprintln(toString([n])+"NOT "+line);}
		}
	}
	return n;
}

//src: https://stackoverflow.com/questions/40257662/how-to-remove-whitespace-from-a-string-in-rascal
public str removeUnwantedComments(str content) {
//19/11: Fixed, removed whitespace, left comments
	return visit (content) { 
		case /\/\*[\s\S]*?\*\/|\/\/.*/ => "" // removes comments, partial thanks to Rocco
	}
}

public str removeUnwantedStrings(str content) {
// removes string content
// doesnt work for |java+compilationUnit:///src/smallsql/database/StoreImpl.java|, line 73
	return visit (content) { 
		case /\".*\"|\'.*\'/ => "\"STRING\""
	}
}
