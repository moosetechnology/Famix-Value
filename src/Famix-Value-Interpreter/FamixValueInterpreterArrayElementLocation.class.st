Class {
	#name : 'FamixValueInterpreterArrayElementLocation',
	#superclass : 'FamixValueInterpreterLocation',
	#instVars : [
		'array',
		'index',
		'type'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueInterpreterArrayElementLocation >> array: aFamixValueOfCollection [

	array := aFamixValueOfCollection
]

{ #category : 'accessing' }
FamixValueInterpreterArrayElementLocation >> index: anInteger [

	index := anInteger
]

{ #category : 'accessing' }
FamixValueInterpreterArrayElementLocation >> type [

	^ type
]

{ #category : 'accessing' }
FamixValueInterpreterArrayElementLocation >> type: aFamixType [

	type := aFamixType
]

{ #category : 'evaluating' }
FamixValueInterpreterArrayElementLocation >> value [

	^ (array value at: index) value
]

{ #category : 'evaluating' }
FamixValueInterpreterArrayElementLocation >> value: aValue [

	^ array value
		  at: index
		  put: (FamixValueOfCollectionElement new value: aValue)
]
