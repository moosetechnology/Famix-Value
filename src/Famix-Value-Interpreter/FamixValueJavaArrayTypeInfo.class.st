Class {
	#name : 'FamixValueJavaArrayTypeInfo',
	#superclass : 'FamixValueJavaTypeInfo',
	#instVars : [
		'componentType',
		'dimensions'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'converting' }
FamixValueJavaArrayTypeInfo >> asDefaultValueOn: interpreter [

	^ interpreter nullValue
]

{ #category : 'testing' }
FamixValueJavaArrayTypeInfo >> canWidenTo: targetType [

	| sourceElement targetElement |
	targetType isArrayType ifFalse: [ ^ false ].

	sourceElement := self elementType.
	targetElement := targetType elementType.

	sourceElement isPrimitiveType ifTrue: [
		^ sourceElement isSameTypeAs: targetElement ].

	targetElement isPrimitiveType ifTrue: [ ^ false ].

	^ sourceElement canWidenTo: targetElement
]

{ #category : 'accessing' }
FamixValueJavaArrayTypeInfo >> componentType [

	^ componentType
]

{ #category : 'accessing' }
FamixValueJavaArrayTypeInfo >> componentType: aTypeInfo [

	componentType := aTypeInfo
]

{ #category : 'accessing' }
FamixValueJavaArrayTypeInfo >> dimensions [

	^ dimensions
]

{ #category : 'accessing' }
FamixValueJavaArrayTypeInfo >> dimensions: anInteger [

	dimensions := anInteger
]

{ #category : 'typing' }
FamixValueJavaArrayTypeInfo >> elementType [

	dimensions = 1 ifTrue: [ ^ componentType ].

	^ self class new
		  componentType: componentType;
		  dimensions: dimensions - 1
]

{ #category : 'accessing' }
FamixValueJavaArrayTypeInfo >> isArrayType [

	^ true
]

{ #category : 'comparing' }
FamixValueJavaArrayTypeInfo >> isSameTypeAs: anotherType [

	^ anotherType isArrayType and: [
		  dimensions = anotherType dimensions and: [
			  componentType isSameTypeAs: anotherType componentType ] ]
]
