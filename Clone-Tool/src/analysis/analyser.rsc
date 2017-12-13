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
	map[node, lrel[node, loc, int]] buckets = ();
	map[node, loc] ignoredBuckets = ();
	
	bool x = true;
	int similarityThreshold = getSimilarityThreshold();
	
	visit(ast) {
		case node i: {
				loc location = getNodeLocation(i, projectLocation);
				if(ignoredBuckets[i]? && ignoredBuckets[i] == location);
				else {
				//if total mass of node is greater than the threshold
			    int mass = getMass(i);
				if (mass >= getMassThreshold()) {
					//hash node to bucket
					if (buckets[i]?) {
						buckets[i] += <i,location, mass>;
					}
					else {
						buckets[i] = [<i,location, mass>];
						ignoredBuckets[i] = location;
						visit(i){
							case node j: 
								ignoredBuckets[j] =  location;
						}
					}			
				}	
			}
		}
	}	
	
	println(size(buckets));
	println(size(ignoredBuckets));
	
	
	
	// Step 3
	//##############################################################	
	//for(bucket <- buckets) {
	//	
	//	lrel[node, int] subTrees = [];
	//	
	//	
	//	for(<_,_> <- bucket) {
	//		for(<j,_,_> <- bucket) {
	//			if(compareTree(i,j) > similarityThreshold) {
	//				println(i);
	//			}
	//		}
	//	}
		
		//If CompareTree(i,j) > SimilarityThreshold
		//if(size(buckets[bucket]) > similarityThreshold) {
		//	
		//	for(treeRelation <- getTreeRelations(buckets, bucket))
		//	{
		//		num similarity = calculateSimilarity(treeRelation[0][0], treeRelation[1][0])*1.0;
		//		if(similarity >= similarityThreshold) {
		//			println("");		
		//		}
		//	
		//	}
		//}
		//println("test");
	//}
	return [];
}

public num calculateSimilarity(node i, node j) {
	return 1;
}

public lrel[tuple[node,loc], tuple[node,loc]] getTreeRelations(map[node, lrel[node, loc]] buckets, map[node, lrel[node,loc]] bucket) {

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

public lrel[node, node] combinations(list[node] nodes) {
	
}

private bool CompareTree(node i, node j) {
	return true;
}

private int getMass(node i) {
	int mass = 0;
	visit(i) {
		case node j : mass += 1;
	}
	return mass;
}