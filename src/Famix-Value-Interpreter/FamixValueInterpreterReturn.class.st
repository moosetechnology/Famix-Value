Class {
	#name : 'FamixValueInterpreterReturn',
	#superclass : 'FamixValueInterpreterControlFlow',
	#instVars : [
		'value'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueInterpreterReturn class >> value: aFamixValue [

	^ self new value: aFamixValue
]

{ #category : 'evaluating' }
FamixValueInterpreterReturn >> value [

	^ value
]

{ #category : 'evaluating' }
FamixValueInterpreterReturn >> value: aFamixValue [

	value := aFamixValue
]
