"
An importer helper for finding Java types represented by `FamixJavaType` and its subclasses in a FamixJava model.
"
Class {
	#name : 'FamixJavaEntityFinder',
	#superclass : 'FamixEntityFinder',
	#classVars : [
		'FieldDescriptors'
	],
	#category : 'Famix-Value-Importer',
	#package : 'Famix-Value-Importer'
}

{ #category : 'class initialization' }
FamixJavaEntityFinder class >> initialize [
	"See https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3.2"

	FieldDescriptors := IdentityDictionary new.
	FieldDescriptors
		at: $B put: 'byte';
		at: $C put: 'char';
		at: $D put: 'double';
		at: $F put: 'float';
		at: $I put: 'int';
		at: $J put: 'long';
		at: $S put: 'short';
		at: $Z put: 'boolean'
]

{ #category : 'enumerating' }
FamixJavaEntityFinder >> methodNameFromSignature: signature [

	^ signature copyUpTo: $(
]

{ #category : 'enumerating' }
FamixJavaEntityFinder >> parseTypeName: name [
	"The name may not be fully qualified.
	Even if we want to find a name in java.lang or java.util packages, we want to search using the mooseName if it is parameterized.
	Famix does not represent arrays, but we need the information, so we use a wrapper around the type."

	| typeName dimensions type |
	typeName := self translateFieldDescriptor: name.
	dimensions := name occurrencesOf: $[.
	type := (typeName includes: $.)
		        ifFalse: [ self findTypeWithName: typeName ]
		        ifTrue: [ "Search by translating the type name to a mooseName."
			        self findTypeWithMooseName:
				        ((typeName allButLast: dimensions * 2)
					         copyReplaceAll: '.'
					         with: '::') ].
	^ dimensions > 0
		  ifFalse: [ type ]
		  ifTrue: [
		  (FamixValueJavaArray wrapping: type) dimensions: dimensions ]
]

{ #category : 'matching' }
FamixJavaEntityFinder >> signatureOf: method matches: signature [
	"Assume the signature includes the method name and the field descriptors of the parameters, e.g. `main([Ljava.lang.String;)`.
	Because Famix doesn't represent arrays, use the method's signature string which contains array information.
	However, its format is the one used in source code, e.g. `main(String[])`, so there needs to be a translation."

	| parameters |
	parameters := (signature
		               copyFrom: method name size + 2
		               to: signature size - 1)
		              ifEmpty: [ #(  ) ]
		              ifNotEmpty: [ :params | params splitOn: $, ].
	method parameters size = parameters size ifFalse: [ ^ false ].
	^ method signatureWithoutParameterTypes
	  = (String streamContents: [ :stream |
			   stream nextPutAll: method name.
			   stream nextPut: $(.
			   self translateFieldDescriptors: parameters on: stream.
			   stream nextPut: $) ])
]

{ #category : 'translating' }
FamixJavaEntityFinder >> translateFieldDescriptor: fieldDescriptor [
	"Translate Java field descriptors to a type name used by Moose, e.g. '[I' -> 'int[]'
	See https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3.2"

	| dimensions typeName |
	dimensions := 0.
	[ (fieldDescriptor at: dimensions + 1) == $[ ] whileTrue: [
		dimensions := dimensions + 1 ].
	dimensions = 0 ifTrue: [ ^ fieldDescriptor ].
	typeName := fieldDescriptor allButFirst: dimensions.
	typeName := FieldDescriptors
		            at: (typeName at: 1)
		            ifAbsent: [ "an instance of class, e.g. Ljava.lang.String;"
			            (typeName at: 1) == $L
				            ifTrue: [ typeName copyFrom: 2 to: typeName size - 1 ]
				            ifFalse: [
				            self error: 'incoherent Java field descriptor' ] ].
	[
	typeName := typeName , '[]'.
	(dimensions := dimensions - 1) > 0 ] whileTrue.
	^ typeName
]

{ #category : 'matching' }
FamixJavaEntityFinder >> translateFieldDescriptors: parameters on: stream [
	"Only keep the type's simple name, discard the qualifying prefix."

	parameters
		do: [ :parameter |
			| translation index |
			translation := self translateFieldDescriptor: parameter.
			index := translation
				         lastIndexOfAnyOf: '.$'
				         startingAt: translation size
				         ifAbsent: 0.
			stream nextPutAll: (index = 0
					 ifTrue: [ translation ]
					 ifFalse: [ translation allButFirst: index ]) ]
		separatedBy: [ stream nextPut: $, ]
]
