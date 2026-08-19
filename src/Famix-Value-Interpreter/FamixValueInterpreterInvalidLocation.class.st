Class {
	#name : 'FamixValueInterpreterInvalidLocation',
	#superclass : 'FamixValueInterpreterError',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'signalling' }
FamixValueInterpreterInvalidLocation class >> signalFor: anExpression [

	^ self signal:
		  'Expression is not assignable: ' , anExpression class name
]
