Class {
	#name : 'FamixValueJavaClassInfo',
	#superclass : 'FamixValueJavaDeclaredTypeInfo',
	#instVars : [
		'superclass',
		'constructors'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'initialization' }
FamixValueJavaClassInfo >> addConstructor: constructorInfo [

	constructors add: constructorInfo
]

{ #category : 'converting' }
FamixValueJavaClassInfo >> asDefaultValueOn: interpreter [

	^ interpreter nullValue
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> classImplementationOf: methodInfo [

	(self methodsNamed: methodInfo name)
		detect: [ :candidate | candidate hasSameSignatureAs: methodInfo ]
		ifFound: [ :candidate | ^ candidate ].

	superclass ifNotNil: [
		^ superclass classImplementationOf: methodInfo ].

	^ nil
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> classMemberMethodsNamed: aName [

	| declared inherited |
	declared := self methodsNamed: aName.

	superclass ifNil: [ ^ declared copy ].

	inherited := (superclass classMemberMethodsNamed: aName) select: [
		             :method | method isInheritableBy: self ].

	^ declared , (inherited reject: [ :inheritedMethod |
		   declared anySatisfy: [ :declaredMethod |
			   declaredMethod hasSameSignatureAs: inheritedMethod ] ])
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> constructorApplicableToTypes: argumentTypes with: interpreter [

	| potential applicable |
	potential := constructors select: [ :constructor |
		             constructor isPotentiallyApplicableToArity:
			             argumentTypes size ].

	potential ifEmpty: [ ^ nil ].

	applicable := potential select: [ :constructor |
		              constructor
			              isApplicableByStrictInvocationToTypes: argumentTypes
			              with: interpreter ].

	applicable ifNotEmpty: [
		^ self
			  mostSpecificAmong: applicable
			  for: argumentTypes
			  with: interpreter ].

	applicable := potential select: [ :constructor |
		              constructor
			              isApplicableByLooseInvocationToTypes: argumentTypes
			              with: interpreter ].

	applicable ifNotEmpty: [
		^ self
			  mostSpecificAmong: applicable
			  for: argumentTypes
			  with: interpreter ].

	applicable := potential select: [ :constructor |
		              constructor
			              isApplicableByVariableArityInvocationToTypes:
			              argumentTypes
			              with: interpreter ].

	applicable ifNotEmpty: [
		^ self
			  mostSpecificAmong: applicable
			  for: argumentTypes
			  with: interpreter ].

	^ nil
]

{ #category : 'initialization' }
FamixValueJavaClassInfo >> constructors [

	^ constructors
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> defaultImplementationOf: methodInfo [

	| methods defaults |
	methods := self maximallySpecificInterfaceMethodsMatching: methodInfo.

	defaults := methods select: [ :method | method isDefault ].

	defaults ifEmpty: [ ^ nil ].
	defaults size = 1 ifTrue: [ ^ defaults first ].

	self error: 'Conflicting default methods'
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> defaultMethodInitializationDependenciesDo: aBlock [

	| visited |
	visited := IdentitySet new.

	interfaces do: [ :interface |
		interface initializationDependenciesDo: aBlock visited: visited ]
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> directSupertypes [

	superclass ifNil: [ ^ interfaces ].

	^ { superclass } , interfaces
]

{ #category : 'definition' }
FamixValueJavaClassInfo >> famixEntityClass [

	^ FamixJavaClass
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> fastClass [

	^ fastDeclaration
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> fieldNamed: fieldName [

	^ self
		  fieldNamed: fieldName
		  ifAbsent: [
		  FamixValueInterpreterResolveError signalFor: fieldName in: self ]
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> fieldNamed: fieldName ifAbsent: aBlock [

	^ fieldsByName at: fieldName ifAbsent: [
		  superclass
			  ifNil: [ aBlock value ]
			  ifNotNil: [ superclass fieldNamed: fieldName ifAbsent: aBlock ] ]
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> fieldNamed: fieldName ifPresent: aBlock [

	^ self fieldNamed: fieldName ifAbsent: [ nil ] ifPresent: aBlock
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> implementationOf: methodInfo [

	(self isSubtypeOf: methodInfo declaringType) ifFalse: [
		self error: qualifiedName , ' is not a subtype of '
			, methodInfo declaringType qualifiedName ].

	(self classImplementationOf: methodInfo) ifNotNil: [ :implementation |
		^ implementation ].

	(self defaultImplementationOf: methodInfo) ifNotNil: [
		:implementation | ^ implementation ].

	self error: 'No implementation of ' , methodInfo name , ' found in '
		, qualifiedName
]

{ #category : 'initialization' }
FamixValueJavaClassInfo >> initialize [

	super initialize.
	constructors := OrderedCollection new
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> instanceFieldsDo: aBlock [

	superclass ifNotNil: [ superclass instanceFieldsDo: aBlock ].

	self fieldsDo: [ :field |
		field isStatic ifFalse: [ aBlock value: field ] ]
]

{ #category : 'testing' }
FamixValueJavaClassInfo >> isClass [

	^ true
]

{ #category : 'testing' }
FamixValueJavaClassInfo >> isFinal [

	^ (modifiers bitAnd: FamixValueJavaModifiers final) ~~ 0
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> memberMethodsNamed: aName [

	| classMethods interfaceMethods |
	classMethods := self classMemberMethodsNamed: aName.
	interfaceMethods := (self interfaceMethodsNamed: aName) reject: [
		                    :method |
		                    method isStatic or: [ method isPrivate ] ].

	interfaceMethods := interfaceMethods reject: [ :interfaceMethod |
		                    classMethods anySatisfy: [ :classMethod |
			                    classMethod hasSameSignatureAs: interfaceMethod ] ].

	interfaceMethods := self maximallySpecificInterfaceMethodsAmong:
		                    interfaceMethods.

	^ classMethods , interfaceMethods
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> superclass [

	^ superclass
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> superclass: aClassInfo [

	superclass := aClassInfo
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> validateConstructorInvocationCycleFrom: constructor [

	| current visited |
	current := constructor.
	visited := IdentitySet new.

	[ current invokesThisConstructor ] whileTrue: [
		(visited includes: current) ifTrue: [
			self error: 'Recursive constructor invocation in ' , qualifiedName ].

		visited add: current.
		current := current invokedConstructor ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> validateConstructorInvocationCycles [

	constructors do: [ :constructor |
		self validateConstructorInvocationCycleFrom: constructor ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> validateDefaultMethodCandidates: methods [

	| representative maximal defaults |
	methods ifEmpty: [ ^ self ].

	representative := methods first.

	((self classMemberMethodsNamed: representative name) anySatisfy: [
		 :classMethod | classMethod hasSameSignatureAs: representative ])
		ifTrue: [ ^ self ].

	maximal := self maximallySpecificInterfaceMethodsAmong: methods.

	defaults := maximal select: [ :method | method isDefault ].

	defaults size > 1 ifTrue: [
		self error:
			'Conflicting default methods for ' , qualifiedName , '>>'
			, representative name ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> validateDefaultMethodConflicts [

	self interfaceMethodNames do: [ :methodName |
		self validateDefaultMethodConflictsNamed: methodName ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> validateDefaultMethodConflictsNamed: aName [

	| methods processed |
	methods := self interfaceMethodsNamed: aName.
	processed := IdentitySet new.

	methods do: [ :method |
		(processed includes: method) ifFalse: [
			| sameSignature |
			sameSignature := methods select: [ :candidate |
				                 candidate hasSameSignatureAs: method ].

			processed addAll: sameSignature.

			self validateDefaultMethodCandidates: sameSignature ] ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> zeroArgumentConstructorWith: interpreter [

	^ self constructorApplicableToTypes: #(  ) with: interpreter
]
