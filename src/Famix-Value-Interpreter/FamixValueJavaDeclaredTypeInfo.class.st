Class {
	#name : 'FamixValueJavaDeclaredTypeInfo',
	#superclass : 'FamixValueJavaTypeInfo',
	#traits : 'FamixValueJavaTWithModifiers',
	#classTraits : 'FamixValueJavaTWithModifiers classTrait',
	#instVars : [
		'qualifiedName',
		'fastDeclaration',
		'famixType',
		'declaringCompilationUnit',
		'loaded',
		'interfaces',
		'methodsByName',
		'fieldsByName'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaDeclaredTypeInfo class >> named: qualifiedName [

	| dotIndex |
	dotIndex := qualifiedName lastIndexOf: $..

	^ self new
		  name: (dotIndex == 0
				   ifTrue: [ qualifiedName ]
				   ifFalse: [
					   qualifiedName copyFrom: dotIndex + 1 to: qualifiedName size ]);
		  qualifiedName: qualifiedName
]

{ #category : 'adding' }
FamixValueJavaDeclaredTypeInfo >> addField: fieldInfo [

	fieldsByName at: fieldInfo name put: fieldInfo
]

{ #category : 'adding' }
FamixValueJavaDeclaredTypeInfo >> addInterface: interfaceInfo [

	^ interfaces add: interfaceInfo
]

{ #category : 'adding' }
FamixValueJavaDeclaredTypeInfo >> addMethod: aMethodInfo [

	methodsByName
		at: aMethodInfo name
		ifPresent: [ :methods | methods add: aMethodInfo ]
		ifAbsentPut: [ OrderedCollection with: aMethodInfo ]
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> canWidenTo: targetType [

	^ self isSubtypeOf: targetType
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> collectInterfaceMethodNamesInto: names visited: visited [

	(visited includes: self) ifTrue: [ ^ self ].
	visited add: self.

	self isInterface ifTrue: [
		self methods do: [ :method | names add: method name ] ].

	self directSupertypes do: [ :supertype |
		supertype collectInterfaceMethodNamesInto: names visited: visited ]
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> collectInterfaceMethodsMatching: methodInfo into: methods visited: visited [

	self isInterface ifTrue: [
		(visited includes: self) ifTrue: [ ^ self ].
		visited add: self.

		(self methodsNamed: methodInfo name) do: [ :candidate |
			(candidate hasSameSignatureAs: methodInfo) ifTrue: [
				methods add: candidate ] ] ].

	self directSupertypes do: [ :supertype |
		supertype
			collectInterfaceMethodsMatching: methodInfo
			into: methods
			visited: visited ]
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> collectInterfaceMethodsNamed: aName into: methods visited: visited [

	self isInterface ifTrue: [
		(visited includes: self) ifTrue: [ ^ self ].
		visited add: self.

		methods addAll: (self methodsNamed: aName) ].

	self directSupertypes do: [ :supertype |
		supertype
			collectInterfaceMethodsNamed: aName
			into: methods
			visited: visited ]
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> declaringCompilationUnit [

	^ declaringCompilationUnit
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> declaringCompilationUnit: aCompilationUnitInfo [

	declaringCompilationUnit := aCompilationUnitInfo
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> defineFrom: aFASTJavaDeclaration [

	fastDeclaration := aFASTJavaDeclaration.
	loaded := true
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> directSupertypes [

	^ interfaces
]

{ #category : 'definition' }
FamixValueJavaDeclaredTypeInfo >> famixEntityClass [

	self subclassResponsibility
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> famixType [

	^ famixType
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> famixType: aFamixType [

	famixType := aFamixType
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> fastDeclaration [

	^ fastDeclaration
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> fieldNamed: fieldName [

	^ fieldsByName
		  at: fieldName
		  ifAbsent: [
		  FamixValueInterpreterResolveError signalFor: fieldName in: self ]
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> fieldNamed: fieldName ifAbsent: aBlock [

	^ fieldsByName at: fieldName ifAbsent: aBlock
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> fieldNamed: fieldName ifAbsent: absentBlock ifPresent: presentBlock [

	| field |
	field := self fieldNamed: fieldName ifAbsent: [ ^ absentBlock value ].

	^ presentBlock value: field
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> fieldNamed: fieldName ifPresent: aBlock [

	^ fieldsByName at: fieldName ifPresent: aBlock
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> fieldsDo: aBlock [

	fieldsByName valuesDo: aBlock
]

{ #category : 'initialization' }
FamixValueJavaDeclaredTypeInfo >> initialize [

	super initialize.
	loaded := false.
	interfaces := OrderedCollection new.
	methodsByName := Dictionary new.
	fieldsByName := OrderedDictionary new.
	modifiers := 0
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> interfaceMethodNames [

	| names visited |
	names := Set new.
	visited := IdentitySet new.

	self collectInterfaceMethodNamesInto: names visited: visited.

	^ names
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> interfaceMethodsMatching: methodInfo [

	| methods |
	methods := OrderedCollection new.

	self
		collectInterfaceMethodsMatching: methodInfo
		into: methods
		visited: IdentitySet new.

	^ methods
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> interfaceMethodsNamed: aName [

	| methods visited |
	methods := OrderedCollection new.
	visited := IdentitySet new.

	self
		collectInterfaceMethodsNamed: aName
		into: methods
		visited: visited.

	^ methods
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> interfaces [

	^ interfaces
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> isAbstract [

	^ (modifiers bitAnd: FamixValueJavaModifiers abstract) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> isDeclaredType [

	^ true
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> isStrictfp [

	^ (modifiers bitAnd: FamixValueJavaModifiers strictfp) ~~ 0
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> isSubtypeOf: anotherType [

	(self isSameTypeAs: anotherType) ifTrue: [ ^ true ].

	^ self directSupertypes anySatisfy: [ :supertype |
		  supertype isSubtypeOf: anotherType ]
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> loaded [

	^ loaded
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> maximallySpecificInterfaceMethodsAmong: methods [

	| maximal |
	methods size <= 1 ifTrue: [ ^ methods ].

	maximal := methods asIdentitySet.

	1 to: methods size - 1 do: [ :i |
		i + 1 to: methods size do: [ :j |
			| first second |
			first := methods at: i.
			second := methods at: j.

			((maximal includes: first) and: [ maximal includes: second ])
				ifTrue: [
					(first hasSameSignatureAs: second) ifTrue: [
						(first declaringType isSubtypeOf: second declaringType)
							ifTrue: [ maximal remove: second ]
							ifFalse: [
								(second declaringType isSubtypeOf: first declaringType)
									ifTrue: [ maximal remove: first ] ] ] ] ] ].

	^ maximal asArray
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> maximallySpecificInterfaceMethodsMatching: methodInfo [

	^ self maximallySpecificInterfaceMethodsAmong:
		  (self interfaceMethodsMatching: methodInfo)
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> memberMethodsNamed: aName [

	self subclassResponsibility
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> methodNamed: aName applicableToTypes: argumentTypes with: interpreter [

	| potential applicable |
	potential := self
		             potentiallyApplicableMethodsNamed: aName
		             argumentCount: argumentTypes size.
	potential ifEmpty: [ ^ nil ].

	applicable := potential select: [ :method |
		              method
			              isApplicableByStrictInvocationToTypes: argumentTypes
			              with: interpreter ].
	applicable ifNotEmpty: [
		^ self
			  mostSpecificAmong: applicable
			  for: argumentTypes
			  with: interpreter ].

	applicable := potential select: [ :method |
		              method
			              isApplicableByLooseInvocationToTypes: argumentTypes
			              with: interpreter ].
	applicable ifNotEmpty: [
		^ self
			  mostSpecificAmong: applicable
			  for: argumentTypes
			  with: interpreter ].

	applicable := potential select: [ :method |
		              method
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

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> methods [

	^ methodsByName values flattened
]

{ #category : 'enumerating' }
FamixValueJavaDeclaredTypeInfo >> methodsNamed: aName [

	^ methodsByName at: aName ifAbsent: [ #(  ) ]
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> modifiersForDeclaration: declaration [

	^ FamixValueJavaModifiers fromFASTModifiers: declaration modifiers
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> modifiersForFieldDeclaration: declaration [

	^ FamixValueJavaModifiers fromFASTModifiers: declaration modifiers
]

{ #category : 'testing' }
FamixValueJavaDeclaredTypeInfo >> modifiersForMethod: fastMethod [

	^ FamixValueJavaModifiers fromFASTModifiers: fastMethod modifiers
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> mostSpecificAmong: methods for: arguments with: interpreter [

	| maximal |
	methods size = 1 ifTrue: [ ^ methods first ].

	maximal := methods asIdentitySet.

	1 to: methods size - 1 do: [ :i |
		i + 1 to: methods size do: [ :j |
			| first second |
			first := methods at: i.
			second := methods at: j.

			((maximal includes: first) and: [ maximal includes: second ])
				ifTrue: [
					(first
						 isStrictlyMoreSpecificThan: second
						 for: arguments
						 with: interpreter)
						ifTrue: [ maximal remove: second ]
						ifFalse: [
							(second
								 isStrictlyMoreSpecificThan: first
								 for: arguments
								 with: interpreter) ifTrue: [ maximal remove: first ] ] ] ] ].

	maximal size = 1 ifTrue: [ ^ maximal anyOne ].

	self error: 'Ambiguous method invocation'
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> packageName [

	^ declaringCompilationUnit packageName
]

{ #category : 'resolving' }
FamixValueJavaDeclaredTypeInfo >> potentiallyApplicableMethodsNamed: aName argumentCount: argumentCount [

	^ (self memberMethodsNamed: aName) select: [ :method |
		  method isPotentiallyApplicableToArity: argumentCount ]
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> qualifiedName [

	^ qualifiedName
]

{ #category : 'accessing' }
FamixValueJavaDeclaredTypeInfo >> qualifiedName: aString [

	qualifiedName := aString
]
