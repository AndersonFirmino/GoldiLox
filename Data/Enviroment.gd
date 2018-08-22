extends Node

class enviroment:
	var enclosing = null
	var values = {}
	
	func _init(enclosing):
		self.enclosing = enclosing
	
	func define(title, value):
		values[title] = value
#		print("ADDING VARIABLE with NAME: ", title, " AND VALUE: ", value)
		
	func get(token):
		if values.has(token.lexeme):
			return values[token.lexeme]
		if enclosing != null:
			return enclosing.get(token)
		print(token, " undefined variable '" + token.lexeme + "'.")
	#	Error.runTimeerror([token, "Undefined variable '" + token.lexeme + "'."])
	
	
	func assign(token_name, value):
		if values.has(token_name.lexeme):
			values[token_name.lexeme] = value
			return
		if enclosing != null:
			enclosing.assign(token_name, value)
			return
		return
	#	  throw new RuntimeError(name,                     
	##        "Undefined variable '" + name.lexeme + "'.");
	