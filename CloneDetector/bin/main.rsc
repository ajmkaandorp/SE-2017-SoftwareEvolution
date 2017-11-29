module main

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;
import DateTime;
import Set;

public loc getProject(int number)
{
	switch (number) {
		case 1: return |project://examples-testing|;
		case 2: return |project://smallsql0.21_src|;
		case 3: return |project://hsqldb-2.3.1|;
	}
}

void main() {
	// start the test
	println("Starting clone detection at : " + printTime(now(), "HH:mm:ss"));
	
	// get the m3 model
	loc projectLocation = getProject(2);
	M3 model = getM3Model(projectLocation);
	set[Declaration] ast = getAST(projectLocation);
	
	}

// Create a M3 model
private M3 getM3Model(loc location) {
	return createM3FromEclipseProject(location); 
}

private set[Declaration] getAST(loc location) {
	return createAstsFromEclipseProject(location, false);
}


