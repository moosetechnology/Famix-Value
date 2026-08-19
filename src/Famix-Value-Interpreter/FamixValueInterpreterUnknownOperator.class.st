Class {
	#name : 'FamixValueInterpreterUnknownOperator',
	#superclass : 'FamixValueInterpreterError',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'signalling' }
FamixValueInterpreterUnknownOperator class >> signalFor: operator [

	^ self signal: 'Unknown operator: `' , operator , '`.'
]
