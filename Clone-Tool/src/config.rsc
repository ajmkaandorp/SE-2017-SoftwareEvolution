module config

public loc getProject(int number)
{
	switch (number) {
		case 1: return |project://examples-testing/src/|;
		case 2: return |project://smallsql0.21_src/database|;
		case 3: return |project://hsqldb-2.3.1/src|;
	}
}

public int getMassThreshold() {
	return 4;
}

public int getSimilarityThreshold() {
	return 2;
}