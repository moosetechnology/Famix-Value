Extension { #name : #FASTJavaVariableExpression }

{ #category : #'*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributeName [

	^ name
]

{ #category : #'*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributesOf: aFamixJavaClass [

	self javaAssignmentExpressionOwner ifNotNil: [ :assign |
		| attributeName |
		attributeName := assign variable accessedAttributeName.
		^ (aFamixJavaClass attributes
			   detect: [ :attribute | attribute name = attributeName ]
			   ifNone: [
				   aFamixJavaClass inheritedAttributes detect: [ :attribute |
					   attribute name = attributeName ] ]) asArray ].
	argumentOwner ifNotNil: [ :invoc | "if used as argument, reiterate the search on the corresponding parameter of the invoked method"
		| method |
		^ (((method := invoc famixInvocation anyCandidate) parameters
			    ifNotEmpty: [ method ]
			    ifEmpty: [ "TODO: investigate why we need to do this"
				    method invokingMethods anyOneIfOnlyOneElement ]) parameters
			   at: (invoc arguments indexOf: self)) allAccessedAttributesOf:
			  aFamixJavaClass ].
	self error: 'TODO: what else can be using the parameter?'.
	^ nil
]
