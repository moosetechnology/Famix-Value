Extension { #name : 'FamixJavaClass' }

{ #category : '*Famix-Value-Importer' }
FamixJavaClass >> isPrimitiveWrapper [

	^ #( Integer Float Double Long Short Byte Boolean Character )
		  includes: name
]

{ #category : '*Famix-Value-Importer' }
FamixJavaClass >> value: aXMLElement asJavaXStreamValueOn: importer [

	^ (name = 'String' or: [ self isPrimitiveWrapper ])
		  ifTrue: [ importer importPrimitive: aXMLElement of: self ]
		  ifFalse: [ importer importObject: aXMLElement of: self ]
]
