Extension { #name : #FamixTClass }

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTClass >> valueReferences [
	"Relation named: #valueReferences type: #FamixValueOfClassReference opposite: #value"

	<generated>
	<derived>
	<FMProperty: #valueReferences type: #FamixValueOfClassReference opposite: #value>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueReferences ifAbsentPut: [ FMMultivalueLink on: self opposite: #value: ]
]

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTClass >> valueReferences: anObject [

	<generated>
	self valueReferences value: anObject
]
