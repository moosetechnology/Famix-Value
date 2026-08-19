Class {
	#name : 'FamixValueInterpreterResolveError',
	#superclass : 'FamixValueInterpreterError',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'signalling' }
FamixValueInterpreterResolveError class >> signalFor: identifier in: value [

	^ self signal:
		  'Unable to resolve: `' , identifier , '` in `' , value asString
		  , '`.'
]
