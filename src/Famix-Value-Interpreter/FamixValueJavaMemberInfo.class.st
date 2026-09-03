Class {
	#name : 'FamixValueJavaMemberInfo',
	#superclass : 'FamixValueJavaInfo',
	#traits : 'FamixValueJavaTWithModifiers',
	#classTraits : 'FamixValueJavaTWithModifiers classTrait',
	#instVars : [
		'declaringType'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaMemberInfo >> compilationUnit [

	^ declaringType declaringCompilationUnit
]

{ #category : 'accessing' }
FamixValueJavaMemberInfo >> declaringType [

	^ declaringType
]

{ #category : 'accessing' }
FamixValueJavaMemberInfo >> declaringType: typeInfo [

	declaringType := typeInfo
]

{ #category : 'initialization' }
FamixValueJavaMemberInfo >> initialize [

	super initialize.
	modifiers := 0
]

{ #category : 'testing' }
FamixValueJavaMemberInfo >> isMember [

	^ true
]

{ #category : 'resolving' }
FamixValueJavaMemberInfo >> localTypeNamed: typeName ifPresent: aBlock [

	^ nil
]
