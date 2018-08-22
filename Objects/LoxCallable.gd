extends Node

class Callable:
	var parameters = []
	var current_class
	
	func _init():
		self.current_class = "Callable"
		
#	func Call(interpreter, arguments):
#		pass
#
#	func arity():
#		return self.parameters.size()
		
class Clock extends Callable:
	# Native Function
	func _init():
		self.parameters = 0
		print("clock created")
	
	func arity():
		return 0
		
	func Call(interpreter, arguments): # Not sure if we need to add this?
		return float(OS.get_system_time_secs())
		
	func toString():
		return "<native fn>"
		
class Function extends Callable:
	var declaration
	
	func _init(declaration):
		self.declaration = declaration
		
	func Call(interpreter, arguments):
		var enviroment = interpreter.ENVIROMENT.new(interpreter.globals)
		for i in range(declaration.parameters.size()):
			enviroment.define(declaration.parameters[i].lexeme, arguments[i])
			
		interpreter.executeBlock(declaration.body, enviroment)
		return null
		
	func arity():
		return declaration.parameters.size()
		
	func toString():
		return "<fn " + declaration.token_name.lexeme + ">"
