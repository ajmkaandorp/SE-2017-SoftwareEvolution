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
	lrel[node, node] subTreePairs = [];
	// Step 2
	//##############################################################
	
	//node: Values of type node represent untyped trees
	//bucket: 
	map[node, list[node]] buckets = ();
	bool x = true;
	
	visit(ast) {
		case node i: {
				//if total mass of node is greater than the threshold
			    int mass = getMass(i);
				if (mass >= getMassThreshold()) {
					//if bucket is already defined
					if (buckets[i]?) {
						buckets[i] += i;
					//if bucket is not defined yet
					} else {
						buckets[i] = [i];
					}
				}
		}
	}
	
	for(bucket <- buckets) {
		subTreePairs
		for(<i,j> <- subTreePairs){
			
		}
	}
	
	//
	// Step 3
	//##############################################################
	
	
	
	
	
		
	return [];
}


public lrel[node, node] combinations(list[node] nodes) {
	
}

private bool CompareTree(node i, node j) {
	return true;
}

private int getMass(node i) {
	int mass = 0;
	visit(i) {
		case node _ : mass += 1;
	}
	return mass;
}