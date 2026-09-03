Class {
	#name : 'FamixValueJavaFieldInfo',
	#superclass : 'FamixValueJavaMemberInfo',
	#instVars : [
		'name',
		'type',
		'initializer',
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
FamixValueJavaFieldInfo >> initializer [

	^ initializer
]

{ #category : 'accessing' }
FamixValueJavaFieldInfo >> initializer: anExpression [

	initializer := anExpression
]

{ #category : 'testing' }
FamixValueJavaFieldInfo >> isField [

	^ true
]

{ #category : 'testing' }
FamixValueJavaFieldInfo >> isFinal [

	^ (modifiers bitAnd: FamixValueJavaModifiers final) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaFieldInfo >> isTransient [

	^ (modifiers bitAnd: FamixValueJavaModifiers transient) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaFieldInfo >> isVolatile [

	^ (modifiers bitAnd: FamixValueJavaModifiers volatile) ~~ 0
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
