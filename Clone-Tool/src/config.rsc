module config

public loc getProject(int number)
{
	switch (number) {
		case 1: return |project://examples-testing|;
		case 2: return |project://smallsql0.21_src|;
		case 3: return |project://hsqldb-2.3.1|;
	}
}

public int getMassThreshold() {
	return 2;
}

public int getSimilarityThreshold() {
	return 2;
}