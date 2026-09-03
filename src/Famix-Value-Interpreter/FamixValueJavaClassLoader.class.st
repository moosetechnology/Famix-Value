Class {
	#name : 'FamixValueJavaClassLoader',
	#superclass : 'Object',
	#instVars : [
		'declaredTypes',
		'primitiveTypes',
		'interpreter',
		'executables',
		'invocations',
		'fieldAccesses',
		'sources',
		'explicitSource',
		'typesToLink'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaClassLoader class >> on: anInterpreter [

	^ self new interpreter: anInterpreter
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> addCompilationUnit: fastCompilationUnit [

	| unitInfo |
	explicitSource addCompilationUnit: fastCompilationUnit.

	unitInfo := FamixValueJavaCompilationUnitInfo new
		            fastCompilationUnit: fastCompilationUnit;
		            packageName: fastCompilationUnit packageName;
		            yourself.

	self indexImportsOf: fastCompilationUnit in: unitInfo.

	"Register all top-level declared types first."
	fastCompilationUnit classDeclarations do: [ :fastClass |
		self registerClass: fastClass fromCompilationUnit: unitInfo ].

	fastCompilationUnit interfaceDeclarations do: [ :fastInterface |
		self registerInterface: fastInterface fromCompilationUnit: unitInfo ].

	"Then resolve/index their contents."
	fastCompilationUnit classDeclarations do: [ :fastClass |
		self indexClass: fastClass in: unitInfo ].

	fastCompilationUnit interfaceDeclarations do: [ :fastInterface |
		self indexInterface: fastInterface in: unitInfo ].

	^ unitInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> addObservableTypeNamed: qualifiedName to: candidates [

	(self isTypeObservableNamed: qualifiedName) ifTrue: [
		candidates add: qualifiedName ]
]

{ #category : 'sources' }
FamixValueJavaClassLoader >> addSource: aClassSource [

	sources add: aClassSource
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> binaryNumericTypeOf: leftType with: rightType [

	^ interpreter binaryNumericTypeOfType: leftType with: rightType
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> enrich: typeInfo fromFamixNamed: qualifiedName [

	| famixType |
	famixType := interpreter entityFinder
		             expecting: typeInfo famixEntityClass
		             do: [
		             interpreter entityFinder findTypeNamed: qualifiedName ].

	famixType ifNotNil: [ typeInfo famixType: famixType ]
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> executableClassFor: fastMethod in: typeInfo [

	^ (self isConstructor: fastMethod of: typeInfo)
		  ifTrue: [ FamixValueJavaConstructorInfo ]
		  ifFalse: [ FamixValueJavaMethodInfo ]
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> executableFor: fastMethod in: typeInfo [

	| executable unitInfo |
	unitInfo := typeInfo declaringCompilationUnit.

	executable := (self executableClassFor: fastMethod in: typeInfo) new
		              fastMethod: fastMethod;
		              declaringType: typeInfo;
		              parameterTypes:
			              (fastMethod parameters collect: [ :parameter |
					               self resolveType: parameter type in: unitInfo ]);
		              variableArity:
			              (fastMethod parameters isNotEmpty and: [
					               fastMethod parameters last hasVariableArguments ]);
		              returnType: (fastMethod type ifNotNil: [ :type |
					               type isVoidTypeExpression ifFalse: [
							               self resolveType: type in: unitInfo ] ]);
		              modifiers: (typeInfo modifiersForMethod: fastMethod);
		              yourself.

	fastMethod parameters
		with: executable parameterTypes
		do: [ :parameter :type |
			executable localTypes at: parameter variable name put: type ].

	^ executables at: fastMethod put: executable
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> executableForFASTMethod: fastMethod [

	^ executables at: fastMethod
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> fieldForAccess: fieldAccess [

	^ fieldAccesses at: fieldAccess
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> hasTypeNamed: qualifiedName [

	declaredTypes
		at: qualifiedName
		ifPresent: [ :typeInfo | typeInfo loaded ifTrue: [ ^ true ] ].

	(explicitSource hasTypeNamed: qualifiedName) ifTrue: [ ^ true ].

	^ sources anySatisfy: [ :source | source hasTypeNamed: qualifiedName ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexClass: fastClass in: unitInfo [

	| classInfo |
	classInfo := unitInfo typeNamed: fastClass name.

	self enrich: classInfo fromFamixNamed: classInfo qualifiedName.
	self indexHierarchyOfClass: fastClass in: classInfo.
	self indexMembersOf: fastClass in: classInfo.
	self indexLocalsOfType: classInfo.

	typesToLink add: classInfo
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexConstructorInvocationOf: constructor [

	| statements first |
	constructor isImplicit ifTrue: [ ^ self ].

	statements := constructor fastMethod statementBlock statements.
	statements ifEmpty: [ ^ self ].

	first := statements first.

	first isExpressionStatement ifFalse: [ ^ self ].
	first expression isInvocation ifFalse: [ ^ self ].

	(#( 'this' 'super' ) includes: first expression name) ifTrue: [
		constructor constructorInvocation: first expression ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexFieldsFrom: declaration in: typeInfo [

	| type modifiers |
	type := self
		        resolveType: declaration type
		        in: typeInfo declaringCompilationUnit.

	modifiers := typeInfo modifiersForFieldDeclaration: declaration.

	declaration declarators do: [ :declarator |
		| name fieldInfo |
		name := declarator variable name.

		fieldInfo := FamixValueJavaFieldInfo new
			             name: name;
			             type: type;
			             declaringType: typeInfo;
			             modifiers: modifiers;
			             initializer: declarator expression.

		typeInfo famixType ifNotNil: [ :famixType |
			famixType attributes
				detect: [ :attribute | attribute name = name ]
				ifFound: [ :attribute | fieldInfo famixAttribute: attribute ]
				ifNone: [  ] ].

		typeInfo addField: fieldInfo ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexHierarchyOfClass: fastClass in: classInfo [

	fastClass superclass ifNotNil: [ :superclass |
		| superclassInfo |
		superclassInfo := self
			                  resolveType: superclass
			                  in: classInfo declaringCompilationUnit.

		superclassInfo isClass ifFalse: [
			self error:
				superclassInfo qualifiedName , ' cannot be used as a superclass' ].

		classInfo superclass: superclassInfo ].

	fastClass interfaces do: [ :interface |
		| interfaceInfo |
		interfaceInfo := self
			                 resolveType: interface
			                 in: classInfo declaringCompilationUnit.

		interfaceInfo isInterface ifFalse: [
			self error:
				interfaceInfo qualifiedName
				, ' cannot be implemented as an interface' ].

		classInfo addInterface: interfaceInfo ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexHierarchyOfInterface: fastInterface in: interfaceInfo [

	fastInterface interfaces do: [ :superinterface |
		| superinterfaceInfo |
		superinterfaceInfo := self
			                      resolveType: superinterface
			                      in: interfaceInfo declaringCompilationUnit.

		superinterfaceInfo isInterface ifFalse: [
			self error: superinterfaceInfo qualifiedName
				, ' cannot be extended by an interface' ].

		interfaceInfo addInterface: superinterfaceInfo ]
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> indexImportsOf: fastCompilationUnit in: unitInfo [

	fastCompilationUnit importDeclarations do: [ :import |
		import isStatic ifFalse: [
			import isOnDemand
				ifTrue: [
				unitInfo addOnDemandImport: import qualifiedName fullName ]
				ifFalse: [
				unitInfo addSingleTypeImport: import qualifiedName fullName ] ] ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexInterface: fastInterface in: unitInfo [

	| interfaceInfo |
	interfaceInfo := unitInfo typeNamed: fastInterface name.

	self
		enrich: interfaceInfo
		fromFamixNamed: interfaceInfo qualifiedName.
	self indexHierarchyOfInterface: fastInterface in: interfaceInfo.
	self indexMembersOf: fastInterface in: interfaceInfo.
	self indexLocalsOfType: interfaceInfo.

	typesToLink add: interfaceInfo
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexLocalsOf: executable [

	| unitInfo statementBlock |
	statementBlock := executable fastMethod statementBlock.
	statementBlock ifNil: [ ^ self ].

	unitInfo := executable declaringType declaringCompilationUnit.

	statementBlock allChildren
		select: [ :entity | entity isVarDeclStatement ]
		thenDo: [ :statement |
			| type |
			type := self resolveType: statement type in: unitInfo.

			statement declarators do: [ :declarator |
				executable localTypes at: declarator variable name put: type ] ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexLocalsOfType: typeInfo [

	typeInfo methods do: [ :methodInfo | self indexLocalsOf: methodInfo ].

	typeInfo isClass ifTrue: [
		typeInfo constructors do: [ :constructorInfo |
			constructorInfo isImplicit ifFalse: [
				self indexLocalsOf: constructorInfo ] ] ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexMembersOf: fastType in: typeInfo [

	fastType declarations do: [ :declaration |
		declaration isVarDeclStatement ifTrue: [
			self indexFieldsFrom: declaration in: typeInfo ].

		declaration isMethodEntity ifTrue: [
			| executable |
			executable := self executableFor: declaration in: typeInfo.

			executable isConstructor
				ifTrue: [
					self indexConstructorInvocationOf: executable.
					typeInfo addConstructor: executable ]
				ifFalse: [ typeInfo addMethod: executable ] ] ].

	typeInfo isClass ifTrue: [
		typeInfo constructors ifEmpty: [ "Add implicit constructor"
			typeInfo addConstructor: (FamixValueJavaConstructorInfo new
					 declaringType: typeInfo;
					 parameterTypes: #(  )) ] ]
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> initialize [

	super initialize.
	declaredTypes := Dictionary new.
	primitiveTypes := Dictionary new.
	executables := IdentityDictionary new.
	invocations := IdentityDictionary new.
	fieldAccesses := IdentityDictionary new.
	sources := OrderedCollection new.
	explicitSource := FamixValueJavaFASTSource new.
	typesToLink := OrderedCollection new
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> interpreter [

	^ interpreter
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> interpreter: anInterpreter [

	interpreter := anInterpreter
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> invocationModeFor: invocation method: method [

	method isStatic ifTrue: [ ^ #static ].

	(invocation receiver isNotNil and: [
		 invocation receiver isIdentifier and: [
			 invocation receiver name = 'super' ] ]) ifTrue: [ ^ #special ].

	method declaringType isInterface ifTrue: [ ^ #interface ].

	^ #virtual
]

{ #category : 'testing' }
FamixValueJavaClassLoader >> isConstructor: fastMethod of: typeInfo [

	^ fastMethod type isNil and: [ fastMethod name = typeInfo name ]
]

{ #category : 'testing' }
FamixValueJavaClassLoader >> isTypeLoadedNamed: qualifiedName [

	^ declaredTypes
		  at: qualifiedName
		  ifPresent: [ :typeInfo | typeInfo loaded ]
		  ifAbsent: [ false ]
]

{ #category : 'testing' }
FamixValueJavaClassLoader >> isTypeObservableNamed: qualifiedName [

	declaredTypes
		at: qualifiedName
		ifPresent: [ :typeInfo | typeInfo loaded ifTrue: [ ^ true ] ].

	^ sources anySatisfy: [ :source | source hasTypeNamed: qualifiedName ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> link [

	[ typesToLink isNotEmpty ] whileTrue: [
		| typeInfo |
		typeInfo := typesToLink removeFirst.

		typeInfo isClass ifTrue: [ typeInfo validateDefaultMethodConflicts ].

		typeInfo methods do: [ :methodInfo |
			self linkReferencesOf: methodInfo ].

		self linkReferencesOfFieldsIn: typeInfo.

		typeInfo isClass ifTrue: [
			typeInfo constructors do: [ :constructor |
				self linkConstructorInvocationOf: constructor.
				self validateImplicitSuperInvocationOf: constructor ].

			typeInfo validateConstructorInvocationCycles.

			typeInfo constructors do: [ :constructor |
				constructor isImplicit ifFalse: [
					self linkReferencesOf: constructor ] ] ] ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkClassProperty: property in: executable [

	| qualifierType fieldInfo |
	qualifierType := self
		                 staticTypeOfName: property type name
		                 in: executable
		                 ifAbsent: [
			                 self
				                 resolveTypeNamed: property type name
				                 in: executable compilationUnit ].

	fieldInfo := qualifierType fieldNamed: property fieldName.

	fieldAccesses at: property put: fieldInfo.

	^ fieldInfo
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkConstructorInvocationOf: constructor [

	| invocation targetType argumentTypes target |
	constructor isImplicit ifTrue: [ ^ self ].

	invocation := constructor constructorInvocation.
	invocation ifNil: [ ^ self ].

	targetType := invocation name = 'this'
		              ifTrue: [ constructor declaringType ]
		              ifFalse: [ constructor declaringType superclass ].

	targetType ifNil: [
		self error: 'Constructor invocation has no target superclass' ].

	argumentTypes := invocation arguments collect: [ :argument |
		                 self staticTypeOf: argument in: constructor ].

	target := targetType
		          constructorApplicableToTypes: argumentTypes
		          with: interpreter.

	target ifNil: [
		self error:
			'Unable to resolve constructor invocation ' , invocation name ].

	constructor invokedConstructor: target
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkFieldAccess: fieldAccess in: executable [

	fieldAccess isFieldAccess ifTrue: [
		^ self linkInstanceFieldAccess: fieldAccess in: executable ].

	fieldAccess isClassProperty ifTrue: [
		^ self linkClassProperty: fieldAccess in: executable ].

	self error: 'Unsupported field access: ' , fieldAccess class name
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> linkInstanceFieldAccess: fieldAccess in: executable [

	| receiverType fieldInfo |
	receiverType := self
		                staticTypeOf: fieldAccess receiver
		                in: executable.

	fieldInfo := receiverType fieldNamed: fieldAccess fieldName.

	fieldAccesses at: fieldAccess put: fieldInfo.

	^ fieldInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> linkInvocation: invocation in: executable [

	| receiverType argumentTypes method linkedInvocation |
	(executable isConstructor and: [
		 executable constructorInvocation == invocation ]) ifTrue: [ ^ nil ].

	(invocations includesKey: invocation) ifTrue: [
		^ invocations at: invocation ].

	receiverType := self
		                staticTypeOfInvocationReceiver: invocation
		                in: executable.

	receiverType loaded ifFalse: [
		receiverType := self loadTypeNamed: receiverType qualifiedName ].

	argumentTypes := invocation arguments collect: [ :argument |
		                 self staticTypeOf: argument in: executable ].

	method := receiverType
		          methodNamed: invocation name
		          applicableToTypes: argumentTypes
		          with: interpreter.

	method ifNil: [
		self error: 'Unable to link invocation ' , receiverType name , '>>'
			, invocation name ].

	linkedInvocation := FamixValueJavaLinkedInvocation new
		                    method: method;
		                    mode:
			                    (self
				                     invocationModeFor: invocation
				                     method: method);
		                    yourself.

	invocations at: invocation put: linkedInvocation.

	^ linkedInvocation
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkReferencesIn: fastEntity in: executable [

	fastEntity children do: [ :child |
		self linkReferencesIn: child in: executable ].

	fastEntity isInvocation ifTrue: [
		self linkInvocation: fastEntity in: executable ].

	(fastEntity isFieldAccess or: [ fastEntity isClassProperty ])
		ifTrue: [ self linkFieldAccess: fastEntity in: executable ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkReferencesOf: executable [

	executable fastMethod statementBlock ifNotNil: [ :statementBlock |
		self linkReferencesIn: statementBlock in: executable ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkReferencesOfFieldsIn: typeInfo [

	typeInfo fieldsDo: [ :fieldInfo |
		fieldInfo initializer ifNotNil: [ :initializer |
			self linkReferencesIn: initializer in: fieldInfo ] ]
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> linkedInvocationFor: invocation [

	^ invocations at: invocation
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> loadTypeNamed: qualifiedName [

	| compilationUnit |
	declaredTypes
		at: qualifiedName
		ifPresent: [ :typeInfo | typeInfo loaded ifTrue: [ ^ typeInfo ] ].

	sources do: [ :source |
		compilationUnit := source loadCompilationUnitForTypeNamed:
			                   qualifiedName.

		compilationUnit ifNotNil: [
			self addCompilationUnit: compilationUnit.

			^ self typeNamed: qualifiedName ifAbsent: [
				  self error:
					  'Compilation unit does not define expected type '
					  , qualifiedName ] ] ].

	FamixValueInterpreterResolveError signalFor: qualifiedName in: self
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> methodForInvocation: invocation [

	^ (self linkedInvocationFor: invocation) method
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> primitiveTypeNamed: name [

	^ primitiveTypes at: name ifAbsentPut: [
		  FamixValueJavaPrimitiveTypeInfo new
			  name: name;
			  famixType: (interpreter entityFinder
					   expecting: FamixJavaPrimitiveType
					   do: [ interpreter entityFinder findTypeNamed: name ]);
			  yourself ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> registerClass: fastClass fromCompilationUnit: unitInfo [

	| typeInfo qualifiedName |
	qualifiedName := unitInfo fastCompilationUnit qualifiedNameOf:
		                 fastClass.

	typeInfo := self
		            typeNamed: qualifiedName
		            ifAbsentPut: [
		            FamixValueJavaClassInfo named: qualifiedName ].

	typeInfo isClass ifFalse: [
		self error: qualifiedName , ' is not a class' ].

	typeInfo loaded ifTrue: [
		self error: 'Class already loaded: ' , qualifiedName ].

	typeInfo
		declaringCompilationUnit: unitInfo;
		modifiers: (typeInfo modifiersForDeclaration: fastClass);
		defineFrom: fastClass.

	unitInfo addType: typeInfo.

	^ typeInfo
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> registerInterface: fastInterface fromCompilationUnit: unitInfo [

	| typeInfo qualifiedName |
	qualifiedName := unitInfo fastCompilationUnit qualifiedNameOf:
		                 fastInterface.

	typeInfo := self
		            typeNamed: qualifiedName
		            ifAbsentPut: [
		            FamixValueJavaInterfaceInfo named: qualifiedName ].

	typeInfo isInterface ifFalse: [
		self error: qualifiedName , ' is not an interface' ].

	typeInfo loaded ifTrue: [
		self error: 'Interface already loaded: ' , qualifiedName ].

	typeInfo
		declaringCompilationUnit: unitInfo;
		modifiers: (typeInfo modifiersForDeclaration: fastInterface);
		defineFrom: fastInterface.

	unitInfo addType: typeInfo.

	^ typeInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveArrayType: type in: unitInfo [

	| baseType dimensions |
	dimensions := 1.
	baseType := type baseType.

	[ baseType isArrayTypeExpression ] whileTrue: [
		dimensions := dimensions + 1.
		baseType := baseType baseType ].

	^ FamixValueJavaArrayTypeInfo new
		  componentType: (self resolveType: baseType in: unitInfo);
		  dimensions: dimensions
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveClassType: fastType in: unitInfo [

	^ self resolveTypeNamed: fastType typeName fullName in: unitInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveImplicitlyImportedTypeNamed: name in: unitInfo [

	| candidate candidates |
	candidate := unitInfo packageName isEmpty
		             ifTrue: [ name ]
		             ifFalse: [ unitInfo packageName , '.' , name ].

	(self isTypeObservableNamed: candidate) ifTrue: [
		^ self resolveQualifiedTypeNamed: candidate ].

	candidates := OrderedCollection new.

	self addObservableTypeNamed: 'java.lang.' , name to: candidates.

	unitInfo onDemandImportsDo: [ :packageName |
		self addObservableTypeNamed: packageName , '.' , name to: candidates ].

	candidates size = 1 ifTrue: [
		^ self resolveQualifiedTypeNamed: candidates first ].

	candidates size > 1 ifTrue: [ self error: 'Ambiguous type: ' , name ].

	FamixValueInterpreterResolveError signalFor: name in: unitInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolvePrimitiveType: fastType [

	^ self primitiveTypeNamed: fastType name
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveQualifiedTypeNamed: qualifiedName [

	declaredTypes at: qualifiedName ifPresent: [ :typeInfo | ^ typeInfo ].

	(self isTypeObservableNamed: qualifiedName) ifFalse: [
		^ FamixValueInterpreterResolveError
			  signalFor: qualifiedName
			  in: self ].

	^ self loadTypeNamed: qualifiedName
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveType: fastType in: unitInfo [

	^ fastType resolveTypeWith: self in: unitInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveTypeNamed: name in: unitInfo [

	(name includes: $.) ifTrue: [
		^ self resolveQualifiedTypeNamed: name ].

	unitInfo ifNil: [ ^ self resolveQualifiedTypeNamed: name ].

	(unitInfo typeNamed: name) ifNotNil: [ :classInfo | ^ classInfo ].

	unitInfo
		singleTypeImportNamed: name
		ifPresent: [ :qualifiedName |
		^ self resolveQualifiedTypeNamed: qualifiedName ].

	^ self resolveImplicitlyImportedTypeNamed: name in: unitInfo
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> sources [

	^ sources
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> staticTypeOf: expression in: executable [

	^ expression staticTypeIn: executable with: self
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> staticTypeOfInvocationReceiver: invocation in: executable [

	| receiver name |
	receiver := invocation receiver.

	receiver ifNil: [ ^ executable declaringType ].

	receiver isIdentifier ifFalse: [
		^ self staticTypeOf: receiver in: executable ].

	name := receiver name.

	name = 'super' ifTrue: [ ^ executable declaringType superclass ].

	^ self
		  staticTypeOfName: name
		  in: executable
		  ifAbsent: [
		  self resolveTypeNamed: name in: executable compilationUnit ]
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> staticTypeOfName: name in: executable [

	^ self
		  staticTypeOfName: name
		  in: executable
		  ifAbsent: [
		  FamixValueInterpreterResolveError signalFor: name in: executable ]
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> staticTypeOfName: name in: executable ifAbsent: aBlock [

	name = 'this' ifTrue: [ ^ executable declaringType ].

	executable localTypeNamed: name ifPresent: [ :type | ^ type ].

	executable declaringType
		fieldNamed: name
		ifPresent: [ :field | ^ field type ].

	^ aBlock value
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> typeNamed: qualifiedName ifAbsent: aBlock [

	^ declaredTypes at: qualifiedName ifAbsent: aBlock
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> typeNamed: qualifiedName ifAbsentPut: aBlock [

	^ declaredTypes at: qualifiedName ifAbsentPut: aBlock
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> unaryNumericTypeOf: type [

	^ interpreter unaryNumericTypeOfType: type
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> unsupportedStaticTypeOf: expression [

	self error:
		'Static type not implemented for ' , expression class name
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> validateImplicitSuperInvocationOf: constructor [

	| superclass |
	constructor implicitlyInvokesSuper ifFalse: [ ^ self ].

	superclass := constructor declaringType superclass.
	superclass ifNil: [ ^ self ].

	(superclass zeroArgumentConstructorWith: interpreter) ifNil: [
		self error:
			'No applicable zero-argument constructor for superclass '
			, superclass qualifiedName ]
]
