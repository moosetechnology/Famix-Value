Extension { #name : #FamixTType }

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTType >> values [
	"Relation named: #values type: #FamixValueOfType opposite: #type"

	<generated>
	<derived>
	<FMProperty: #values type: #FamixValueOfType opposite: #type>
	<package: #'Famix-Value-Entities'>
	^ self attributeAt: #values ifAbsentPut: [ FMMultivalueLink on: self opposite: #type: ]
]

{ #category : #'*Famix-Value-Entities-accessing' }
FamixTType >> values: anObject [

	<generated>
	self values value: anObject
]
