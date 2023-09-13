Extension { #name : #Number }

{ #category : #'*Famix-Value-Importer' }
Number >> asPharoSTONValueOn: importer [

	^ importer importPrimitive: self of: self className
]
