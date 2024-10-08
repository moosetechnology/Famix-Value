Extension { #name : 'FamixValueOfCollection' }

{ #category : '*Famix-Value-Exporter' }
FamixValueOfCollection >> accept: visitor [

	^ visitor visitCollection: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfCollection >> asFASTJavaExpressionOn: visitor [

	^ visitor makeNewExpression: self
]

{ #category : '*Famix-Value-Exporter' }
FamixValueOfCollection >> asPharoInitializationAST [

	^ RBMessageNode
		  receiver: (RBVariableNode named: self type name)
		  selector: #basicNew
]
