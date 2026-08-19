Class {
	#name : 'FamixValueInterpreterLocal',
	#superclass : 'Object',
	#instVars : [
		'type',
		'value'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueInterpreterLocal class >> type: type value: value [

	^ self new
		  type: type;
		  value: value
]

{ #category : 'instance creation' }
FamixValueInterpreterLocal class >> typed: aFamixType [

	^ self new type: aFamixType
]

{ #category : 'initialization' }
FamixValueInterpreterLocal >> initialize [

	super initialize.
	value := FamixValueInterpreterUninitialized uniqueInstance
]

{ #category : 'accessing' }
FamixValueInterpreterLocal >> type [

	^ type
]

{ #category : 'accessing' }
FamixValueInterpreterLocal >> type: aType [

	type := aType
]

{ #category : 'evaluating' }
FamixValueInterpreterLocal >> value [

	^ value
]

{ #category : 'evaluating' }
FamixValueInterpreterLocal >> value: aValue [

	value := aValue
]
