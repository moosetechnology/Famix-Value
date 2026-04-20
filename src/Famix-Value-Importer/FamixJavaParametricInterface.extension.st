Extension { #name : 'FamixJavaParametricInterface' }

{ #category : '*Famix-Value-Importer' }
FamixJavaParametricInterface >> value: aXMLElement asJavaXStreamValueOn: importer [

	(#( Map Set ) includes: name) ifTrue: [
		^ importer
			  importDictionary: aXMLElement
			  of: (importer loadTypeNamed: 'java.util.Hash' , name) ].

	'List' = name ifTrue: [
		^ importer
			  importCollection: aXMLElement
			  of: (importer loadTypeNamed: 'java.util.ArrayList') ].

	Error signal: 'What am I?'
]
