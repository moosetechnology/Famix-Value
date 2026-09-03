Class {
	#name : 'FamixValueJavaInterfaceInfo',
	#superclass : 'FamixValueJavaDeclaredTypeInfo',
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'testing' }
FamixValueJavaInterfaceInfo >> declaresDefaultMethod [

	^ self methods anySatisfy: [ :method | method isDefault ]
]

{ #category : 'definition' }
FamixValueJavaInterfaceInfo >> famixEntityClass [

	^ FamixJavaInterface
]

{ #category : 'accessing' }
FamixValueJavaInterfaceInfo >> fastInterface [

	^ fastDeclaration
]

{ #category : 'enumerating' }
FamixValueJavaInterfaceInfo >> initializationDependenciesDo: aBlock visited: visited [

	(visited includes: self) ifTrue: [ ^ self ].
	visited add: self.

	self interfaces do: [ :superinterface |
		superinterface initializationDependenciesDo: aBlock visited: visited ].

	self declaresDefaultMethod ifTrue: [ aBlock value: self ]
]

{ #category : 'testing' }
FamixValueJavaInterfaceInfo >> isInterface [

	^ true
]

{ #category : 'resolving' }
FamixValueJavaInterfaceInfo >> memberMethodsNamed: aName [

	| declared inherited |
	declared := self methodsNamed: aName.
	inherited := OrderedCollection new.

	interfaces do: [ :superinterface |
		inherited addAll:
			((superinterface memberMethodsNamed: aName) reject: [ :method |
				 method isStatic or: [ method isPrivate ] ]) ].

	inherited := inherited reject: [ :inheritedMethod |
		             declared anySatisfy: [ :declaredMethod |
			             declaredMethod hasSameSignatureAs: inheritedMethod ] ].

	inherited := self maximallySpecificInterfaceMethodsAmong: inherited.

	^ declared , inherited
]

{ #category : 'testing' }
FamixValueJavaInterfaceInfo >> modifiersForDeclaration: declaration [

	^ (super modifiersForDeclaration: declaration) bitOr:
		  FamixValueJavaModifiers abstract
]

{ #category : 'testing' }
FamixValueJavaInterfaceInfo >> modifiersForFieldDeclaration: declaration [

	| fieldModifiers |
	fieldModifiers := super modifiersForFieldDeclaration: declaration.

	^ ((fieldModifiers bitOr: FamixValueJavaModifiers public) bitOr:
		   FamixValueJavaModifiers static) bitOr:
		  FamixValueJavaModifiers final
]

{ #category : 'testing' }
FamixValueJavaInterfaceInfo >> modifiersForMethod: fastMethod [

	| methodModifiers |
	methodModifiers := super modifiersForMethod: fastMethod.

	(methodModifiers bitAnd: FamixValueJavaModifiers private) == 0
		ifTrue: [
			methodModifiers := methodModifiers bitOr:
				                   FamixValueJavaModifiers public ].

	(methodModifiers bitAnd: ((FamixValueJavaModifiers default bitOr:
			   FamixValueJavaModifiers static) bitOr:
			  FamixValueJavaModifiers private)) == 0 ifTrue: [
		methodModifiers := methodModifiers bitOr:
			                   FamixValueJavaModifiers abstract ].

	^ methodModifiers
]
