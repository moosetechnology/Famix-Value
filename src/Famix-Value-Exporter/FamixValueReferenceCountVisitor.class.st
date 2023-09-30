Class {
	#name : #FamixValueReferenceCountVisitor,
	#superclass : #Object,
	#instVars : [
		'references'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #visiting }
FamixValueReferenceCountVisitor class >> visit: value [

	^ self new visit: value
]

{ #category : #initialization }
FamixValueReferenceCountVisitor >> initialize [

	references := Dictionary new
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visit: value [

	value accept: self.
	^ references
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitCollection: collection [

	references
		at: collection
		ifPresent: [ :count | ^ references at: collection put: count + 1 ]
		ifAbsentPut: 1.
	collection value do: [ :element | element value accept: self ]
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitDictionary: dictionary [

	references
		at: dictionary
		ifPresent: [ :count | ^ references at: dictionary put: count + 1 ]
		ifAbsentPut: 1.
	dictionary value do: [ :assoc | 
		assoc key accept: self.
		assoc value accept: self ]
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitEnumValue: enumValue [

	references
		at: enumValue
		ifPresent: [ :count | references at: enumValue put: count + 1 ]
		ifAbsentPut: 1
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitObject: object [

	references
		at: object
		ifPresent: [ :count | ^ references at: object put: count + 1 ]
		ifAbsentPut: 1.
	object value do: [ :attribute | attribute value accept: self ]
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitPrimitive: primitive [

	references
		at: primitive
		ifPresent: [ :count | references at: primitive put: count + 1 ]
		ifAbsentPut: 1
]

{ #category : #visiting }
FamixValueReferenceCountVisitor >> visitValueOfUnknownType: unknown [

	references
		at: unknown
		ifPresent: [ :count | references at: unknown put: count + 1 ]
		ifAbsentPut: 1
]
