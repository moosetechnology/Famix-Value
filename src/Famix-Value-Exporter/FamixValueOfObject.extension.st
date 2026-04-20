Extension { #name : 'FamixValueOfObject' }

{ #category : '*Famix-Value-Exporter' }
FamixValueOfObject >> accept: visitor [

	^ visitor visitObject: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfObject >> asFASTJavaExpressionOn: visitor [

	^ self type value: self asFASTJavaExpressionOn: visitor
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfObject >> asPharoInitializationAST [

	^ RBMessageNode
		  receiver: (RBVariableNode named: self type name)
		  selector: #new
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfObject >> constructorSignature [

	^ String streamContents: [ :s |
		  s << self type name << '('.
		  value
			  do: [ :attribute |
				  attribute attribute declaredType
					  ifNotNil: [ :declaredType | s << declaredType name ]
					  ifNil: [ "TODO this should not be happening, fix parser then fix this
						Use the name in the meantime, since this is only used for hashing at this moment, and that should keep the unicity"
						  attribute attribute name ] ]
			  separatedBy: [ s nextPut: $, ].
		  s nextPut: $) ]
]
