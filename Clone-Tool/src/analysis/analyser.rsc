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


public map[node, lrel[node, loc, int]] getClones(loc projectLocation, set[Declaration] ast, bool printbool = false) {
// Generates a map of clones within a project, but without clones that only occur within bigger clones.
	// Source for our approach:
	//http://leodemoura.github.io/files/ICSM98.pdf

	rel[node, int] bucketMass = {}; // Logs the mass of all the nodes.
	map[node, lrel[node, loc, int]] buckets = ();
	
	//println("##########################################################################");
	//println("Started hashing the subtrees to buckets at <(printTime(now()))>");
	
	bool printSwitch = false; // An on-off switch for printing the properties of a node, for diagnostics purposes
	
	// Builds a map of the entire AST of a project. Nodes are the keys, clone nodes have the same key,
	// which have one value for each time the node occurs.
	visit(ast) {
		case node i: {
			//if total mass of node is greater than the threshold
		    int mass = getMass(i);
			if (mass >= getMassThreshold()) {
			//https://stackoverflow.com/questions/47555798/comparing-ast-nodes
			// Since the locations of nodes are unique, the locations must be dumped before the nodes can be checked for being clones.
					node j = unsetRec(i);
				// buckets = addNodeToMap(buckets, bucketMass, i, mass, projectLocation);
					loc location = getNodeLocation(i, projectLocation);
					
					if (buckets[j]?) {
						buckets[j] += <i,location, mass>;
					} else {
						buckets[j] = [<i,location, mass>];
						
						if(printSwitch) { // Can be used to print properties of a node, for diagnostics purposes
							println(buckets[j]);
							printSwitch = false;
						}
					}
					bucketMass += <i, mass>;
			}	
		}
	}
	
	if(printbool)println("Number of unique nodes: <size(buckets)>");
	//
	//println("Ended hashing the subtrees to buckets at <(printTime(now()))>");
	//println("##########################################################################");
	//println("Started clone detection at <(printTime(now()))>");
	
	// Step 3
	//##############################################################	

	map[node, lrel[node, loc, int]] clones = ();	
	set[node] childsToKick = {};
	// Creates a new map, only containing clone nodes. Creates a set to later kick out redundant clones.
	for(bucket <- buckets) {
		if(size(buckets[bucket])>1) { // Picks out only the clone nodes.			
			clones[bucket] = buckets[bucket]; // Building of new map.
			visit(bucket) { // Building of kick set. Duplicates are automatically prevented because it is a set.
				case node i: if(i!=bucket && buckets[i]? && size(buckets[bucket]) == size(buckets[i])) {childsToKick+=i;}
			}
		}
	}

	// Kicks out clones that are only present inside of other, bigger clones.
	for(child <- childsToKick){
		clones = delete(clones,child);
	}

	return clones;
}

//public set[Declaration] type2Ast(set[Declaration] ast){
//// A start for the type 2 clone detecting, but it doesnt work yet
////public list[node] type2Ast(set[Declaration] ast){
//	node j = ""(); 
//	visit(ast){
//		//case node i: if(size(getChildren(i)) == 0){
//		//	i = ""();
//			//if(j!= ""()){return [i,j];}
//			//j = i;			
//			//iprintln(i);
//			//println();
//			//i.src = |unknown:///|;
//			//i.name = |unresolved:///|;
//			//i.decl = |unresolved:///|;
//			//i.typ = \any();
//			//i.modifiers = [];
//			//i.messages = [];
//			//}
//		//case /Type i => /Type void()
//		case /Expression i => ...
//		//case /Type i : iprintln(i);
//	}
//	
//	return ast;
//}


