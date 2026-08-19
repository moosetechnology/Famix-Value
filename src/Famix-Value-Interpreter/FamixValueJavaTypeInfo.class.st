Class {
	#name : 'FamixValueJavaTypeInfo',
	#superclass : 'Object',
	#instVars : [
		'name'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> isArrayType [

	^ false
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> isPrimitiveType [

	^ false
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> isSameTypeAs: anotherType [

	^ self == anotherType
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> name [

	^ name
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> name: aString [

	name := aString
]
