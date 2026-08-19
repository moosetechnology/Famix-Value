"
A named slot in a particular lexical scope.
"
Class {
	#name : 'FamixValueInterpreterLocalLocation',
	#superclass : 'FamixValueInterpreterLocation',
	#instVars : [
		'local'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueInterpreterLocalLocation class >> on: local [

	^ self new local: local
]

{ #category : 'accessing' }
FamixValueInterpreterLocalLocation >> local: aLocal [

	local := aLocal
]

{ #category : 'accessing' }
FamixValueInterpreterLocalLocation >> type [

	^ local type
]

{ #category : 'evaluating' }
FamixValueInterpreterLocalLocation >> value [

	^ local value
]

{ #category : 'evaluating' }
FamixValueInterpreterLocalLocation >> value: aValue [

	local value: aValue.
	^ aValue
]
