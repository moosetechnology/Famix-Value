Class {
	#name : #FamixValuePharoSTONImporter,
	#superclass : #FamixValueAbstractImporter,
	#instVars : [
		'reader'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #enumerating }
FamixValuePharoSTONImporter >> getObjectIdentity: rawObject [

	^ rawObject hash
]

{ #category : #importing }
FamixValuePharoSTONImporter >> importObject: rawObject of: type [

	"STON objects are fully deserialized, so there is no way of knowing if an object has already been imported without remembering all objects.
	If a serialized object doesn't have its class loaded in the image, it is reified as a dictionary.
	The super call awaits a dictionary-like structure, so we transform the object into one."

	| dictionary |
	objectDict
		at: (self getObjectIdentity: rawObject)
		ifPresent: [ :object | ^ object ].
	rawObject isDictionary
		ifTrue: [ dictionary := rawObject ]
		ifFalse: [ 
			dictionary := Dictionary new.
			rawObject class stonAllInstVarNames do: [ :varName | 
				(rawObject instVarNamed: varName) ifNotNil: [ :value | 
					dictionary at: varName put: value ] ] ].
	^ super importObject: dictionary of: type
]

{ #category : #importing }
FamixValuePharoSTONImporter >> importValue: rawValue [

	^ rawValue asPharoSTONValueOn: self
]

{ #category : #'private - utility' }
FamixValuePharoSTONImporter >> newReader [

	^ STONReader new acceptUnknownClasses: true
]
