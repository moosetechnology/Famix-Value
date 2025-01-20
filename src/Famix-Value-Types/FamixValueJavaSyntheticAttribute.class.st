Class {
	#name : 'FamixValueJavaSyntheticAttribute',
	#superclass : 'Object',
	#instVars : [
		'name',
		'declaredType',
		'parentType',
		'valueInObjects'
	],
	#category : 'Famix-Value-Types',
	#package : 'Famix-Value-Types'
}

{ #category : 'instance creation' }
FamixValueJavaSyntheticAttribute class >> named: aString [

	^ self new name: aString
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> declaredType [

	^ declaredType
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> declaredType: aFamixJavaClass [
	"Must correspond to the outer class of the parentType"

	declaredType := aFamixJavaClass
]

{ #category : 'testing' }
FamixValueJavaSyntheticAttribute >> isStub [

	^ false
]

{ #category : 'testing' }
FamixValueJavaSyntheticAttribute >> isTransient [

	^ false
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> name [

	^ name
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> name: aString [

	name := aString
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> parentType [

	^ parentType
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> parentType: aFamixJavaClass [
	"Must correspond to a non-static inner class"

	parentType := aFamixJavaClass
]

{ #category : 'accessing' }
FamixValueJavaSyntheticAttribute >> valueInObjects [

	^ valueInObjects ifNil: [
		  valueInObjects := FMMultivalueLink on: self opposite: #attribute: ]
]
