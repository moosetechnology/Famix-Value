Class {
	#name : 'FamixValueJavaPrimitiveTypeInfo',
	#superclass : 'FamixValueJavaTypeInfo',
	#instVars : [
		'famixType'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'converting' }
FamixValueJavaPrimitiveTypeInfo >> asDefaultValueOn: interpreter [

	^ interpreter defaultValueOfPrimitiveType: self
]

{ #category : 'accessing' }
FamixValueJavaPrimitiveTypeInfo >> famixType [

	^ famixType
]

{ #category : 'accessing' }
FamixValueJavaPrimitiveTypeInfo >> famixType: aFamixType [

	famixType := aFamixType
]

{ #category : 'accessing' }
FamixValueJavaPrimitiveTypeInfo >> isPrimitiveType [

	^ true
]
