extends Node

var interpreter
var scopes
var currentFunction

enum FunctionType {
	NONE,
	FUNCTION
}

func _init(interpreter):
	self.interpreter = interpreter
	self.scopes = []
	self.currentFunction = FunctionType.NONE

func Block(statement):
	beginScope()
	resolve_loop(statement.statements)
	endScope()
	return null
	
func Expression(statement):
	resolve(statement.expression)
	return null

func Function(statement):
	declare(statement.token_name)
	define(statement.token_name)
	resolveFunction(statement, FunctionType.FUNCTION) #
	return null
	
func If(statement):
	resolve(statement.condition)
	resolve(statement.thenBranch)
	if statement.elseBranch != null:
		resolve(statement.elseBranch)

	
func Print(statement):
	resolve(statement.expression)

	
func Return(statement):
	if currentFunction == FunctionType.NONE:
		Error.error(statement.keyword, "Cannot return from top level code.")
	if statement.value != null:
		resolve(statement.value)
		
func While(statement):
	resolve(statement.condition)
	resolve(statement.body) # This may need a resolve-loop

	
func Binary(expression):
	resolve(expression.left)
	resolve(expression.right)

	
func Call(expression):
	resolve(expression.callee)

	for argument in expression.arguments:
		resolve(argument)
		
func Grouping(expression):
	resolve(expression)
	
func Literal(expression):
	return
	
func Logical(expression):
	resolve(expression.left)
	resolve(expression.right)
	
func Unary(expression):
	resolve(expression.right)
	
func resolve_loop(statements):
	for statement in statements: # stament is do(); // for do(){}
		resolve(statement)


func resolve(obj):
	obj.accept(self)
	
func resolveFunction(function, functype):
	var enclosingFunction = currentFunction # Where do we define current function?
	currentFunction = functype
	beginScope()
	for parameter in function.parameters:
		declare(parameter)
		define(parameter)
	resolve_loop(function.body) # probably a loop but lets try
	endScope()
	currentFunction = enclosingFunction
	
func beginScope():
	# written as scopes.push(new HashMap)
	scopes.append({})
	
func endScope():
	# This returns something but we aren't returning it anywhere? They say we're using to just exit the scope
	scopes.pop_back()
	
# Visit Var Statement. Keep track of this in case Expr/Var collide
func Var(statement):
	declare(statement.token_name)
	if statement.initializer != null:
		resolve(statement.initializer) # This might mean resolve statements // more like expressions
	define(statement.token_name)
	return null
	
func declare(token_name):
	if scopes.empty():
		return
	var scope = scopes.back()
	if scope.has(token_name.lexeme):
		Error.error(token_name, "variable with this name already declared in this scope")
	scope[token_name.lexeme] = false # "Invalid set index 'a' on base Array with value of type bool
	
func define(token_name):
	if scopes.empty():
		return
	scopes.back()[token_name.lexeme] = true
	
func Variable(expression):
	if not scopes.empty() and scopes.back()[expression.token_name.lexeme] == false:
		Error.error(expression.token_name,"Cannot read local variable in its own initializer.")
		# May need to cancel here?
	resolveLocal(expression, expression.token_name)
	return null
	
func Assign(expression):
	# I'm pretty confident resolve should just be able to work with one thing //
	# This is probably resolve expression
	resolve_expression(expression)
	resolveLocal(expression, expression.token_name)
	return null
	
func resolveLocal(expression, token_name):
	var i = scopes.size() - 1
	while i >= 0:
		if scopes[i].has(token_name.lexeme): # This may be wrong
			interpreter.resolve(expression, scopes.size() - 1 - i) # Maybe the wrong index?
			i -= 1
			return