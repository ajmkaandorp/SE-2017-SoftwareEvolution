module main

import IO;
import List;
import String;
import DateTime;
import Set;
//importing metrics
import Metrics::vol;
import Metrics::uSize;
import Metrics::uCompl;
import Metrics::dupl;

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public loc getProject()
{
	return |project://smallsql0.21_src|;
}

// Main method
void main() {
	
	
	// start the test
	println("Starting SIG test at: " + printTime(now(), "HH:mm:ss"));
	
	// get the m3 model
	loc projectLocation = getProject();
	M3 model = getM3Model(projectLocation);
	
	// get the AST model
	set[Declaration] dec = createAstsFromEclipseProject(projectLocation, false);
	
	//assessJavaFile(readJavaFile());
	
	//get classes
	list[loc] classes = getClasses(model);
	
	//Volume
	println("Calculating Volume at: " + printTime(now(), "HH:mm:ss"));
	println("--There are <amountOfClasses(classes)> classes in this project.");
	
	
	
	println("Calculating Unit Size at: " + printTime(now(), "HH:mm:ss"));
	
	
	println("Calculating Unit Complexity at: " + printTime(now(), "HH:mm:ss"));
	
	println("Calculating Duplication at: " + printTime(now(), "HH:mm:ss"));
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

