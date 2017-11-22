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
 			that is seen in more than one cases in code fragments of 6
 			lines or more. We start by filtering out all the methods that
 			are shorter than 6 lines in the various classes within the
 			project. 
 			
 	
 */
 
 
 //Document guidelines:
 //Document has alternatives, has design decisions is measurable etc
 //Check the validity
 //Find a way to check your code
 // Make claims, test your claims
 // Make an evaluation
 
 
 /*
 The first thing that needs to happen for the detection of duplicates in 
 the project, is that these fragments need to be formed including both the lines of code
 that are in the method as well as the corresponding method location.
  
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


public list[lrel[str, loc]] getCodeFragments(list[loc] methods) {
	list[lrel[str, loc]] codeFragments = [];
	//foreach method in the list of methods
	for(method <- methods) {
		
		//get lines of method
		list[str] lines = calcVolumeMethod(method);
		
		//if the method has less than 6 lines of actual code, skip it
		int methodSize = size(lines);
		if(methodSize < 6) {
			continue;
		}
		
		//create a list of tuples containing, the lines, and it's method location
		lrel[str, loc] codeLines = zip(lines, [method | _ <- upTill(methodSize)]);
		//add this list the parent list, matching
		codeFragments += [[l1,l2,l3,l4,l5,l6] | [_*,l1,l2,l3,l4,l5,l6,_*] := codeLines];
	}
	return codeFragments;
}

public int calcDuplication(list[loc] methods) {
	//A set of tuples in line which will represent the duplicates
	set[tuple[str,loc]] duplicates = {};
	//A map which refers to the unique lines handled
	map[list[str], lrel[str, loc]] handled = ();	
	//The fragments of code representing methods larger than 6 lines
	list[lrel[str, loc]] codeFragments = getCodeFragments(methods);
		
	//For each codeFragment in the project
	for(codeFragment <- codeFragments) {
		// get a list of strings representing the actual lines of code for each fragment
		list[str] lines = [line | <line,_> <- codeFragment];
		//if these lines are in the handled lines, so the collection of lines already seen in the project
		if(lines in handled) {
			//we add the codelines with data(tuple) to the duplicates set
			duplicates += {codeLine | codeLine <- codeFragment};
			
			
			
		} else {
			// if the lines are not in the handled lines and thus are unique, we add these to them
			handled[lines] = codeFragment;
		}
	}	
	return size(duplicates);
}







