Class {
	#name : #FamixValueJavaInterpreter,
	#superclass : #FamixValueInterpreter,
	#instVars : [
		'globals'
	],
	#classVars : [
		'Operators'
	],
	#category : #'Famix-Value-Interpreter'
}

{ #category : #'instance creation' }
FamixValueJavaInterpreter class >> entityFinderClass [

	^ FamixJavaEntityFinder
]

{ #category : #'class initialization' }
FamixValueJavaInterpreter class >> initialize [

	Operators := Dictionary new.

	"=== Unary"
	"= Arithmetic"
	Operators at: '+' put: [ :v | v ].
	Operators at: '-' put: [ :v | 0 - v ].
	Operators at: '++' put: [ :v | v + 1 ].
	Operators at: '--' put: [ :v | v - 1 ].
	"= Bitwise"
	Operators at: '~' put: [ :v | v bitInvert ].
	"= Conditional"
	Operators at: '!' put: [ :v | v not ].

	"=== Binary"
	"= Arithmetic"
	Operators at: '*' put: [ :l :r | l * r ].
	Operators at: '/' put: [ :l :r | l / r ].
	Operators at: '%' put: [ :l :r | l rem: r ].
	Operators at: '+' put: [ :l :r | l + r ].
	Operators at: '-' put: [ :l :r | l - r ].
	"= Shift"
	Operators at: '<<' put: [ :l :r | l bitShift: r ].
	Operators at: '>>' put: [ :l :r | l bitShift: 0 - r ].
	Operators at: '>>>' put: [ :l :r | l bitShift: 0 - r ].
	"= Relational"
	Operators at: '<' put: [ :l :r | l < r ].
	Operators at: '<=' put: [ :l :r | l <= r ].
	Operators at: '>' put: [ :l :r | l > r ].
	Operators at: '>=' put: [ :l :r | l >= r ].
	Operators at: 'instanceof' put: [ :l :r | self halt ].
	"= Equality"
	Operators at: '==' put: [ :l :r | l = r ].
	Operators at: '!=' put: [ :l :r | l ~= r ].
	"= Bitwise"
	Operators at: '&' put: [ :l :r | l bitAnd: r ].
	Operators at: '^' put: [ :l :r | l bitXor: r ].
	Operators at: '|' put: [ :l :r | l bitOr: r ].
	"= Conditional"
	Operators at: '&&' put: [ :l :r | l and: [ r ] ].
	Operators at: '||' put: [ :l :r | l or: [ r ] ]
]

{ #category : #'as yet unclassified' }
FamixValueJavaInterpreter >> executeMain: main [
	"Execute a Java main method with default argument: an empty string array."

	^ self inContextDo: [
		  self
			  privateSend: main
			  with:
				  { (self model newOfCollection type: (FamixValueJavaArray new
						    type: main parameters first declaredType;
						    dimensions: 1)) } ]
]

{ #category : #initialization }
FamixValueJavaInterpreter >> initialize [

	super initialize.
	"global context"
	globals := FamixValueInterpreterContext new.

	self flag: #TODO. "kinda hacky, change later"
	globals bind: 'System' to: (self model newOfObject type:
			 (FamixValueJavaSystem wrapping: FamixJavaClass new))
]

{ #category : #'instance creation' }
FamixValueJavaInterpreter >> newContext [

	^ FamixValueInterpreterContext new parentContext: globals
]

{ #category : #'instance creation' }
FamixValueJavaInterpreter >> newInteger [

	^ self model newOfPrimitiveType type:
		  (self entityFinder findTypeNamed: 'int')
]

{ #category : #private }
FamixValueJavaInterpreter >> operate: operator with: value [

	^ Operators
		  at: operator
		  ifPresent: [ :operation | operation value: value value ]
		  ifAbsent: [
		  FamixValueInterpreterUnknownOperator signalFor: operator ]
]

{ #category : #private }
FamixValueJavaInterpreter >> operate: operator with: left with: right [

	^ Operators
		  at: operator
		  ifPresent: [ :operation |
		  operation value: left value value: right value ]
		  ifAbsent: [
		  FamixValueInterpreterUnknownOperator signalFor: operator ]
]

{ #category : #hooks }
FamixValueJavaInterpreter >> receiverName [

	^ 'this'
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaArrayAccess: aFASTJavaArrayAccess [
	"Shift index because Java arrays start at 0."

	^ (aFASTJavaArrayAccess array accept: self) value at:
		  (aFASTJavaArrayAccess expression accept: self) value + 1
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaAssignmentExpression: aFASTJavaAssignmentExpression [
	"Conversion in assignment context: https://docs.oracle.com/javase/specs/jls/se10/html/jls-5.html#jls-5.2"

	| lhs rhs |
	"The left hand side operand may be a named variable, such as a local variable or a field of the current object or class, or it may be a computed variable, as can result from a field access or an array access."
	lhs := aFASTJavaAssignmentExpression variable accept: self.
	rhs := aFASTJavaAssignmentExpression expression accept: self.
	lhs value: (aFASTJavaAssignmentExpression operator = '='
			 ifTrue: [ rhs value ]
			 ifFalse: [ "one of:  *=  /=  %=  +=  -=  <<=  >>=  >>>=  &=  ^=  |=  "
				 self
					 operate: aFASTJavaAssignmentExpression operator allButLast
					 with: lhs
					 with: rhs ])
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaClassProperty: aFASTJavaClassProperty [

	| receiver |
	receiver := aFASTJavaClassProperty type accept: self.
	^ receiver type
		  valueOfPropertyNamed: aFASTJavaClassProperty fieldName
		  ofInstance: receiver
		  on: self
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaForStatement: aFASTJavaForStatement [

	self inChildContextDo: [
		aFASTJavaForStatement initializer accept: self.
		[ (aFASTJavaForStatement condition accept: self) value ] whileTrue: [
			aFASTJavaForStatement body accept: self.
			aFASTJavaForStatement incrementor accept: self ] ]
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaIfStatement: aFASTJavaIfStatement [

	(aFASTJavaIfStatement condition accept: self) value ifTrue: [
		aFASTJavaIfStatement thenPart accept: self ]
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaInfixOperation: aFASTJavaInfixOperation [

	self flag: #TODO. "how to type the result correctly"
	^ self model newOfPrimitiveType value: (self
			   operate: aFASTJavaInfixOperation operator
			   with: (aFASTJavaInfixOperation leftOperand accept: self)
			   with: (aFASTJavaInfixOperation rightOperand accept: self))
	"type: left type;"
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaIntegerLiteral: aFASTJavaIntegerLiteral [

	^ self newInteger value:
		  aFASTJavaIntegerLiteral primitiveValue asInteger
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaMethodInvocation: aFASTJavaMethodInvocation [

	| receiver method arguments |
	receiver := aFASTJavaMethodInvocation receiver accept: self.
	method := aFASTJavaMethodInvocation famixInvocation anyCandidate.
	arguments := aFASTJavaMethodInvocation arguments collect: [ :argument |
		             argument accept: self ].
	^ method isClassSide
		  ifTrue: [ self send: method with: arguments ]
		  ifFalse: [ self send: method to: receiver with: arguments ]
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaNewExpression: aFASTJavaNewExpression [

	| constructor object |
	constructor := aFASTJavaNewExpression famixInvocation anyCandidate.
	object := self constructObject: constructor parentType.

	"default constructors may be auto-generated and not present in source"
	(constructor parameters isEmpty and: [
		 constructor accesses isEmpty and: [
			 constructor outgoingInvocations isEmpty ] ]) ifFalse: [
		| arguments |
		arguments := aFASTJavaNewExpression arguments collect: [ :argument |
			             argument accept: self ].
		self send: constructor to: object with: arguments ].

	^ object
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaUnaryExpression: aFASTJavaUnaryExpression [

	| variable result oldValue |
	variable := aFASTJavaUnaryExpression expression accept: self.
	result := self
		          operate: aFASTJavaUnaryExpression operator
		          with: variable.
	aFASTJavaUnaryExpression isPrefixedUnaryExpression ifTrue: [
		^ variable value: result ].
	"If postfixed, return the value the variable had before applying the operator."
	oldValue := variable value.
	variable value: result.
	^ (self model add: variable class new)
		  value: oldValue;
		  type: variable type
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaVarDeclStatement: aFASTJavaVarDeclStatement [

	aFASTJavaVarDeclStatement declarators do: [ :declarator |
		self context
			bind: declarator variable name
			to: (declarator expression accept: self) ]
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaVariableDeclarator: aFASTJavaVariableDeclarator [

	| value |
	value := aFASTJavaVariableDeclarator expression ifNotNil: [
		         :initializer | initializer accept: self ].
	self context
		bind: aFASTJavaVariableDeclarator variable name
		to: value
]

{ #category : #visiting }
FamixValueJavaInterpreter >> visitFASTJavaVariableExpression: aFASTJavaVariableExpression [

	^ self context resolve: aFASTJavaVariableExpression name
]
