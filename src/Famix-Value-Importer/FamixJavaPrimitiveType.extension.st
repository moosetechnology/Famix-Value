Extension { #name : 'FamixJavaPrimitiveType' }

{ #category : '*Famix-Value-Importer' }
FamixJavaPrimitiveType >> value: aXMLElement asJavaXStreamValueOn: importer [

	^ importer importPrimitive: aXMLElement of: self
]
