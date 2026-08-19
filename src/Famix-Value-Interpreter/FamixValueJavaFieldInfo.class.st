Class {
	#name : 'FamixValueJavaFieldInfo',
	#superclass : 'Object',
	#instVars : [
		'name',
		'type',
		'famixAttribute'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> famixAttribute [

	^ famixAttribute
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> famixAttribute: aFamixAttribute [

	famixAttribute := aFamixAttribute
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> name [

	^ name
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> name: aString [

	name := aString
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> type [

	^ type
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> type: aType [

	type := aType
]
