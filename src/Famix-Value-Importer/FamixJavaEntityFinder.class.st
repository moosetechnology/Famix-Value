"
An importer helper for finding Java types represented by `FamixJavaType` and its subclasses in a FamixJava model.
"
Class {
	#name : #FamixJavaEntityFinder,
	#superclass : #FamixEntityFinder,
	#instVars : [
		'fieldDescriptors'
	],
	#category : #'Famix-Value-Importer'
}

{ #category : #initialization }
FamixJavaEntityFinder >> initialize [

	"See https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3.2"

	fieldDescriptors := IdentityDictionary new.
	fieldDescriptors
		at: $B put: 'byte';
		at: $C put: 'char';
		at: $D put: 'double';
		at: $F put: 'float';
		at: $I put: 'int';
		at: $J put: 'long';
		at: $S put: 'short';
		at: $Z put: 'bool'
]

{ #category : #enumerating }
FamixJavaEntityFinder >> methodNameFromSignature: signature [

	^ signature copyUpTo: $(
]

{ #category : #enumerating }
FamixJavaEntityFinder >> parseTypeName: name [

	self flag: #VerveineJ. "restore method when parsing useless stubs is fixed"
	^ "(name beginsWithAnyOf: #( 'java.lang.' 'java.util.' ))
		  ifTrue: [ self findTypeWithName: (name copyAfterLast: $.) ]
		  ifFalse: [ "
		  self findTypeWithMooseName: (name copyReplaceAll: '.' with: '::') "]"
]

{ #category : #matching }
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

{ #category : #translating }
FamixJavaEntityFinder >> translateFieldDescriptor: fieldDescriptor [

	"Translate Java field descriptors to a type name used by Moose, e.g. '[I' -> 'int[]'
	See https://docs.oracle.com/javase/specs/jvms/se8/html/jvms-4.html#jvms-4.3.2"

	| dimensions typeName |
	dimensions := 0.
	[ (fieldDescriptor at: dimensions + 1) == $[ ] whileTrue: [ 
		dimensions := dimensions + 1 ].
	dimensions = 0 ifTrue: [ ^ fieldDescriptor ].
	typeName := fieldDescriptor allButFirst: dimensions.
	typeName := fieldDescriptors
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

{ #category : #matching }
FamixJavaEntityFinder >> translateFieldDescriptors: parameters on: stream [

	"Only keep the type's simple name, discard the qualifying prefix."

	parameters
		do: [ :parameter | 
			| translation index |
			translation := self translateFieldDescriptor: parameter.
			index := translation lastIndexOf: $..
			stream nextPutAll: (index = 0
					 ifTrue: [ translation ]
					 ifFalse: [ translation allButFirst: index ]) ]
		separatedBy: [ stream nextPut: $, ]
]
