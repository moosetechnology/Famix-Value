Extension { #name : #Dictionary }

{ #category : #'*Famix-Value-Importer' }
Dictionary >> asPharoJacksonValueOn: importer [

	^ (self removeKey: importer typeKey ifAbsent: nil)
		  ifNotNil: [ :className | "object of an unloaded class"
			  importer
				  importObject: self
				  of: (importer loadTypeNamed: className) ]
		  ifNil: [ "species of dictionary"
			  (self removeKey: importer refKey ifAbsent: nil)
				  ifNotNil: [ :refId | "if @ref"
					  importer
						  getObjectFromIdentity: refId
						  ifAbsent: [ Error signal: 'unknown id' ] ]
				  ifNil: [ "if Dictionary there only is @id"
					  importer
						  importDictionary: self
						  of: (importer loadTypeNamed: self className) ] ]
]

{ #category : #'*Famix-Value-Importer' }
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
