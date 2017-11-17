module metrics::uCompl

import IO;
import List;
import String;
import Set;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;

public list[int] calcComplexity(loc project){
// Spits out a list with the cyclomatic complexity of every method in the given project.
	M3 m3project = createM3FromEclipseProject(project);
	m3methods =  methods(m3project);
	incrementer = 0;
	list[int] ifsPerMethod = [];
	for(oneMethod <- m3methods){
		//incrementer +=1; // Diagnostics code, to pick out specific methods and analyze it more closely 
		//if(incrementer == 25) ifsPerMethod += countIfs(split("\r\n",readFile(oneMethod)));
		ifsPerMethod += countIfs(split("\r\n",readFile(oneMethod)));
	}	
	return ifsPerMethod;
}

public int countIfs(list[str] file){
// thanks to https://github.com/PhilippDarkow/rascal/blob/master/Assignment1/src/count/CountIf.rsc
// Is called by calcComplexity, and adds 1 to the cyclomatic complexity whenever a node with two edges is detected
	n = 1;
  	for(s <- file)
    	if(/if\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /while\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /case(\s|\{)/ := s
    			|| /do(\s|\{)/ := s
    			|| /for\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /catch\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /conditional\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /infix\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
    			|| /foreach\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s)
      		n +=1;
  	return n; 
}