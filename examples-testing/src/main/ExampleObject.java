package main;

public class ExampleObject {

	// Comment 1
	
	private String title;
	private int age;
	
	public ExampleObject(String title, int age) {
		this.title = title;
		this.age = age;
	}
	/**
	 * Comment 2
	 * ---
	 * ---
	 */
	
	public String gettitle() {
		return title;
	}
	
	public int getAge() {
		return age;
	}

}
