Extension { #name : #FamixValueOfObject }

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> accept: visitor [

	^ visitor visitObject: self
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> asFASTJavaExpressionOn: visitor [

	^ self type value: self asFASTJavaExpressionOn: visitor
]

{ #category : #'*Famix-Value-Exporter' }
FamixValueOfObject >> asPharoInitializationAST [

	^ RBMessageNode
		  receiver: (RBVariableNode named: self type name)
		  selector: #new
]
