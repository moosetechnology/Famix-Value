Extension { #name : #FamixTEnumValue }

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTEnumValue >> valueInstances [
	"Relation named: #valueInstances type: #FamixValueOfEnum opposite: #value"

	<generated>
	<derived>
	<FMProperty: #valueInstances type: #FamixValueOfEnum opposite: #value>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #valueInstances ifAbsentPut: [ FMMultivalueLink on: self opposite: #value: ]
]

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTEnumValue >> valueInstances: anObject [

	<generated>
	self valueInstances value: anObject
]
