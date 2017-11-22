module scores
 
import IO;
import List;
import String;
import DateTime;
import Set;
import util::Math;
 
 public real calculatePercentage(int base, int total){
	percentage = toReal(base)/toReal(total)*100;
	return percentage;
}

public real scoreToRank(str score) {
	// reader score amount of lines * 1000 
	if(score == "++") {
		return 2.0;
	} else if(score == "+") {
		return 1.0;
	} else if(score == "o") {
		return 0.0;
	} else if(score == "-") {
		return -1.0;
	}
	return -2.0;
}

public str rankToScore(real rank) {
	if(rank == 2.0) {
		return "++";
	} else if(rank == 1.0) {
		return "+";
	} else if(rank == 0.0) {
		return "o";
	} else if(rank == -1.0) {
		return "-";
	}
	return "--";
}
