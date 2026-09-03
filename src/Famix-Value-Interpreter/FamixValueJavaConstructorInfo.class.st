Class {
	#name : 'FamixValueJavaConstructorInfo',
	#superclass : 'FamixValueJavaExecutableInfo',
	#instVars : [
		'constructorInvocation',
		'invokedConstructor'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaConstructorInfo >> constructorInvocation [

	^ constructorInvocation
]

{ #category : 'accessing' }
FamixValueJavaConstructorInfo >> constructorInvocation: anInvocation [

	constructorInvocation := anInvocation
]

{ #category : 'testing' }
FamixValueJavaConstructorInfo >> hasExplicitConstructorInvocation [

	^ constructorInvocation isNotNil
]

{ #category : 'testing' }
FamixValueJavaConstructorInfo >> implicitlyInvokesSuper [

	^ constructorInvocation isNil
]

{ #category : 'accessing' }
FamixValueJavaConstructorInfo >> invokedConstructor [

	^ invokedConstructor
]

{ #category : 'accessing' }
FamixValueJavaConstructorInfo >> invokedConstructor: aConstructorInfo [

	invokedConstructor := aConstructorInfo
]

{ #category : 'testing' }
FamixValueJavaConstructorInfo >> invokesThisConstructor [

	^ constructorInvocation isNotNil and: [
		  constructorInvocation name = 'this' ]
]

{ #category : 'testing' }
FamixValueJavaConstructorInfo >> isConstructor [

	^ true
]

{ #category : 'testing' }
FamixValueJavaConstructorInfo >> isImplicit [

	^ fastMethod isNil
]
