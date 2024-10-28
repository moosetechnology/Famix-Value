"
An importer helper to find types in a Famix model, based on the usage of the `FamixTType` trait.
"
Class {
	#name : 'FamixEntityFinder',
	#superclass : 'Object',
	#instVars : [
		'model',
		'cache',
		'replacements'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'instance creation' }
FamixEntityFinder class >> on: aModel [

	^ self new model: aModel
]

{ #category : 'accessing' }
FamixEntityFinder >> cache [

	^ cache ifNil: [ cache := Dictionary new ]
]

{ #category : 'enumerating' }
FamixEntityFinder >> detectType: block [

	^ self model allTypes detect: block ifNone: nil
]

{ #category : 'API' }
FamixEntityFinder >> findMethodWithSignature: signature in: class [

	| candidates |
	class methods
		detect: [ :method | method signature = signature ]
		ifFound: [ :method | ^ method ].
	"signature might not exactly match due to representation format"
	candidates := self
		              findMethodsWithName:
		              (self methodNameFromSignature: signature)
		              in: class.
	candidates size = 1 ifTrue: [ ^ candidates anyOne ].
	"method might be overloaded, find the one with matching signature"
	candidates := candidates select: [ :method |
		              self signatureOf: method matches: signature ].
	candidates size = 1 ifTrue: [ ^ candidates anyOne ].
	candidates ifEmpty: [
		FamixEntityNotFound signalFor: signature in: class ].
	"consider returning a specific candidate; TODO: better"
	self error: 'Found multiple methods matching signature: ' , signature
]

{ #category : 'API' }
FamixEntityFinder >> findMethodsWithName: name in: class [

	^ class methods select: [ :method | method name = name ]
]

{ #category : 'API' }
FamixEntityFinder >> findTypeNamed: name [
	"Main API for finding a type, should not be overridden."

	| actualName |
	actualName := self replacements at: name ifAbsent: [ name ].
	^ self cache at: actualName ifAbsentPut: [
		  (self parseTypeName: actualName) ifNotNil: [ :type |
			  type isParametricEntity
				  ifTrue: [ type genericEntity ]
				  ifFalse: [ type ] ] ]
]

{ #category : 'enumerating' }
FamixEntityFinder >> findTypeWithMooseName: name [

	^ self detectType: [ :type | type mooseName = name ]
]

{ #category : 'enumerating' }
FamixEntityFinder >> findTypeWithName: name [

	^ self detectType: [ :type | type name = name ]
]

{ #category : 'enumerating' }
FamixEntityFinder >> methodNameFromSignature: signature [

	^ signature
]

{ #category : 'accessing' }
FamixEntityFinder >> model [

	^ model ifNil: [ model := FamixModel new ]
]

{ #category : 'accessing' }
FamixEntityFinder >> model: aFamixModel [

	model := aFamixModel
]

{ #category : 'enumerating' }
FamixEntityFinder >> parseTypeName: name [
	"This method can be overriden to modify how the search is executed."

	^ self findTypeWithName: name
]

{ #category : 'accessing' }
FamixEntityFinder >> replace: aTypeName with: anotherTypeName [

	self replacements at: aTypeName put: anotherTypeName
]

{ #category : 'accessing' }
FamixEntityFinder >> replacements [

	^ replacements ifNil: [ replacements := Dictionary new ]
]

{ #category : 'accessing' }
FamixEntityFinder >> replacements: aDictionary [

	replacements := aDictionary
]

{ #category : 'matching' }
FamixEntityFinder >> signatureOf: method matches: signature [

	^ method signature = signature
]
