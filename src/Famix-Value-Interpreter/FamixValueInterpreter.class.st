Class {
	#name : 'FamixValueInterpreter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'entityFinder',
		'frames',
		'globals'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueInterpreter class >> entityFinderClass [

	^ FamixEntityFinder
]

{ #category : 'instance creation' }
FamixValueInterpreter class >> on: aFamixModel [

	^ self new entityFinder: ((self entityFinderClass on: aFamixModel)
			   createNotFound: false;
			   signalNotFound: false)
]

{ #category : 'invoking' }
FamixValueInterpreter >> bindArguments: arguments toParametersOf: method in: frame [

	self subclassResponsibility
]

{ #category : 'accessing' }
FamixValueInterpreter >> entityFinder [

	^ entityFinder ifNil: [
		  entityFinder := self class entityFinderClass new
			                  createNotFound: false;
			                  signalNotFound: false ]
]

{ #category : 'accessing' }
FamixValueInterpreter >> entityFinder: anEntityFinder [

	entityFinder := anEntityFinder
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: method [
	"Assume the method is class-side and takes no arguments."

	^ self execute: method on: nil with: {  }
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: method on: receiver with: arguments [

	| frame result |
	frame := FamixValueInterpreterFrame new
		         method: method;
		         receiver: receiver;
		         yourself.

	self bindArguments: arguments toParametersOf: method in: frame.

	^ self inFrame: frame do: [
		  result := method statementBlock accept: self.

		  (result isKindOf: FamixValueInterpreterReturn) ifTrue: [
			  ^ self returnValue: result value from: method ] ]
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: method with: arguments [

	^ self execute: method on: nil with: arguments
]

{ #category : 'accessing' }
FamixValueInterpreter >> frame [

	^ frames top
]

{ #category : 'scoping' }
FamixValueInterpreter >> inFrame: aFrame do: aBlock [

	frames push: aFrame.
	^ [ aBlock value ] ensure: [ frames pop ]
]

{ #category : 'scoping' }
FamixValueInterpreter >> inScopeDo: aBlock [

	self frame pushScope.
	^ [ aBlock value ] ensure: [ self frame popScope ]
]

{ #category : 'initialization' }
FamixValueInterpreter >> initialize [

	super initialize.
	frames := Stack new
]

{ #category : 'resolving' }
FamixValueInterpreter >> locationOf: anExpression [

	self subclassResponsibility
]

{ #category : 'accessing' }
FamixValueInterpreter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : 'accessing' }
FamixValueInterpreter >> model: aFamixValueModel [

	model := aFamixValueModel
]

{ #category : 'invoking' }
FamixValueInterpreter >> returnValue: value from: method [

	^ value
]

{ #category : 'resolving' }
FamixValueInterpreter >> unsupportedLocationOf: anExpression [

	^ FamixValueInterpreterInvalidLocation signalFor: anExpression
]

{ #category : 'visiting' }
FamixValueInterpreter >> visitFASTTExpressionStatement: aFASTTExpressionStatement [

	aFASTTExpressionStatement expression accept: self
]

{ #category : 'visiting' }
FamixValueInterpreter >> visitFASTTReturnStatement: aFASTReturnStatement [
	"Load the return value into the register. If nil, it means the method did not return anything."

	^ FamixValueInterpreterReturn value:
		  (aFASTReturnStatement expression ifNotNil: [ :expression |
			   expression accept: self ])
]

{ #category : 'visiting' }
FamixValueInterpreter >> visitFASTTStatementBlock: aFASTJavaStatementBlock [

	aFASTJavaStatementBlock statements do: [ :statement |
		| result |
		result := statement accept: self.
		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			^ result ] ].
	^ nil
]
