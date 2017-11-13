module metrics::vol

import lang::java::jdt::m3::Core;
import String;
import IO;

public str getVolumeScore(int amountLines) {
	// reader score amount of lines * 1000 
	if(amountLines <= 66000) {
		return "++";
	} else if(amountLines <= 246000) {
		return "+";
	} else if(amountLines <= 665000) {
		return "o";
	} else if(amountLines <= 1310000) {
		return "-";
	}
	return "--";
}
