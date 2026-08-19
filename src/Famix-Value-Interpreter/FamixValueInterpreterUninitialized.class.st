Class {
	#name : 'FamixValueInterpreterUninitialized',
	#superclass : 'Object',
	#classInstVars : [
		'uniqueInstance'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueInterpreterUninitialized class >> uniqueInstance [

	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]
