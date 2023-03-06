Extension { #name : #FamixTTypedEntity }

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTTypedEntity >> values [
	"Relation named: #values type: #FamixValueOfType opposite: #typedEntity"

	<generated>
	<derived>
	<FMProperty: #values type: #FamixValueOfType opposite: #typedEntity>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #values ifAbsentPut: [ FMMultivalueLink on: self opposite: #typedEntity: ]
]

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTTypedEntity >> values: anObject [

	<generated>
	self values value: anObject
]
