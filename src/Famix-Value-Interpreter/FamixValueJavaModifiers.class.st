Class {
	#name : 'FamixValueJavaModifiers',
	#superclass : 'Object',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> abstract [

	^ 16r0400
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> accessMask [
	"Source-level flags without corresponding JVM access flags"

	"(self public bitOr: self private) bitOr: self protected"

	^ 16r0007
]

{ #category : 'instance creation' }
FamixValueJavaModifiers class >> bitForToken: token [

	token = 'public' ifTrue: [ ^ self public ].
	token = 'private' ifTrue: [ ^ self private ].
	token = 'protected' ifTrue: [ ^ self protected ].
	token = 'static' ifTrue: [ ^ self static ].
	token = 'final' ifTrue: [ ^ self final ].
	token = 'synchronized' ifTrue: [ ^ self synchronized ].
	token = 'volatile' ifTrue: [ ^ self volatile ].
	token = 'transient' ifTrue: [ ^ self transient ].
	token = 'native' ifTrue: [ ^ self native ].
	token = 'abstract' ifTrue: [ ^ self abstract ].
	token = 'strictfp' ifTrue: [ ^ self strictfp ].
	token = 'default' ifTrue: [ ^ self default ].

	self error: 'Unknown Java modifier: ' , token
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> default [
	"Source-level flags without corresponding JVM access flags"

	^ 16r10000
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> final [

	^ 16r0010
]

{ #category : 'instance creation' }
FamixValueJavaModifiers class >> fromFASTModifiers: fastModifiers [

	| result |
	result := 0.

	fastModifiers do: [ :modifier |
		result := result bitOr: (self bitForToken: modifier token) ].

	^ result
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> interface [

	^ 16r0200
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> native [

	^ 16r0100
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> private [

	^ 16r0002
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> protected [

	^ 16r0004
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> public [

	^ 16r0001
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> static [

	^ 16r0008
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> strictfp [

	^ 16r0800
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> synchronized [

	^ 16r0020
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> transient [

	^ 16r0080
]

{ #category : 'class initialization' }
FamixValueJavaModifiers class >> volatile [

	^ 16r0040
]
