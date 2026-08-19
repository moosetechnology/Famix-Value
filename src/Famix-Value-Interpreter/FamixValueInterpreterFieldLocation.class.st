Class {
	#name : 'FamixValueInterpreterFieldLocation',
	#superclass : 'FamixValueInterpreterLocation',
	#instVars : [
		'objectAttribute',
		'type'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'enumerating' }
FamixValueInterpreterFieldLocation >> objectAttribute [

	^ objectAttribute
]

{ #category : 'enumerating' }
FamixValueInterpreterFieldLocation >> objectAttribute: aFamixValueOfObjectAttribute [

	objectAttribute := aFamixValueOfObjectAttribute
]

{ #category : 'accessing' }
FamixValueInterpreterFieldLocation >> type [

	^ type
]

{ #category : 'accessing' }
FamixValueInterpreterFieldLocation >> type: aTypeInfo [

	type := aTypeInfo
]

{ #category : 'evaluating' }
FamixValueInterpreterFieldLocation >> value [

	^ objectAttribute value
]

{ #category : 'evaluating' }
FamixValueInterpreterFieldLocation >> value: aValue [

	^ objectAttribute value: aValue
]