public str getJsonStr(map[node, lrel[node, loc, int]] clones) {
// Writes the found clones into a string with a format (.json) from which the visualisation can be initialized.
// This is done in two parts: clone pairs and files. Clone pairs will go into the string after files, 
// but must be parsed first to find the locations that must go into the first part of the string.
	str JstringEnd = "\t\"clone_pairs\": [";
	int pairNum = 1;
	set[loc] filesSet = {};
	bool putcomma = false;
	
	for(clone<-clones){ // Writes the clone pairs, with their properties.
		if(putcomma==true){JstringEnd+=",\r\n";}else{putcomma = true;} // Adds commas after the } that closes each entry, but not after the last one.
		fileLoc = clones[clone][0][1];
		filesSet += toLocation(fileLoc.uri); // Saves locations of clones, so that these can be written as well, later.
		println(fileLoc);
		
		if(fileLoc == |unknown:///|(1,1,<1,1>,<11,1>)) {
			JstringEnd += "\r\n\t\t{\r\n\t\t\t\"id\": \"clone_<pairNum>\",\r\n\r\n\t\t\t\"clone_type\": \"type-1\",\r\n\r\n\t\t\t\"origin\": {\r\n\t\t\t\t\"file\": \"<fileLoc.file>\",\r\n\t\t\t\t\"start_line\": \"<fileLoc.begin.line>\",\r\n\t\t\t\t\"end_line\": \"<fileLoc.end.line>\",\r\n\t\t\t\t\"source_code\": \"\"\r\n\t\t\t}";
		} else {
			JstringEnd += "\r\n\t\t{\r\n\t\t\t\"id\": \"clone_<pairNum>\",\r\n\r\n\t\t\t\"clone_type\": \"type-1\",\r\n\r\n\t\t\t\"origin\": {\r\n\t\t\t\t\"file\": \"<fileLoc.file>\",\r\n\t\t\t\t\"start_line\": \"<fileLoc.begin.line>\",\r\n\t\t\t\t\"end_line\": \"<fileLoc.end.line>\",\r\n\t\t\t\t\"source_code\": \"<escapeSourceCode(readFile(fileLoc))>\"\r\n\t\t\t}";
		}
		int cloneNum = 1; // This variable cycles the clone names in the string, to prevent duplicate names.
		
		JstringEnd += ",\r\n\t\"clones\": [";
		for(i<-[1..size(clones[clone])]){
			cloneLoc = clones[clone][i][1];
			filesSet += toLocation(cloneLoc.uri); // Also saves locations of clones, so that these can be written as well, later.
			
			if(fileLoc == |unknown:///|(1,1,<1,1>,<11,1>)) {
				JstringEnd += "\r\n\r\n\t\t\t{\r\n\t\t\t\t\"file\": \"<cloneLoc.file>\",\r\n\t\t\t\t\"start_line\": \"<cloneLoc.begin.line>\",\r\n\t\t\t\t\"end_line\": \"<cloneLoc.end.line>\",\r\n\t\t\t\t\"source_code\": \"\"\r\n\t\t\t}";
			} else {
				try
					JstringEnd += "\r\n\r\n\t\t\t{\r\n\t\t\t\t\"file\": \"<cloneLoc.file>\",\r\n\t\t\t\t\"start_line\": \"<cloneLoc.begin.line>\",\r\n\t\t\t\t\"end_line\": \"<cloneLoc.end.line>\",\r\n\t\t\t\t\"source_code\": \"<escapeSourceCode(readFile(cloneLoc))>\"\r\n\t\t\t}";
				catch IO(msg): println("This did not work: <msg>");
			}
			cloneNum +=1;
			if(cloneNum != size(clones[clone])) {
				JstringEnd += ",";
			}
		}
		
		JstringEnd += "\r\n\t]\r\n\r\n";
		JstringEnd += "\r\n\t\t}";
		pairNum+=1;
	}
	JstringEnd += "\r\n\t]\r\n}";
	
	// Writes the files in which clones occur, and their paths.
	putcomma = false;
	str JstringStart = "{\r\n\t\"summary\": {\r\n\t\t\"project_name\": \"testproject\"\r\n\t},\r\n\r\n\t\"directories\": [\r\n\t\t\"/<getOneFrom(filesSet).authority>/\"\r\n\t],\r\n\r\n\t\"files\": [";
	for(fileLoc <- filesSet) {
		if(putcomma == true){JstringStart += ",\r\n";}else{putcomma = true;} // Adds commas after the } that closes each entry, but not after the last one.
		JstringStart += "\r\n\t\t{\r\n\t\t\t\"name\": \"<fileLoc.file>\",\r\n\t\t\t\"dir\": \"/<fileLoc.path[1..size(fileLoc.path)-size(fileLoc.file)-1]>\"\r\n\t\t}";
	}
	JstringStart += "\r\n\t],\r\n\r\n";
	
	return JstringStart+JstringEnd;
}

private str escapeSourceCode(str code) {
    map[str, str] replaceMap = (
        "\"": "\\\"", 
        "\\": "\\\\", 
        "\n": "\\n", 
        "\b": "\\b", 
        "\f": "\\f", 
        "\t": "\\t", 
        "\r": "\\r",
        "\\s": "\\\\s"
    );
    return escape(code, replaceMap);
}


public loc getNodeLocation(node i, loc location) {		
		//http://tutor.rascal-mpl.org/Rascal/Libraries/analysis/m3/AST/src/src.html
		if (Declaration d := i && d.src?) {
				location = d.src;
		} else if (Statement s := i && s.src?) {
				location = s.src;	
		} else if (Expression e := i && e.src?) {
				location = e.src;
		} else {
				location = getUnknownLoc();
		}
		return location;
}

public loc getUnknownLoc() { 
 	loc unknown = |unknown:///|;
	unknown = unknown[offset = 1];
	unknown = unknown[length = 1];
	unknown = unknown[begin = <1,1>];
	unknown = unknown[end = <11,1>];
	return unknown;
}

private int getMass(node i) {
	int mass = 0;
	visit(i) {
		case node _ : mass += 1;
	}
	return mass;
}