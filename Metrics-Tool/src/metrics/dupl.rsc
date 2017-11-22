module metrics::dupl

import lang::java::jdt::m3::Core;
import String;
import IO;
import Set;
import List;
import metrics::vol;

/**
 * Metric: Duplication
 * Summary: Code duplication is defined in this project as all code
 			that is seen in more than one cases in code blocks of 6
 			lines or more. We start by filtering out all the methods that
 			are shorter than 6 lines in the various classes within the
 			project. 
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


public list[lrel[str, loc]] getCodeBlocks(list[loc] methods) {

	list[lrel[str, loc]] codeBlocks = [];
	//foreach method in the list of methods
	for(method <- methods) {
		
		//get lines of method
		list[str] lines = calcVolumeMethod(method);
		
		//if the method has less than 6 lines of actual code, skip it
		int methodSize = size(lines);
		if(methodSize < 6) {
			continue;
		}
		
		//create a list of tuples containing, the line, and it's method
		lrel[str, loc] codeLines = zip(lines, [method | _ <- upTill(methodSize)]);
		//add this list to a parent list
		codeBlocks += [[a,b,c,d,e,f] | [_*,a,b,c,d,e,f,_*] := codeLines];
	}
	return codeBlocks;
}

public int calcDuplication(list[loc] methods) {
	//A set of tuples in line which will represent the duplicates
	set[tuple[str,loc]] duplicates = {};
	//A map which refers to the unique lines handled
	map[list[str], lrel[str, loc]] handled = ();	
	//The blocks of code representing methods larger than 6 lines
	list[lrel[str, loc]] codeBlocks = getCodeBlocks(methods);
		
	//For each codeblock in the project
	for(block <- codeBlocks) {
		// get a list of strings representing the actual lines of code for each block
		list[str] lines = [line | <line,_> <- block];
		println("lines: <lines>");
		//if these lines are in the handled lines, so the collection of lines already seen in the project
		if(lines in handled) {
			//we add the codelines with data(tuple) to the duplicates set
			duplicates += {codeLine | codeLine <- block};
			
			
			duplicates += {initCodeLine | initCodeLine <- handled[lines]};
		} else {
			handled[lines] = block;
		}
	}	
	
	
	return size(duplicates);
}







