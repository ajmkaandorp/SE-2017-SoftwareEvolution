module analysis::analyser


import lang::java::m3::AST;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

import IO;
import List;
import String;
import DateTime;
import Set;
import Map;
import Node;
import config;


public M3 project;
public set[Declaration] ast;


public lrel[loc,loc] getClones(loc projectLocation, set[Declaration] ast) {
	// Source for our approach:
	//http://leodemoura.github.io/files/ICSM98.pdf
	
	map[node, lrel[node, loc, int]] buckets = (); // Map of unique nodes
	map[node, loc] ignoredBuckets = (); // Map of nodes we do not wish to visit. These nodes have been determined to be clones, 
										//but are saved together with their location to differentiate them.
	
	visit(ast) {
		case node i: {
				loc location = getNodeLocation(i, projectLocation);
				
				if(ignoredBuckets[i]? && ignoredBuckets[i] == location); // If we want to ignore a node, we ignore it.
				else {
				//if total mass of node is greater than the threshold
			    int mass = getMass(i);
				if (mass >= getMassThreshold()) {
				
					// Mapping our nodes
					// If the node is already in our map, extend the value corresponding to the key.
					if (buckets[i]?) {
						buckets[i] += <i,location, mass>;
						
						ignoredBuckets[i] = location; // From hereon, ignore this node and its children, to avoid false positive clone detection
						visit(i){
							case node j: 
								ignoredBuckets[j] =  location;
						}
					}
					else { // Adds nodes that are not yet contained.
						buckets[i] = [<i,location, mass>];

					}			
				}	
			}
		}
	}	
	
	println(size(buckets));
	println(size(ignoredBuckets));
	return [];
}


public loc getNodeLocation(node i, loc location) {		
		//http://tutor.rascal-mpl.org/Rascal/Libraries/analysis/m3/AST/src/src.html
		if (Declaration d := i && d.src?) {
				location = d.src;
		} else if (Expression e := i && e.src?) {
				location = e.src;
		} else if (Statement s := i && s.src?) {
				location = s.src;
		}	
		return location;
}


private int getMass(node i) {
	int mass = 0;
	visit(i) {
		case node j : mass += 1;
	}
	return mass;
}