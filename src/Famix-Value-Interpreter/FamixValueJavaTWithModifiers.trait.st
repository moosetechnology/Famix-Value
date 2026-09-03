Trait {
	#name : 'FamixValueJavaTWithModifiers',
	#instVars : [
		'modifiers'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> hasModifier: modifier [

	^ (modifiers bitAnd: modifier) ~~ 0
]

{ #category : 'typing' }
FamixValueJavaTWithModifiers >> isDefault [

	^ (modifiers bitAnd: FamixValueJavaModifiers default) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> isPackagePrivate [

	^ (modifiers bitAnd: FamixValueJavaModifiers accessMask) == 0
]

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> isPrivate [

	^ (modifiers bitAnd: FamixValueJavaModifiers private) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> isProtected [

	^ (modifiers bitAnd: FamixValueJavaModifiers protected) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> isPublic [

	^ (modifiers bitAnd: FamixValueJavaModifiers public) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaTWithModifiers >> isStatic [

	^ (modifiers bitAnd: FamixValueJavaModifiers static) ~~ 0
]

{ #category : 'accessing' }
FamixValueJavaTWithModifiers >> modifiers [

	^ modifiers
]

{ #category : 'accessing' }
FamixValueJavaTWithModifiers >> modifiers: anInteger [

	modifiers := anInteger
]
