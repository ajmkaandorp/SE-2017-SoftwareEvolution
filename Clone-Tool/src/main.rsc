module main

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;
import DateTime;
import Set;
import Map;
import analysis::analyser;
import visualization::visualizer;
import config;

void main() {
	// start the test
	println("Starting clone detection at : " + printTime(now(), "HH:mm:ss"));
	
	// get the m3 model
	loc projectLocation = getProject(2);
	M3 model = getM3Model(projectLocation);
	set[Declaration] ast = getAST(projectLocation);
	int cloneType = 1;
	
	//get clones of type 1
	println("Start detection of clone type <cloneType>");
	map[node, lrel[node, loc, int]] clones = ();
	clones = getClones(projectLocation, ast, printbool = true);
	//if(cloneType == 1){clones = getClones(projectLocation, ast);
	//}else{clones = getClones(projectLocation, type2Ast(ast));}
	//println("Ended clone detection at <(printTime(now()))>");
	//println("Number of clones: <size(clones)>");

}

void writeJsonToFile() {
// Generates a string containing information about clones and their locations, and writes it to a .json file.
// This file can then be used to generate a visualization of the clones in a project.
 	loc projectLocation = getProject(2);
	M3 model = getM3Model(projectLocation);
	set[Declaration] ast = getAST(projectLocation);
	int cloneType = 1;
	
	map[node, lrel[node, loc, int]] clones = getClones(projectLocation, ast);
	//map[node,str] cloneStrs = getCloneStrs(clones);
	str jsonStr = getJsonStr(clones);
	writeFile(|project://Clone-Tool/src/analysis/testfile.json|,jsonStr);
	//println("written to file");
}

// Create a M3 model
private M3 getM3Model(loc location) {
	return createM3FromEclipseProject(location); 
}

private set[Declaration] getAST(loc location) {
	return createAstsFromEclipseProject(location, false);
}
