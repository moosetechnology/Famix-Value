Extension { #name : #FamixJavaMethod }

{ #category : #'*Famix-Value-Importer' }
FamixJavaMethod >> signatureWithoutParameterTypes [

	"Rewrite the method signature ignoring parameter types, e.g. f(List<String>) => f(List)"

	| result from to |
	result := '' writeStream.
	from := to := 1.
	[ (to := signature indexOf: $< startingAt: from) = 0 ] whileFalse: [ 
		result nextPutAll: (signature copyFrom: from to: to - 1).
		from := to := (signature findClosing: $> startingAt: to) + 1 ].
	^ from = 1
		  ifTrue: [ signature ]
		  ifFalse: [ 
			  result nextPutAll: (signature copyFrom: from to: signature size).
			  result contents ]
]
