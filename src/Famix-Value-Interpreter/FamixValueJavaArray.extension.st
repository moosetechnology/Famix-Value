Extension { #name : #FamixValueJavaArray }

{ #category : #'*Famix-Value-Interpreter' }
FamixValueJavaArray >> asDefaultValueOn: aFamixValueModel [

	^ aFamixValueModel newOfUnknownType
		  type: self;
		  value: nil
]

{ #category : #'*Famix-Value-Interpreter' }
FamixValueJavaArray >> valueOfPropertyNamed: identifier ofInstance: array on: interpreter [

	identifier = 'length' ifTrue: [
		^ interpreter newInteger value: array value size ].
	FamixValueInterpreterResolveError signalFor: identifier in: array
]
