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
	
	# We
	var returnValue
	
	func _init(declaration):
		self.declaration = declaration
		
	func Call(interpreter, arguments):
		# We initialize the return value to null
		self.returnValue = null
#		ifbool is_connected( String signal, Object target, String method ) c
		if not interpreter.is_connected("RETURN", self, "setReturnValue"):
			interpreter.connect("RETURN", self, "setReturnValue")
		var enviroment = interpreter.ENVIROMENT.new(interpreter.globals)
		for i in range(declaration.parameters.size()):
			enviroment.define(declaration.parameters[i].lexeme, arguments[i])
			
		# The interpreter will break itself via boolean check
		# So if we hit an early return, the interpreter will set its boolean and break its execution loop
		interpreter.executeBlock(declaration.body, enviroment)
		
		# Note to others, all functions use the SAME interpreter but within different enviroments. Therefore we have to reset our early exit boolean back to false
		# from here
		interpreter.exited_early = false
		
		# One shot is not working here?
		# We ALWAYS return something, it will default to nil/null unless otherwise set.
		return returnValue
		
	func setReturnValue(value):
		self.returnValue = value
		
	func arity():
		return declaration.parameters.size()
		
	func toString():
		return "<fn " + declaration.token_name.lexeme + ">"
