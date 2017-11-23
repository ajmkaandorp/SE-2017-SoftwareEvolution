module metrics::uCompl

import IO;
import List;
import String;
import Set;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;

public str calcCCScore(list[int] complexities){
	riskScores = calcCCRiskScores(complexities);
	int tot = sum(riskScores);
	if(riskScores[1] < tot/4. && riskScores[2]==0 && riskScores[3]==0) return "++";
	if(riskScores[1] < tot/10.*3 && riskScores[2] < tot/20. && riskScores[3]==0) return "+";
	if(riskScores[1] < tot/10.*4 && riskScores[2] < tot/10. && riskScores[3]==0) return "o";
	if(riskScores[1] < tot/10.*5 && riskScores[2] < tot/20.*3 && riskScores[3] < tot/20.) return "-";
	return "--";
}

public list[int] calcCCRiskScores(list[int] complexities){
// Bins the calculated CC scores to a risk catagory list.
	list[int] riskScores =[0,0,0,0]; 
	for(complexity <- complexities){ // Why not use switch here?
		if(complexity < 11) riskScores[0] += 1;
		if(10 < complexity && complexity < 21) riskScores[1] += 1;
		if(20 < complexity && complexity < 51) riskScores[2] += 1;
		if(complexity > 50) riskScores[3] += 1;
	}
	return riskScores;
}

public list[int] calcComplexity(set[Declaration] ast){
// Spits out a list with the cyclomatic complexity of every method in the given project.
	
	list[int] ifsPerMethod = [];
	x = {m | /Declaration m := ast, m is method};
	for(item <- x){
		ifsPerMethod += [calcCC(item)];
	}
	return ifsPerMethod;
}

public int calcCC(Declaration impl) {

    int result = 1;
    visit (impl) {
        case \if(_,_) : result += 1;
        case \if(_,_,_) : result += 1;
        case \case(_) : result += 1;
        case \do(_,_) : result += 1;
        case \while(_,_) : result += 1;
        case \for(_,_,_) : result += 1;
        case \for(_,_,_,_) : result += 1;
        case foreach(_,_,_) : result += 1;
        case \catch(_,_): result += 1;
        case \conditional(_,_,_): result += 1;
        case infix(_,"&&",_) : result += 1;
        case infix(_,"||",_) : result += 1;
    }
    return result;
}

//public list[int] calcComplexity(set[loc] m3methods){
//// Spits out a list with the cyclomatic complexity of every method in the given project.
//	list[int] ifsPerMethod = [];
//	for(oneMethod <- m3methods){
//		ifsPerMethod += countIfs(split("\r\n",readFile(oneMethod)));
//	}	
//	return ifsPerMethod;
//}
//
//public int countIfs(list[str] file){
//// thanks to https://github.com/PhilippDarkow/rascal/blob/master/Assignment1/src/count/CountIf.rsc
//// Is called by calcComplexity, and adds 1 to the cyclomatic complexity whenever a node with two edges is detected
//	n = 1;
//  	for(s <- file)
//    	if(/if\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /while\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /case(\s|\{)/ := s
//    			|| /do(\s|\{)/ := s
//    			|| /for\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /catch\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /conditional\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /infix\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s
//    			|| /foreach\(\w*(\)|\w*)(\s|[\,,\s,\.]*)/ := s)
//      		n +=1;
//  	return n; 
//}
