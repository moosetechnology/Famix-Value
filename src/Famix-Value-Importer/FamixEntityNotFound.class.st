Class {
	#name : 'FamixEntityNotFound',
	#superclass : 'NotFound',
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'private' }
FamixEntityNotFound >> standardMessageText [

	^ String streamContents: [ :stream |
		  stream << self object << ' not found in ' << self collection name ]
]
