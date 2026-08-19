Extension { #name : 'FamixValueOfType' }

{ #category : '*Famix-Value-Interpreter' }
FamixValueOfType >> runtimeType [

	^ self attributeAt: #runtimeType ifAbsent: [ nil ]
]

{ #category : '*Famix-Value-Interpreter' }
FamixValueOfType >> runtimeType: aTypeInfo [

	self attributeAt: #runtimeType put: aTypeInfo
]
