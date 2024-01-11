Extension { #name : #String }

{ #category : #'*Famix-Value-Exporter' }
String >> asFASTJavaExpressionOn: visitor of: type [

	^ visitor model newStringLiteral primitiveValue:
		  (self copyReplaceAll: self class lf with: '\n')
]

{ #category : #'*Famix-Value-Exporter' }
String >> splitJavaArguments [
	"Assume I represent a list of comma-separated Java arguments. Return that list."

	| args index start |
	self trim isEmpty ifTrue: [ ^ {  } ].
	args := OrderedCollection new.
	index := start := 1.
	[ (self at: index) isSeparator ] whileTrue: [ index := index + 1 ].
	[ index <= self size ] whileTrue: [
		| char |
		(char := self at: index) == $,
			ifTrue: [
				args add: (self copyFrom: start to: index - 1) trimRight.
				[ (self at: (index := index + 1)) isSeparator ] whileTrue.
				start := index ]
			ifFalse: [
				char == $" | (char == $') ifTrue: [
					| next escape |
					escape := 0.
					[
					escape := escape - 1.
					(next := self at: (index := index + 1)) == $\ & (escape < 0)
						ifTrue: [ (escape := 1) == 1 ]
						ifFalse: [ next ~~ char | (escape == 0) ] ] whileTrue ].
				index := index + 1 ] ].
	args add: (self copyFrom: start to: self size) trimRight.
	^ args
]
