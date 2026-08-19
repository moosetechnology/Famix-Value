Extension { #name : 'FamixValueOfObjectAttribute' }

{ #category : '*Famix-Value-Interpreter' }
FamixValueOfObjectAttribute >> runtimeField [

	^ self attributeAt: #runtimeField ifAbsent: [ nil ]
]

{ #category : '*Famix-Value-Interpreter' }
FamixValueOfObjectAttribute >> runtimeField: aFieldInfo [

	self attributeAt: #runtimeField put: aFieldInfo
]
