Class {
	#name : 'FamixValueJavaTypeInfo',
	#superclass : 'FamixValueJavaInfo',
	#instVars : [
		'name'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'testing' }
FamixValueJavaTypeInfo >> canWidenTo: targetType [

	^ false
]

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

{ #category : 'testing' }
FamixValueJavaTypeInfo >> isSubtypeOf: anotherType [

	^ self isSameTypeAs: anotherType
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> name [

	^ name
]

{ #category : 'accessing' }
FamixValueJavaTypeInfo >> name: aString [

	name := aString
]
