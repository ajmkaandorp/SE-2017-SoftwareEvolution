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
	lrel[loc, int, str] duplicates = [];
	int i = 0;
	
	//foreach method in the list of methods
	for(method <- methods) {
		list[str] lines = calcVolume(method);
		println(<size(lines)	>);
		//if the method has less than 6 lines of actual code, skip it
		if(size(lines) < 6) {
			continue;
		}
		int i = i + 1;
		println("<i>");
	}
	
	return i;
}

