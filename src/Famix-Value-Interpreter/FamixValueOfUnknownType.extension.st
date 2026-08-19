Extension { #name : 'FamixValueOfUnknownType' }

{ #category : '*Famix-Value-Interpreter' }
FamixValueOfUnknownType >> resolve: identifier [

	value ifNil: [
		FamixValueInterpreterResolveError signalFor: identifier in: self ].
	^ value
		  at: identifier
		  ifAbsent: [
		  FamixValueInterpreterResolveError signalFor: identifier in: self ]
]
