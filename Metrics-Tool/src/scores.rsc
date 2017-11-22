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