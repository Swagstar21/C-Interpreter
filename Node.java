import java.io.*;
import java.util.*;

public class Node {
	int level;
	int line;
	String type;
	Integer AValue;
	Boolean BValue;
	String Var;
	Node c1, c2, c3;
	int necesitaSecventa = 0;

	public Node(int level, String type) {
		this.level = level;
		this.type = type;
	}

	public void setValue(int value) {
		AValue = new Integer(value);
	}

	public void setValue(boolean value) {
		BValue = new Boolean(value);
	}

	public void setValue(String value) {
		Var = new String(value);
	}

	public String show() {
		String s1, s2, s3;
		if (c1 == null)
			s1 = "";
		else s1 = c1.show();
		if (c2 == null)
			s2 = "";
		else s2 = c2.show();
		if (c3 == null)
			s3 = "";
		else s3 = c3.show();
		String f = new String();
		if (type.equals("<IntNode>"))
			f = " " + Integer.toString(AValue);
		else if (type.equals("<BoolNode>"))
			f = " " + Boolean.toString(BValue);
		else if (type.equals("<VariableNode>"))
			f = " " + Var;
		String prefix = "";
		if (!type.equals("<MainNode>"))
			prefix += "\n";
		for (int i = 0; i < level; i++)
			prefix += "\t";
		return prefix + type + f + s1 + s2 + s3;
	}

	public void incrementLevel(int level) {
		this.level = level;
		if (c1 != null)
			c1.incrementLevel(level + 1);
		if (c2 != null)
			c2.incrementLevel(level + 1);
		if (c3 != null)
			c3.incrementLevel(level + 1);
	}

	public Object getValue(ArrayList<String> variableNames, 
		ArrayList<Integer> variableValues, ArrayList<Integer> declared) {
		if (type.equals("<IntNode>"))
			return AValue;
		else if (type.equals("<BoolNode>"))
			return BValue;
		else if (type.equals("<VariableNode>")) {
			for (int i = 0; i < variableNames.size(); i++) {
				if (variableNames.get(i).equals(Var) && declared.get(i) != -1) {
					return variableValues.get(i);
				}
			}
			Main.returnCode = 1;
			Main.errorLine = line;
			return null;
		}
		else if (type.equals("<PlusNode> +")) {
			Integer x = (Integer)(c1.getValue(variableNames, variableValues, declared));
			Integer y = (Integer)(c2.getValue(variableNames, variableValues, declared));
			if (x == null || y == null)
				return null;
			return new Integer(x.intValue() + y.intValue());
		}
		else if (type.equals("<DivNode> /")) {
			Integer x = (Integer)(c1.getValue(variableNames, variableValues, declared));
			Integer y = (Integer)(c2.getValue(variableNames, variableValues, declared));
			if (x == null || y == null)
				return null; 
			if (y.intValue() == 0) {
				Main.returnCode = 2;
				Main.errorLine = line;
				return null;
			}	
			return new Integer(x.intValue() / y.intValue());
		}
		else if (type.equals("<BracketNode> ()"))
			return c2.getValue(variableNames, variableValues, declared);
		else if (type.equals("<AndNode> &&")) {
			Boolean x = (Boolean)(c1.getValue(variableNames, variableValues, declared));
			Boolean y = (Boolean)(c2.getValue(variableNames, variableValues, declared));
			if (x == null || y == null)
				return null;
			return new Boolean(x.booleanValue() && y.booleanValue());
		}
		else if (type.equals("<GreaterNode> >")) {
			Integer x = (Integer)(c1.getValue(variableNames, variableValues, declared));
			Integer y = (Integer)(c2.getValue(variableNames, variableValues, declared));
			if (x == null || y == null)
				return null;
			return new Boolean(x.intValue() > y.intValue());
		}
		else if (type.equals("<NotNode> !")) {
			Boolean x;
			if (c1 == null)
				x = (Boolean)(c2.getValue(variableNames, variableValues, declared));
			else x = (Boolean)(c1.getValue(variableNames, variableValues, declared));
			if (x == null)
				return null;
			return new Boolean(!x.booleanValue());
		}
		return null;
	}

	public void execute(ArrayList<String> variableNames,
						ArrayList<Integer> variableValues, ArrayList<Integer> declared) {
		if (Main.returnCode != 0)
			return;
		if (type.equals("<MainNode>")) {
			if (c1 != null)
				c1.execute(variableNames, variableValues, declared);
			else if (c2 != null)
				c2.execute(variableNames, variableValues, declared);
		}
		else if (type.equals("<AssignmentNode> =")) {
			String x = c1.Var;
			Integer y = (Integer)c2.getValue(variableNames, variableValues, declared);
			if (y == null || x == null) {
				return;
			}
			for (int i = 0; i < variableNames.size(); i++) {
				if (variableNames.get(i).equals(x)) {
					variableValues.set(i, y);
					declared.set(i, 1);
				}
			}
		}
		else if (type.equals("<BlockNode> {}")) {
			if (c1 != null)
				c1.execute(variableNames, variableValues, declared);
			else if (c2 != null)
				c2.execute(variableNames, variableValues, declared);
		}
		else if (type.equals("<IfNode> if")) {
			Boolean x = (Boolean)(c1.getValue(variableNames, variableValues, declared));
			if (x == null)
				return;
			if (x.booleanValue() == true)
				c2.execute(variableNames, variableValues, declared);
			else c3.execute(variableNames, variableValues, declared);
		}
		else if (type.equals("<WhileNode> while")) {
			Boolean x = (Boolean)(c1.getValue(variableNames, variableValues, declared));
			if (x == null)
				return;
			if (x.booleanValue() == true) {
				c2.execute(variableNames, variableValues, declared);
				this.execute(variableNames, variableValues, declared);
			}
			else return;
		}
		else if (type.equals("<SequenceNode>")) {
			c1.execute(variableNames, variableValues, declared);
			c2.execute(variableNames, variableValues, declared);
		}
	}

	public void analyse(ArrayList<String> variableNames,
		ArrayList<Integer> variableValues, ArrayList<Integer> declared) {
		if (Main.returnCode != 0)
			return;
		if (type.equals("<VariableNode>")) {
			for (int i = 0; i < variableNames.size(); i++)
				if (Var.equals(variableNames.get(i)))
					return;
			Main.returnCode = 1;
			Main.errorLine = line;
		}
		if (c1 != null)
			c1.analyse(variableNames, variableValues, declared);
		if (c2 != null)
			c2.analyse(variableNames, variableValues, declared);
		if (c3 != null)
			c3.analyse(variableNames, variableValues, declared);
	}
}