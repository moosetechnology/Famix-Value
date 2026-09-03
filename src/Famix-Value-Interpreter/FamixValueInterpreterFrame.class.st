Class {
	#name : 'FamixValueInterpreterFrame',
	#superclass : 'Object',
	#instVars : [
		'receiver',
		'scopes',
		'executable'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'binding' }
FamixValueInterpreterFrame >> bind: identifier to: value [

	^ scopes top at: identifier put: value
]

{ #category : 'binding' }
FamixValueInterpreterFrame >> declare: identifier type: type [

	^ scopes top
		  at: identifier
		  put: (FamixValueInterpreterLocal typed: type)
]

{ #category : 'accessing' }
FamixValueInterpreterFrame >> executable [

	^ executable
]

{ #category : 'accessing' }
FamixValueInterpreterFrame >> executable: anExecutableInfo [

	executable := anExecutableInfo
]

{ #category : 'testing' }
FamixValueInterpreterFrame >> hasLocal: identifier [

	^ scopes anySatisfy: [ :scope | scope includesKey: identifier ]
]

{ #category : 'initialization' }
FamixValueInterpreterFrame >> initialize [

	super initialize.
	scopes := Stack new.
	self pushScope
]

{ #category : 'scope' }
FamixValueInterpreterFrame >> popScope [

	^ scopes pop
]

{ #category : 'scope' }
FamixValueInterpreterFrame >> pushScope [

	scopes push: Dictionary new
]

{ #category : 'accessing' }
FamixValueInterpreterFrame >> receiver [

	^ receiver
]

{ #category : 'accessing' }
FamixValueInterpreterFrame >> receiver: aFamixValue [

	receiver := aFamixValue
]

{ #category : 'binding' }
FamixValueInterpreterFrame >> resolve: identifier [

	| value |
	value := (self resolveLocation: identifier) value.

	(value isKindOf: FamixValueInterpreterUninitialized) ifTrue: [
		self error: 'Uninitialized local variable: ' , identifier ].

	^ value
]

{ #category : 'binding' }
FamixValueInterpreterFrame >> resolveLocation: identifier [

	scopes do: [ :scope |
		scope
			at: identifier
			ifPresent: [ :local |
			^ FamixValueInterpreterLocalLocation on: local ] ].

	FamixValueInterpreterResolveError signalFor: identifier in: self
]
