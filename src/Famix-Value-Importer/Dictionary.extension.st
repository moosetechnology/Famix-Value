Extension { #name : 'Dictionary' }

{ #category : '*Famix-Value-Importer' }
Dictionary >> asPharoJacksonValueOn: importer [

	^ (importer getObjectType: self)
		  ifNotNil: [ :className | "object of an unloaded class"
			  className = 'Class'
				  ifTrue: [
					  importer
						  importTypeReference: self
						  of: (importer loadTypeNamed: className) ]
				  ifFalse: [
				  importer
					  importObject: self
					  of: (importer loadTypeNamed: className) ] ]
		  ifNil: [ "species of dictionary"
			  (importer getObjectReference: self)
				  ifNotNil: [ :refId | "if @ref"
					  importer
						  getObjectFromIdentity: refId
						  ifAbsent: [ Error signal: 'unknown id: ' , refId asString ] ]
				  ifNil: [ Error signal: 'Unknown state' ] ]
]

{ #category : '*Famix-Value-Importer' }
Dictionary >> asPharoSTONValueOn: importer [

	^ (self removeKey: STON classNameKey ifAbsent: nil)
		  ifNotNil: [ :className | "object of an unloaded class"
			  importer
				  importObject: self
				  of: (importer loadTypeNamed: className) ]
		  ifNil: [ "species of dictionary"
			  importer
				  importDictionary: self
				  of: (importer loadTypeNamed: self className) ]
]
