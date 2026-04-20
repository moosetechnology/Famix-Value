Extension { #name : 'FamixTType' }

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> valueInstances [
	"Relation named: #valueInstances type: #FamixValueOfType opposite: #type"

	<generated>
	<derived>
	<FMProperty: #valueInstances type: #FamixValueOfType opposite: #type>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueInstances ifAbsentPut: [ FMMultivalueLink on: self opposite: #type: ]
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTType >> valueInstances: anObject [

	<generated>
	self valueInstances value: anObject
]

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
