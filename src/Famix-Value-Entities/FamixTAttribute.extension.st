Extension { #name : 'FamixTAttribute' }

{ #category : '*Famix-Value-Entities-accessing' }
FamixTAttribute >> valueInObjects [
	"Relation named: #valueInObjects type: #FamixValueOfObjectAttribute opposite: #attribute"

	<generated>
	<derived>
	<FMProperty: #valueInObjects type: #FamixValueOfObjectAttribute opposite: #attribute>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueInObjects ifAbsentPut: [ FMMultivalueLink on: self opposite: #attribute: ]
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTAttribute >> valueInObjects: anObject [

	<generated>
	self valueInObjects value: anObject
]
