Extension { #name : 'FamixJavaType' }

{ #category : '*Famix-Value-Importer' }
FamixJavaType >> isDictionaryType [

	^ #( 'Map' 'HashMap' 'LinkedHashMap' ) includes: self baseName
]
