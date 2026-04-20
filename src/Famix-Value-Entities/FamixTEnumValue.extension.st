Extension { #name : 'FamixTEnumValue' }

{ #category : '*Famix-Value-Entities-accessing' }
FamixTEnumValue >> valueReferences [
	"Relation named: #valueReferences type: #FamixValueOfEnum opposite: #value"

	<generated>
	<derived>
	<FMProperty: #valueReferences type: #FamixValueOfEnum opposite: #value>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueReferences ifAbsentPut: [ FMMultivalueLink on: self opposite: #value: ]
]

{ #category : '*Famix-Value-Entities-accessing' }
FamixTEnumValue >> valueReferences: anObject [

	<generated>
	self valueReferences value: anObject
]
