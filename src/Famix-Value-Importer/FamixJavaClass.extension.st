Extension { #name : 'FamixJavaClass' }

{ #category : '*Famix-Value-Importer' }
FamixJavaClass >> isPrimitiveWrapper [

	^ #( Integer Float Double Long Short Byte Boolean Character )
		  includes: name
]
