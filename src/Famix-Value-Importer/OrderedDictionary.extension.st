Extension { #name : 'OrderedDictionary' }

{ #category : '*Famix-Value-Importer' }
OrderedDictionary >> asJavaJacksonValueOn: importer [

	| type |
	type := (importer getObjectType: self)
		        ifNotNil: [ :typeName | importer loadTypeNamed: typeName ]
		        ifNil: [
			        importer typeInference ifNil: [
				        Error signal: 'Cannot determine type.' ] ].
	^ (type isUnknownType or: [ type isDictionaryType ])
		  ifTrue: [ importer importDictionary: self of: type ]
		  ifFalse: [ importer importObject: self of: type ]
]

{ #category : '*Famix-Value-Importer' }
OrderedDictionary >> asPharoJacksonValueOn: importer [

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
