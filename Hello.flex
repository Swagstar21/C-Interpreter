import java.util.*;
 
%%
 
%class HelloLexer
%standalone
 
%{
	Stack<Node> stack = new Stack<>();
	Node root;
	ArrayList<String> variableNames = new ArrayList<>();
	ArrayList<Integer> variableValues = new ArrayList<>();
	ArrayList<Integer> declared = new ArrayList<>();
	int line = 0;
%}
 
LineTerminator = \r|\n|\r\n
Digit = [1-9]
Number = {Digit}(0 | {Digit})* | 0
String = [a-z]+
Var = {String}
AVal = {Number}
BVal = "true" | "false"
WS = (" "|\t)+

%state DECL
%state CORP
%state AEXPR
%state IF
%state WHILE
 
%%

<YYINITIAL> {
	"int" { line++; yybegin(DECL); root = new Node(0, "<MainNode>"); stack.push(root); }
	{LineTerminator} {}
	{WS} {}
} 

<DECL> {
	"int" {}
	{Var} {
		variableNames.add(yytext());
		variableValues.add(0);
		declared.add(-1);
	}
	"," {}
	{LineTerminator} {}
	{WS} {}
	";" { yybegin(CORP); }
}

<CORP> {
	"while" {
		line++;
		Node aux = new Node(0, "<WhileNode> while");
		aux.line = line;
		aux.necesitaSecventa = 1;

		if (stack.peek().necesitaSecventa == 1) {
			Node secv = new Node(0, "<SequenceNode>");
			secv.necesitaSecventa = 1;
			Node c = stack.pop();
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = secv;
			else stack.peek().c1 = secv;
			secv.c1 = c;
			secv.c2 = aux;
			stack.push(secv);
		}
		else {
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = aux;
			else stack.peek().c1 = aux;
		}
		stack.push(aux);
		yybegin(WHILE);
	}
	"if" {
		line++;
		Node aux = new Node(0, "<IfNode> if");
		aux.line = line;
		aux.necesitaSecventa = 1;

		if (stack.peek().necesitaSecventa == 1) {
			Node secv = new Node(0, "<SequenceNode>");
			secv.necesitaSecventa = 1;
			Node c = stack.pop();
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = secv;
			else stack.peek().c1 = secv;
			secv.c1 = c;
			secv.c2 = aux;
			stack.push(secv);
		}
		else {
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = aux;
			else stack.peek().c1 = aux;
		}
		stack.push(aux);
		yybegin(IF);
	}
	"=" {
		line++;
		Node aux = new Node(0, "<AssignmentNode> =");
		aux.line = line;
		Node c1 = stack.pop();
		aux.c1 = c1;
		aux.necesitaSecventa = 1;
		

		if (stack.peek().necesitaSecventa == 1) {
			Node secv = new Node(0, "<SequenceNode>");
			secv.necesitaSecventa = 1;
			Node c = stack.pop();
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = secv;
			else stack.peek().c1 = secv;
			secv.c1 = c;
			secv.c2 = aux;
			stack.push(secv);
		}
		else {
			if (stack.peek().type.equals("<SequenceNode>") ||
			stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c2 = aux;
			else stack.peek().c1 = aux;
		}

		stack.push(aux);
		yybegin(AEXPR);

	}

	"{" {
		Node aux = new Node(0, "<BlockNode> {}");
		aux.line = line;
		stack.peek().c2 = aux;
		stack.push(aux);
	}

	"else {" {
		Node aux = new Node(0, "<BlockNode> {}");
		aux.line = line;
		stack.peek().c3 = aux;
		stack.push(aux);
	}

	"}" {
		line++;
		while(!stack.peek().type.equals("<BlockNode> {}")) {
			Node aux = stack.pop();
		}
		stack.pop();
		if (stack.peek().c2 == null && stack.peek().type.equals("<IfNode> if")) {
			yybegin(IF);
		}
	}


	{Var} {
		Node aux = new Node(0, "<VariableNode>");
		aux.line = line;
		aux.setValue(yytext());
		stack.push(aux);
	}
	{LineTerminator} {}
	{WS} {}
}

<AEXPR> {
	"(" {
		Node aux = new Node(0, "<BracketNode> ()");
		aux.line = line;
		if (stack.peek().type.equals("<IfNode> if"))
			stack.peek().c1 = aux;
		else stack.peek().c2 = aux;
		stack.push(aux);
	}
	")" {
		while(!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
	}
	{WS} {}
	{AVal} {
		Node aux = new Node(0, "<IntNode>");
		aux.line = line;
		aux.setValue(Integer.parseInt(yytext()));
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
	}
	"+" {
		while(!stack.peek().type.equals("<AssignmentNode> =") &&
		!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<PlusNode> +");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.peek().c2 = aux;
		stack.push(aux);
	}
	"/" {
		Node aux = new Node(0, "<DivNode> /");
		aux.line = line;
		Node c1 = stack.pop();
		aux.c1 = c1;
		stack.push(aux);
	}
	";" {
		while (!stack.peek().type.equals("<AssignmentNode> =")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		yybegin(CORP);
	}
	{Var} {
		Node aux = new Node(0, "<VariableNode>");
		aux.line = line;
		aux.setValue(yytext());
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
	}
}

<IF> {
	{LineTerminator} {}
	{WS} {}
	"+" {
		while(!stack.peek().type.equals("<AssignmentNode> =") &&
		!stack.peek().type.equals("<BracketNode> ()") && !stack.peek().type.equals("<GreaterNode> >")
		&& !stack.peek().type.equals("<AndNode> &&")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<PlusNode> +");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.peek().c2 = aux;
		stack.push(aux);
	}
	"/" {
		Node aux = new Node(0, "<DivNode> /");
		aux.line = line;
		Node c1 = stack.pop();
		aux.c1 = c1;
		stack.push(aux);
	}
	"&&" {
		while(!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<AndNode> &&");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.push(aux);
	}
	"!" {
		Node aux = new Node(0, "<NotNode> !");
		aux.line = line;
		stack.push(aux);
	}
	">" {
		while(!stack.peek().type.equals("<BracketNode> ()") && !stack.peek().type.equals("<AndNode> &&")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<GreaterNode> >");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.push(aux);
	}

	{BVal} {
		Node aux = new Node(0, "<BoolNode>");
		aux.line = line;
		aux.setValue(Boolean.parseBoolean(yytext()));
		if (stack.peek().type.equals("<PlusNode> +"))
			stack.peek().c2 = aux;
		else stack.push(aux);
		
	}
	
	{AVal} {
		Node aux = new Node(0, "<IntNode>");
		aux.line = line;
		aux.setValue(Integer.parseInt(yytext()));
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
		
	}
	
	{Var} {
		Node aux = new Node(0, "<VariableNode>");
		aux.line = line;
		aux.setValue(yytext());
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
		
	}
	"(" {
		Node aux = new Node(0, "<BracketNode> ()");
		aux.line = line;
		if (stack.peek().type.equals("<IfNode> if"))
			stack.peek().c1 = aux;
		else stack.peek().c2 = aux;
		stack.push(aux);
	}
	")" {
		while(!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		stack.pop();
		if (stack.peek().type.equals("<IfNode> if"))
			yybegin(CORP);
	}
}

<WHILE> {
	{LineTerminator} {}
	{WS} {}
	"/" {
		Node aux = new Node(0, "<DivNode> /");
		aux.line = line;
		Node c1 = stack.pop();
		aux.c1 = c1;
		stack.push(aux);
	}
	"+" {
		while(!stack.peek().type.equals("<AssignmentNode> =") &&
		!stack.peek().type.equals("<BracketNode> ()") && !stack.peek().type.equals("<GreaterNode> >")
		&& !stack.peek().type.equals("<AndNode> &&")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<PlusNode> +");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.peek().c2 = aux;
		stack.push(aux);
	}
	"&&" {
		while(!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<AndNode> &&");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.push(aux);
	}
	"!" {
		Node aux = new Node(0, "<NotNode> !");
		aux.line = line;
		stack.push(aux);
	}
	">" {
		while(!stack.peek().type.equals("<BracketNode> ()") && !stack.peek().type.equals("<AndNode> &&")) {
			Node aux = stack.pop();
			stack.peek().c2 = aux;
		}
		Node aux = new Node(0, "<GreaterNode> >");
		aux.line = line;
		Node c1 = stack.peek().c2;
		aux.c1 = c1;
		stack.push(aux);
	}
	
	{AVal} {
		Node aux = new Node(0, "<IntNode>");
		aux.line = line;
		aux.setValue(Integer.parseInt(yytext()));
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
		
	}
	{BVal} {
		Node aux = new Node(0, "<BoolNode>");
		aux.line = line;
		aux.setValue(Boolean.parseBoolean(yytext()));
		if (stack.peek().type.equals("<PlusNode> +"))
			stack.peek().c2 = aux;
		else stack.push(aux);
		
	}
	{Var} {
		Node aux = new Node(0, "<VariableNode>");
		aux.line = line;
		aux.setValue(yytext());
		if (stack.peek().type.equals("<DivNode> /")) {
			stack.peek().c2 = aux;
		}
		
		else stack.push(aux);
		
	}
	"(" {
		Node aux = new Node(0, "<BracketNode> ()");
		aux.line = line;
		if (stack.peek().type.equals("<WhileNode> while"))
			stack.peek().c1 = aux;
		else stack.peek().c2 = aux;
		stack.push(aux);
	}
	")" {
		while(!stack.peek().type.equals("<BracketNode> ()")) {
			Node aux = stack.pop();
			if (stack.peek().type.equals("<WhileNode> while"))
				stack.peek().c1 = aux;
			else stack.peek().c2 = aux;
		}
		stack.pop();
		if (stack.peek().type.equals("<WhileNode> while"))
			yybegin(CORP);
	}
}




