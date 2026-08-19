Class {
	#name : 'FamixValueInterpreterComputedLocation',
	#superclass : 'FamixValueInterpreterLocation',
	#instVars : [
		'readBlock'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueInterpreterComputedLocation class >> computed: aBlock [

	^ self new readBlock: aBlock
]

{ #category : 'accessing' }
FamixValueInterpreterComputedLocation >> readBlock: aBlock [

	readBlock := aBlock
]

{ #category : 'accessing' }
FamixValueInterpreterComputedLocation >> type [

	self shouldNotImplement
]

{ #category : 'evaluating' }
FamixValueInterpreterComputedLocation >> value [

	^ readBlock value
]

{ #category : 'evaluating' }
FamixValueInterpreterComputedLocation >> value: aValue [

	self error: 'Cannot assign to read-only location'
]
