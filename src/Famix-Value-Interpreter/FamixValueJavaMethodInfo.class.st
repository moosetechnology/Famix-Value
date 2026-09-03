Class {
	#name : 'FamixValueJavaMethodInfo',
	#superclass : 'FamixValueJavaExecutableInfo',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaMethodInfo class >> on: aFASTJavaMethodEntity [

	^ self new fastMethod: aFASTJavaMethodEntity
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isAbstract [

	^ (modifiers bitAnd: FamixValueJavaModifiers abstract) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isDefault [

	^ (modifiers bitAnd: FamixValueJavaModifiers default) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isInheritableBy: typeInfo [

	self isPrivate ifTrue: [ ^ false ].

	(self isPublic or: [ self isProtected ]) ifTrue: [ ^ true ].

	^ declaringType packageName = typeInfo packageName
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isMethod [

	^ true
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isNative [

	^ (modifiers bitAnd: FamixValueJavaModifiers native) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isStrictfp [

	^ (modifiers bitAnd: FamixValueJavaModifiers strictfp) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isSynchronized [

	^ (modifiers bitAnd: FamixValueJavaModifiers synchronized) ~~ 0
]
