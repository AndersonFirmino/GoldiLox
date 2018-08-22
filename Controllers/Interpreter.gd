extends Node

const ENVIROMENT = preload("res://Data/Enviroment.gd").enviroment
const TYPE = preload("res://Data/Token.gd").TYPE
const Callable = preload("res://Objects/LoxCallable.gd")


var globals = ENVIROMENT.new(null)
var enviroment = globals # Not always globals?

# Working with retvals:
signal RETURN
var exited_early = false

func _init():
	self.globals.define('clock', Callable.Clock.new())


func interpret(statements):
	for statement in statements:
		# Not pretty but hopefully it will
		if exited_early:
			return
		execute(statement)
	# They throw an error here somewhere. Need to figure out a proper way to replicate it
	
func execute(statement):
	statement.accept(self)
	
func Block(statement):
	# We are passing in a NEW enviroment, and passing our *current* enviroment to its constructor so it can
	# check one level up
	executeBlock(statement.statements, ENVIROMENT.new(self.enviroment))
	return null
	
func executeBlock(statements, enviroment):
	# We're storing the current enviroment into previous enviroment so we don't lose it
	var previous_enviroment = self.enviroment
	
	# This is wrapped in a try block in the tutorial
	# We go into the new enviroment scope
	self.enviroment = enviroment
	for statement in statements:
		# We're hitting this one repeatedly here? 
		if self.exited_early:
			break
		# These are all being executed in the new scope
		execute(statement)
		
	# Once finished we exit the scope back up one
	self.enviroment = previous_enviroment
	
#func visit():
#	# Hopefully works as intended. May require look over
#	return preload("res://Objects/VisitorInterface.gd")
	
func Literal(expr):
	return expr.value
	
func Logical(expression):
	var left = evaluate(expression.left)
	if expression.operator.type == TYPE.OR:
		if isTruthy(left):
			return left
	# I know {} but screw } else {
	else:
		if !isTruthy(left):
			return left
	
	return evaluate(expression.right)
	
func Grouping(expr):
	return evaluate(expr.expression)
	
func evaluate(expr):
	# This shouldn't be calling a reference?
	return expr.accept(self)
	
func Expression(statement):
	evaluate(statement.expression)
	return null
	
func Function(statement):
	var function = Callable.Function.new(statement, self.enviroment)
	enviroment.define(statement.token_name.lexeme, function)
	return null
	
func If(statement):
	if isTruthy(evaluate(statement.condition)):
		execute(statement.thenBranch)
	elif statement.elseBranch != null:
		execute(statement.elseBranch)
	return null
	
func Print(statement):
	var value = evaluate(statement.expression)
	print(stringify(value))
	return null

func Return(statement):
	var value = null
	if statement.value != null:
		value = evaluate(statement.value)
	# Emulating a throw
	self.exited_early = true
	emit_signal("RETURN", value)


    
	
func Var(statement):
	var value = null
	if statement.initializer != null:
		value = evaluate(statement.initializer)
	# The triple dot access may be wrong but not sure
	enviroment.define(statement.token_name.lexeme, value)
	return null
	
func While(statement):
	while isTruthy(evaluate(statement.condition)):
		execute(statement.body)
	return null

func Assign(expr):
	var value = evaluate(expr.value)
	enviroment.assign(expr.token_name, value)
	return value
	
func Unary(expr):
	var right = evaluate(expr.right)
	
	match expr.operator.type:
		TYPE.MINUS:
			checkNumberOperand(expr.operator, right);
			return -float(right)
		TYPE.BANG:
			return !isTruthy(right)
	return null
	
func Variable(expr):
	return enviroment.get(expr.token_name)

func isTruthy(object):
	if object == null: 
		return false
	if typeof(object) == TYPE_BOOL: 
		return bool(object)
	return true

func Binary(expr):
	var left = evaluate(expr.left)
	var right = evaluate(expr.right) # left????
	match expr.operator.type:
		TYPE.GREATER:
			checkNumberOperands(expr.operator, left, right)
			return float(left) > float(right)
		TYPE.GREATER_EQUAL:
			checkNumberOperands(expr.operator, left, right)
			return float(left) >= float(right)
		TYPE.LESS:
			checkNumberOperands(expr.operator, left, right)
			return float(left) < float(right)
		TYPE.LESS_EQUAL:
			checkNumberOperands(expr.operator, left, right)
			return float(left) <= float(right)
		TYPE.BANG_EQUAL: return !isEqual(left, right)
		TYPE.EQUAL_EQUAL: return isEqual(left, right)
		TYPE.MINUS:
			checkNumberOperands(expr.operator, left, right)
			return float(left) - float(right)
		TYPE.PLUS:
			if typeof(left) == TYPE_REAL and typeof(right) == TYPE_REAL:
				return float(left) + float(right)
			elif typeof(left) == TYPE_STRING and typeof(right) == TYPE_STRING:
				return left + right
			RuntimeError.new(expr.operator, "Operands must be two numbers OR two strings")
		TYPE.SLASH:
			checkNumberOperands(expr.operator, left, right)
			return float(left) / float(right)
		TYPE.STAR:
			checkNumberOperands(expr.operator, left, right)
			return float(left) * float(right)
		
	# Unreachable
	return null
	
func Call(expression):
	var callee = evaluate(expression.callee)
	var arguments = []
	for argument in expression.arguments:
		arguments.append(evaluate(argument))
		
#	if not callee is Callable:
	if not callee.current_class == "Callable":
		print('error, can only call functions and classes.')
#		throw new RuntimeError(expr.paren, "Can only call functions and classes.")

	var function = callee
	if arguments.size() != function.arity():
		print(expression.paren, "Expected " + str(function.arity()) + " arguments but got " + str(arguments.size()) + ".")
	return function.Call(self, arguments) # Pretty sure this is a class? Adding a small interpreter?
	
func isEqual(a, b):
	# nil is only equal to nil
	if a == null and b == null: return true
	if a == null: return false
	
	return a == b
	
func stringify(object):
	if typeof(object) == TYPE_NIL: return "nil"
	
	if typeof(object) == TYPE_REAL:
		# toString may not have been implemented?
		var text = str(object)
		if text.ends_with(".0"):
			text = text.subst(0, text.length() -2)
		return text
		
	return str(object)

func checkNumberOperand(operator, operand):
	if typeof(operand) == TYPE_REAL: 
		return
	else:
		# Throwing an error
		RuntimeError.new(operator, "Operand must be a number")

func checkNumberOperands(operator, left, right):
	if typeof(left) == TYPE_REAL and typeof(right) == TYPE_REAL:
		return
	# This may conflict with GDScript ints unless we were already converting them?
	RuntimeError.new(operator, "Operands must be numbers")

class RuntimeError:
	var token
	
	func _init(token, message):
		# Super invoke here?
		# super_init(message)
		print(message)
		self.token = token