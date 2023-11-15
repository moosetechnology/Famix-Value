Extension { #name : #FamixTClass }

{ #category : #'*Famix-Value-Exporter' }
FamixTClass >> constructorsOrderedByScore [

	"Return the constructors ordered by an arbitrary score that determine their effectiveness.
	The score is roughly the ratio of attributes set over parameter count, see FamixTMethod>>#impactScore."

	self flag: #VerveineJ. "should not have to use Sets"
	^ (methods asSet asArray select: [ :method | method isConstructor ]) 
		  sort: [ :a :b | a constructorScore > b constructorScore ]
]

{ #category : #'*Famix-Value-Exporter' }
FamixTClass >> findSetterOf: aFamixAttribute [

	^ self allMethods
		  detect: [ :method | 
			  method isSetter and: [ 
				  method accesses anySatisfy: [ :access | 
					  access variable == aFamixAttribute ] ] ]
		  ifNone: nil
]

{ #category : #'*Famix-Value-Exporter' }
FamixTClass >> publicConstructorsWithMostImpact [

	"Return the constructors that access the most attributes and have the most parameters."

	| maxAccessCount maxParamCount candidates |
	maxAccessCount := maxParamCount := -1.
	self flag: #VerveineJ. "should not have to use Sets"
	candidates := IdentitySet new.
	methods asSet do: [ :method | 
		| accessCount paramCount |
		method isPublic & method isConstructor ifTrue: [ 
			paramCount := method parameters size.
			((accessCount := method allAccessedAttributes size)
			 > maxAccessCount or: [ 
				 accessCount = maxAccessCount and: [ paramCount > maxParamCount ] ])
				ifTrue: [ 
					candidates := IdentitySet with: method.
					maxAccessCount := accessCount.
					maxParamCount := paramCount ]
				ifFalse: [ 
					accessCount = maxAccessCount & (paramCount = maxParamCount) 
						ifTrue: [ candidates add: method ] ] ] ].
	^ candidates
]
