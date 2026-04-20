Class {
	#name : #FamixValueInterpreterUnknownOperator,
	#superclass : #Error,
	#category : #'Famix-Value-Interpreter'
}

{ #category : #signalling }
FamixValueInterpreterUnknownOperator class >> signalFor: operator [

	^ self signal: 'Unknown operator: `' , operator , '`.'
]
