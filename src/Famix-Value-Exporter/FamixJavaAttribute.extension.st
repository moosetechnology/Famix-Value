Extension { #name : 'FamixJavaAttribute' }

{ #category : '*Famix-Value-Exporter' }
FamixJavaAttribute >> initializerMatchesValues: objectAttributes [
	"Assume I have a source and an initializer expression.
	Return whether the representations of primitive objects, given as argument, match those of my initializer expression, regardless of order.
	For example, if my representation in Java was:
	public static MyClass MY_ATTRIBUTE = new MyClass(1, 'foo');
	Then I would match: { 1. 'foo' } or { 'foo'. 1 }"

	| toFind source |
	toFind := objectAttributes copy.
	source := (source := self sourceText)
		          copyFrom: (source indexOf: $() + 1
		          to: (source lastIndexOf: $)) - 1.
	source splitJavaArguments do: [ :argument |
		| index |
		(index := toFind indexOf: argument) = 0
			ifTrue: [ ^ false ]
			ifFalse: [ toFind removeAt: index ] ].
	^ toFind isEmpty
]

{ #category : '*Famix-Value-Exporter' }
FamixJavaAttribute >> isStaticConstant [
	"Public static attribute with an initializer."

	^ self isClassSide and: [
		  self isPublic and: [
			  self hasSourceAnchor and: [ self sourceText includes: $= ] ] ]
]
