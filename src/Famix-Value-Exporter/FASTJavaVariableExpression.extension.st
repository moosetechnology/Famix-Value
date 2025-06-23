Extension { #name : 'FASTJavaVariableExpression' }

{ #category : '*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributeName [

	^ name
]

{ #category : '*Famix-Value-Exporter' }
FASTJavaVariableExpression >> accessedAttributesOf: aFamixJavaClass [
	"I am a variable expression referencing a constructor parameter.
	Find all attributes accessed through me, directly or transitively."

	self javaAssignmentExpressionOwner ifNotNil: [ :assign |
		| attributeName |
		attributeName := assign variable accessedAttributeName.
		^ { (aFamixJavaClass attributes
			   detect: [ :attribute | attribute name = attributeName ]
			   ifNone: [
				   aFamixJavaClass inheritedAttributes detect: [ :attribute |
					   attribute name = attributeName ] ]) } ].

	argumentOwner ifNotNil: [ :invocation | "If used as argument, reiterate the search on the corresponding parameter of the invoked method"
		| method |
		invocation famixInvocation
			ifNotNil: [ :famixInvocation |
				^ (method := famixInvocation anyCandidate) isStub
					  ifTrue: [ "Ignore stubs" Array empty ]
					  ifFalse: [
						  method parameters size > 1 ifTrue: [ self halt. "Sorted? Make sure arg[i]=param[i]" ].
						  (method parameters at: (invocation arguments indexOf: self))
							  allAccessedAttributesOf: aFamixJavaClass ] ]
			ifNil: [ "Special case, or something went wrong when creating AST or binding to Famix"
				^ invocation name = 'super'
					  ifFalse: [ "Perhaps another constructor? `Foo(int a, int b){ this(a); this.b = b; }`"
						  self shouldBeImplemented ]
					  ifTrue: [ "Lookup the constructor in the superclass and return its attributes accessed through 'this'"
						  (invocation findSuperConstructorIn: aFamixJavaClass superclass)
							  ifNil: [ self error: 'Got nil instead of super constructor' ]
							  ifNotNil: [ :constructor |
								  (constructor parameters at:
									   (invocation arguments indexOf: self))
									  allAccessedAttributesOf: aFamixJavaClass superclass ] ] ] ].

	receiverOwner ifNotNil: [ :invocation | "Receiver of a method, reiterate on the variable 'this' if it is given as an argument"
		^ invocation arguments flatCollectAsSet: [ :argument |
			  (argument
				   toScope: FASTJavaThis
				   until: [ :entity | "Stop when 'this' stops referring to the instance of the class of interest."
					   entity isNewClassExpression
						   ifTrue: [ "TODO: Follow references in anonymous classes referencing attributes or using FASTJavaOuterThis."
							   self shouldBeImplemented ]
						   ifFalse: [ false ] ]) collect: [ :this |
				  this allAccessedAttributesOf: aFamixJavaClass ] ] ].

	self error: 'TODO: what else can be using the constructor parameter?'
]
