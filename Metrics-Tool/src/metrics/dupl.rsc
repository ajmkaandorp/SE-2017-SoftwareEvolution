module metrics::dupl

import lang::java::jdt::m3::Core;
import String;
import IO;

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

//public int methodDuplicates(list[loc] methods) {
//	//foreach method in the list of methods
//	for(method <- methods) {
//		//if the method has less than 6 lines of actual code, skip it
//		if(amountofLines(method) < 6) {
//			continue;
//		}
//		
//	}
//	return duplicates;
//}

