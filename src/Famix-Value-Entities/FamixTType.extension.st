Extension { #name : 'FamixTType' }

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> valueReferences [
	"Relation named: #valueReferences type: #FamixValueOfTypeReference opposite: #value"

	<generated>
	<derived>
	<FMProperty: #valueReferences type: #FamixValueOfTypeReference opposite: #value>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueReferences ifAbsentPut: [ FMMultivalueLink on: self opposite: #value: ]
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> valueReferences: anObject [

	<generated>
	self valueReferences value: anObject
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> values [
	"Relation named: #values type: #FamixValueOfType opposite: #type"

	<generated>
	<derived>
	<FMProperty: #values type: #FamixValueOfType opposite: #type>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #values ifAbsentPut: [ FMMultivalueLink on: self opposite: #type: ]
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> values: anObject [

	<generated>
	self values value: anObject
]
