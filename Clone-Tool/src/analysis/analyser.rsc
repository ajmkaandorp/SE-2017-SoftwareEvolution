module analysis::analyser

import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;
import DateTime;
import Set;
import Node;
import config;


public M3 project;
public set[Declaration] ast;


public lrel[loc,loc] getClones(int cloneType, loc projectLocation, set[Declaration] ast) {
	//Figure 1:
	//http://leodemoura.github.io/files/ICSM98.pdf
	
	// Step 1
	//##############################################################
	lrel[loc,loc] clones = [];
	
	// Step 2
	//##############################################################
	
	//node: Values of type node represent untyped trees
	//bucket: 
	map[node, list[node]] buckets = ();
	
	visit(ast) {
		case node i: {
				if (getMass(i) >= getMassThreshold()) {
					if (buckets[i]?) {
						buckets[i] += i;
					} else {
						buckets[i] = [i];
				}
				}
		}
	}
	
	// Step 3
	//##############################################################
	
	
	
	
		
	return [];
}

private int getMass(node i) {
	int mass = 0;
	visit(i) {
		case node _ : mass += 1;
	}
	return mass;
}