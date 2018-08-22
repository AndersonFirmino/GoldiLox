extends Object

class Expr extends Object:
	var immediate_class
	var current_class
	
	func _init(c = "Expr"):
		self.immediate_class = c
		self.current_class == "Callable"

	func accept(visitor):
		return visitor.call(self.immediate_class, self)
		
	func get_immediate_class():
		return self.immediate_class

class Call extends Expr:
	var callee
	var paren
	var arguments
	
	func _init(callee, paren, arguments).("Call"):
		self.callee = callee
		self.paren = paren
		self.arguments = arguments
		
class Assign extends Expr:
	var token_name
	var value
	
	func _init(token_name, value).("Assign"):
		self.token_name = token_name
		self.value = value
		
#      "Logical  : Expr left, Token operator, Expr right",
class Logical extends Expr:
	var left
	var operator
	var right
	
	func _init(left, operator, right).("Logical"):
		self.left = left
		self.operator = operator
		self.right = right

class Binary extends Expr:
	var left
	var operator
	var right
	
	func _init(left, operator, right).("Binary"):
		self.left = left
		self.operator = operator
		self.right = right
		
class Unary extends Expr:
	var operator
	var right
	
	func _init(operator, right).("Unary"):
		self.operator = operator
		self.right = right
		
class Grouping extends Expr:
	var expression
	
	func _init(expression).("Grouping"):
		self.expression = expression
		
class Literal extends Expr:
	var value
	
	func _init(value).("Literal"):
		self.value = value
		
class Variable extends Expr:
	var token_name
	
	func _init(token_name).("Variable"):
		self.token_name = token_name