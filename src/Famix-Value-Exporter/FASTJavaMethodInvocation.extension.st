Extension { #name : 'FASTJavaMethodInvocation' }

{ #category : '*Famix-Value-Exporter' }
FASTJavaMethodInvocation >> findSuperConstructorIn: aFamixJavaClass [
	"I am a super constructor invocation, find the constructor I reference in the given superclass."

	(self atScope: FASTJavaMethodEntity) anyOne famixMethod
		outgoingInvocations
		detect: [ :invocation | invocation isConstructor ]
		ifFound: [ :invocation | ^ invocation anyCandidate ].

	"It should be found through the above code but it can be absent if there was an error during parsing (with VerveineJ v3.3.1).
	We could check that parameter pairs have an identical declaredType, but it can be nil!
	Instead we're drawing with crayons and using a crazy way to detect type name equality, which is fragile because of possible qualifiers.
	This is supposed to be a temporary workaround until VerveineJ is fixed. (2025-06-20)"

	^ aFamixJavaClass methods detect: [ :superMethod |
		  superMethod isConstructor and: [
			  superMethod parameters size = self arguments size and: [
				  (1 to: superMethod parameters size) allSatisfy: [ :i |
					  (self arguments at: i) famixVariable fastDeclaration first type
						  typeName name
					  = (superMethod parameters at: i) declaredType name ] ] ] ]
]
