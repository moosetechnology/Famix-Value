Extension { #name : 'Integer' }

{ #category : '*Famix-Value-Importer' }
Integer >> asJavaJacksonValueOn: importer [

	| typeInference |
	((typeInference := importer typeInference) isNotNil and: [
		 (importer isPrimitiveType: typeInference) not ]) ifTrue: [ "Object reference, solved by the importer"
		(importer
			 getObjectFromIdentity: self
			 ifAbsent: [ "Can be a special object with missing runtime type information"
				 importer importSpecialObject: self of: typeInference ])
			ifNotNil: [ :value | ^ value ] ].

	"If none of the above holds, this must be a regular integer (or long)"
	^ importer
		  importPrimitive: self
		  of: ((self > 2147483647 or: [ self < -2147483648 ])
				   ifTrue: [ 'long' ]
				   ifFalse: [ 'int' ])
]
