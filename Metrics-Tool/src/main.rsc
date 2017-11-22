module main

import IO;
import List;
import String;
import DateTime;
import Set;

//import metrics
import metrics::vol;
import metrics::dupl;
import metrics::uCompl;
import metrics::uSize;
//import scores
import scores;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public loc getProject(int number)
{
	switch (number) {
		case 1: return |project://examples-testing|;
		case 2: return |project://smallsql0.21_src|;
		case 3: return |project://hsqldb-2.3.1|;
	}
}
 
// Main method
void main() {
	// start the test
	println("Starting SIG test at: " + printTime(now(), "HH:mm:ss"));
	
	// get the m3 model
	loc projectLocation = getProject(2);
	M3 model = getM3Model(projectLocation);
	
	// get the AST model
	set[Declaration] dec = createAstsFromEclipseProject(projectLocation, false);
	
	//assessJavaFile(readJavaFile());
	
	//get classes
	//list[loc] classes = getClasses(model);
	//println("--There are <amountOfClasses(classes)> classes in this project.");
	
	println("------------------------------------------------------------------------");
	println("Calculating Volume at: " + printTime(now(), "HH:mm:ss"));
	int volume = calcTotalVolume(files(model));
	str volumeScore = getVolumeScore(volume);
	println("The total number of lines: <volume> gives this project a score of <volumeScore>");
	println("Ended Calculating Volume at: " + printTime(now(), "HH:mm:ss"));
	
	//Unit volume
	println("------------------------------------------------------------------------");
	println("Calculating Unit Size at: " + printTime(now(), "HH:mm:ss"));
	list[int] unitVolume = calcIndividualVolume(methods(model));
	println("The method volumes give this project a score of <getUnitVolumeScores(unitVolume)>");
		
	//Unit complexity
	println("------------------------------------------------------------------------");
	println("Calculating Unit Complexity at: " + printTime(now(), "HH:mm:ss"));
	complexities = calcComplexity(methods(model));
	println("	The method complexity score gives this project a score of <calcCCScore(complexities)>");
	
	println("------------------------------------------------------------------------");
	println("Calculating Duplication at: " + printTime(now(), "HH:mm:ss"));
	int duplication = calcDuplication(getMethods(model));
	println("Method blocks : <duplication>");
	real percentage = calculatePercentage(duplication, volume);
	println("percentage: <percentage>");
	str duplicationScore = getDuplicationScore(toInt(percentage));
	println("Duplication score: <duplicationScore>");
	println("Ended Calculating Duplication at: " + printTime(now(), "HH:mm:ss"));
	
	
	
	println("SIG test ended at: " + printTime(now(), "HH:mm:ss"));
	
}

// get a list of all classes within the project
public list[loc] getClasses(M3 model) {
	return toList(classes(model));
}
// get the amount of classes within the project
public int amountOfClasses(list[loc] classes) {
	return size(classes);
}

// get a list of the methods within the project
public list[loc] getMethods(M3 project) {
	return toList(methods(project));
}
// get the amount of methods within the project
public int amountOfMethods(list[loc] methods) {
 	return size(methods);
}



//get the contents of a file
public str fileContent(loc file) {
	return readFile(file);
}

//remove comments from the contents of a file
public str removeComments(str text) {
	
	return replaceAll(text, "//.*|/\\*((.|\\n)(?!=*/))+\\*/", "");
}



//public list[str] getFileContent(loc file) {
//	content = readFile(file);
//}

// Create a M3 model
public M3 getM3Model(loc location) {
	return createM3FromEclipseProject(location); 
}

