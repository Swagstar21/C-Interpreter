import java.io.*;
import java.util.*;
 
public class Main {
	public static Integer returnCode = 0;
	public static Integer errorLine = -1;

  public static void main (String[] args) throws IOException {
    HelloLexer l = new HelloLexer(new FileReader(args[0]));

 	PrintWriter arbore = new PrintWriter("arbore", "UTF-8");
 	PrintWriter output = new PrintWriter("output", "UTF-8");

    l.yylex();

    l.root.incrementLevel(0);
    arbore.println(l.root.show());
    arbore.close();

    l.root.execute(l.variableNames, l.variableValues, l.declared);
    l.root.analyse(l.variableNames, l.variableValues, l.declared);

    if (returnCode == 0) {
    	for (int i = 0; i < l.variableNames.size(); i++)
    		if (l.declared.get(i) == 1)
    			output.println(l.variableNames.get(i) + "=" + l.variableValues.get(i));
    		else output.println(l.variableNames.get(i) + "=null");
    }
    else if (returnCode == 1)
    	output.println("UnassignedVar " + Integer.toString(errorLine));
    else output.println("DivideByZero " + Integer.toString(errorLine));
    
	
 	output.close();
  }
}