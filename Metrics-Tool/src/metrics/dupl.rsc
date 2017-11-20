module metrics::dupl

import lang::java::jdt::m3::Core;
import String;
import IO;
import List;
import metrics::vol;

/**
 * Metric: Duplication
 * Summary: Code duplication is defined in this project as all code
 			that is seen in more than one cases in code blocks of 6
 			lines or more. We start by filtering out all the methods that
 			are shorter than 6 lines in the various classes within the
 			project. After this we ignore leading spaces and compare these
 			lines to one another to find duplicates.
 */

public str getDuplicationScore(int percentage) {
	if(percentage <= 3) {
		return "++";
	} else if(percentage <= 5) {
		return "+";
	} else if(percentage <= 10) {
		return "o";
	} else if(percentage <= 20) {
		return "-";
	}
	return "--";
}

public int calcDuplication(list[loc] methods) {
	return getDuplicateLines(methods);
}


public int getDuplicateLines(list[loc] methods) {

	list[lrel[loc, int, str]] codeBlocks = [];
	lrel[loc, int, str] duplicateLines = [];
	int i = 0; 
	bool j = false;
	//foreach method in the list of methods
	for(method <- methods) {
		list[str] lines = calcVolumeMethod(method);
		//if the method has less than 6 lines of actual code, skip it
		int methodSize = size(lines);
		if(methodSize < 6) {
			continue;
		}
		lrel[loc, int, str] codeLines = zip([method | _ <- upTill(methodSize)], index(lines), lines);
		codeBlocks += [codeLines];
		
	}
	
	println(<codeBlocks>);
	
	return 1;
}

