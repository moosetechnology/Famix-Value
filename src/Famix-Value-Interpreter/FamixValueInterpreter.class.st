Class {
	#name : #FamixValueInterpreter,
	#superclass : #Object,
	#instVars : [
		'model',
		'entityFinder',
		'callstack',
		'returnValue'
	],
	#category : #'Famix-Value-Interpreter'
}

{ #category : #'instance creation' }
FamixValueInterpreter class >> entityFinderClass [

	^ FamixEntityFinder
]

{ #category : #'instance creation' }
FamixValueInterpreter class >> on: aFamixModel [

	^ self new entityFinder: (self entityFinderClass on: aFamixModel)
]

{ #category : #private }
FamixValueInterpreter >> constructObject: aFamixTClass [
	"Build an object with all of its attributes set to their default value.
	Attributes from a superclass can be shadowed in a subclass."

	| object seen |
	object := self model newOfObject type: aFamixTClass.
	seen := Set new.
	aFamixTClass withSuperclassesDo: [ :class |
		class attributes do: [ :attribute |
			(seen includes: attribute name) ifFalse: [
				seen add: attribute name.
				self halt.
				model newOfObjectAttribute
					object: object;
					attribute: attribute";value: ???" ] ] ].
	^ object
]

{ #category : #accessing }
FamixValueInterpreter >> context [

	^ callstack top
]

{ #category : #accessing }
FamixValueInterpreter >> entityFinder [

	^ entityFinder ifNil: [
		  entityFinder := self class entityFinderClass new ]
]

{ #category : #accessing }
FamixValueInterpreter >> entityFinder: anEntityFinder [

	entityFinder := anEntityFinder
]

{ #category : #private }
FamixValueInterpreter >> inChildContextDo: aBlock [
	"Create a new context which has access to the current context."

	callstack push:
		(FamixValueInterpreterContext new parentContext: callstack top).
	[ aBlock value ] ensure: [ callstack pop ]
]

{ #category : #private }
FamixValueInterpreter >> inContextDo: aBlock [
	"Reset return value, it will be set by a return statement, if any."

	| result |
	callstack push: self newContext.
	^ [ aBlock value ] ensure: [
		  callstack pop.
		  result := returnValue.
		  returnValue := nil.
		  result ]
]

{ #category : #initialization }
FamixValueInterpreter >> initialize [

	callstack := Stack new
]

{ #category : #accessing }
FamixValueInterpreter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : #accessing }
FamixValueInterpreter >> model: aFamixValueModel [

	model := aFamixValueModel
]

{ #category : #'instance creation' }
FamixValueInterpreter >> newContext [

	^ FamixValueInterpreterContext new
]

{ #category : #'instance creation' }
FamixValueInterpreter >> newInteger [

	self subclassResponsibility
]

{ #category : #private }
FamixValueInterpreter >> privateSend: method with: arguments [
	"Bind the arguments and interpret the body."

	method parentType generateFastIfNotDoneAndBind. "Need to know the whole class, not just the method."
	method parameters
		with: arguments
		do: [ :parameter :value |
		self context bind: parameter name to: value ].
	method fast statementBlock accept: self
]

{ #category : #evaluating }
FamixValueInterpreter >> send: method [
	"Assume the method is class-side. Arguments, if any, are given their default value."

	method parentType generateFastIfNotDoneAndBind.
	^ self inContextDo: [
		  self
			  privateSend: method
			  with: (method parameters collect: [ :parameter |
					   (parameter fastDeclaration first type asTypeOf:
						    parameter declaredType) asDefaultValueOn: self model ]) ]
]

{ #category : #evaluating }
FamixValueInterpreter >> send: method to: object with: values [
	"object: a FamixValueOfObject, the receiver.
	values: collection of FamixValueOfType, the arguments.
	method: a Famix method to interpret."

	^ self inContextDo: [
		  self flag: #TODO. "also bind all attributes, do it in bindReceiver"
		  self bindReceiver: object.
		  self privateSend: method with: values ]
]

{ #category : #evaluating }
FamixValueInterpreter >> send: method with: arguments [

	^ self inContextDo: [ self privateSend: method with: arguments ]
]

{ #category : #visiting }
FamixValueInterpreter >> visitFASTTExpressionStatement: aFASTTExpressionStatement [

	aFASTTExpressionStatement expression accept: self
]

{ #category : #visiting }
FamixValueInterpreter >> visitFASTTReturnStatement: aFASTReturnStatement [
	"Load the return value into the register. If nil, it means the method did not return anything."

	returnValue := aFASTReturnStatement expression ifNotNil: [
		               :expression | expression accept: self ]
]

{ #category : #visiting }
FamixValueInterpreter >> visitFASTTStatementBlock: aFASTJavaStatementBlock [

	aFASTJavaStatementBlock statements do: [ :statement |
		statement accept: self ]
]
