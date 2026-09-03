Class {
	#name : 'FamixValueInterpreterLocation',
	#superclass : 'Object',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'testing' }
FamixValueInterpreterLocation class >> isAbstract [

	^ self == FamixValueInterpreterLocation
]

{ #category : 'accessing' }
FamixValueInterpreterLocation >> type [

	self subclassResponsibility
]

{ #category : 'evaluating' }
FamixValueInterpreterLocation >> value [

	self subclassResponsibility
]

{ #category : 'evaluating' }
FamixValueInterpreterLocation >> value: aFamixValue [

	self subclassResponsibility
]
