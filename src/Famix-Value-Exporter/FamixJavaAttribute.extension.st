Extension { #name : #FamixJavaAttribute }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaAttribute >> initializerMatchesValues: objectAttributes [
	"Assume I have a source and an initializer expression. Return whether the representations of primitive objects, given as argument, match those of my initializer expression, regardless of order.
	For example, if my representation in Java was:
	public static MY_ATTRIBUTE = MyClass(1, 'foo');
	Then I would match: { 1. 'foo' } or { 'foo'. 1 }"

	| found source |
	found := objectAttributes copy.
	source := self sourceText.
	source := source
		          copyFrom: (source indexOf: $() + 1
		          to: (source lastIndexOf: $)) - 1.
	source regex: '[^,\s]+' matchesDo: [ :match |
		| index |
		index := found indexOf: match.
		index = 0
			ifTrue: [ ^ false ]
			ifFalse: [ found removeAt: index ] ].
	^ found isEmpty
]

{ #category : #'*Famix-Value-Exporter' }
FamixJavaAttribute >> isStaticConstant [
	"Public static attribute with an initializer."

	^ self isClassSide and: [
		  self isPublic and: [
			  self hasSourceAnchor and: [ self sourceText includes: $= ] ] ]
]
