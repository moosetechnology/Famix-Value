Extension { #name : 'FASTJavaVariableExpression' }

{ #category : '*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributeName [

	^ name
]

{ #category : '*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributesOf: aFamixJavaClass [

	self javaAssignmentExpressionOwner ifNotNil: [ :assign |
		| attributeName |
		attributeName := assign variable accessedAttributeName.
		^ { (aFamixJavaClass attributes
			   detect: [ :attribute | attribute name = attributeName ]
			   ifNone: [
				   aFamixJavaClass inheritedAttributes detect: [ :attribute |
					   attribute name = attributeName ] ]) } ].
	argumentOwner ifNotNil: [ :invoc | "if used as argument, reiterate the search on the corresponding parameter of the invoked method"
		| method |
		^ (method := invoc famixInvocation anyCandidate) isStub
			  ifTrue: [ "ignore stubs" {  } ]
			  ifFalse: [
				  (method parameters at: (invoc arguments indexOf: self))
					  allAccessedAttributesOf: aFamixJavaClass ] ].
	receiverOwner ifNotNil: [ :receiver | "receiver of a method, reiterate on the variable 'this'"
		| method |
		^ (method := receiver famixInvocation anyCandidate) isStub
			  ifTrue: [ "ignore stubs" {  } ]
			  ifFalse: [
				  method implicitVariables
					  detect: [ :var | var isSelf ]
					  ifFound: [ :var | var allAccessedAttributesOf: aFamixJavaClass ]
					  ifNone: [ {  } ] ] ].
	self error: 'TODO: what else can be using the parameter?'
]
