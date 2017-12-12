module main

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;
import DateTime;
import Set;

import analysis::analyser;
import visualization::visualizer;
import config;

void main() {
	// start the test
	println("Starting clone detection at : " + printTime(now(), "HH:mm:ss"));
	
	// get the m3 model
	loc projectLocation = getProject(1);
	M3 model = getM3Model(projectLocation);
	set[Declaration] ast = getAST(projectLocation);
	int cloneType = 1;
	
	//get clones of type 1
	println("Start analyzation of type <cloneType>");
	lrel[loc,loc] clones = getClones(cloneType, projectLocation, ast);
	
	
}

// Create a M3 model
private M3 getM3Model(loc location) {
	return createM3FromEclipseProject(location); 
}

private set[Declaration] getAST(loc location) {
	return createAstsFromEclipseProject(location, false);
}
