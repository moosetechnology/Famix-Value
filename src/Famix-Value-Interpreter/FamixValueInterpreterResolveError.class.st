Class {
	#name : #FamixValueInterpreterResolveError,
	#superclass : #Error,
	#category : #'Famix-Value-Interpreter'
}

{ #category : #signalling }
FamixValueInterpreterResolveError class >> signalFor: identifier in: value [

	^ self signal:
		  'Unable to resolve: `' , identifier , '` in `' , value asString
		  , '`.'
]
