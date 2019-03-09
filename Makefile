build:
	jflex Hello.flex
	javac *.java
run:
	touch input
	touch arbore
	touch output
	java Main input
clean:
	rm HelloLexer.java
	rm *.class
	rm arbore
	rm output