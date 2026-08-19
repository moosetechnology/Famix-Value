Class {
	#name : 'FamixValueJavaClassLoader',
	#superclass : 'Object',
	#instVars : [
		'classes',
		'primitiveTypes',
		'interpreter',
		'methods',
		'invocations',
		'sources',
		'classesToLink'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaClassLoader class >> on: anInterpreter [

	^ self new interpreter: anInterpreter
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> addClass: fastClass [

	| classInfo |
	classInfo := self classNamed: fastClass name.

	classInfo loaded ifTrue: [
		self error: 'Class already loaded: ' , fastClass name ].

	classInfo defineFrom: fastClass.

	"Optional bridge if present in the FAMIX model."
	classInfo famixType: (interpreter entityFinder
			 expecting: FamixJavaClass
			 do: [ interpreter entityFinder findTypeNamed: fastClass name ]).

	fastClass declarations do: [ :declaration |
		declaration isVarDeclStatement ifTrue: [
			self indexFieldsFrom: declaration in: classInfo ].

		declaration isMethodEntity ifTrue: [
			| methodInfo |
			methodInfo := self methodInfoFor: declaration in: classInfo.
			classInfo addMethod: methodInfo ] ].

	classInfo methods do: [ :methodInfo | self indexLocalsOf: methodInfo ].

	classesToLink add: classInfo.

	^ classInfo
]

{ #category : 'adding' }
FamixValueJavaClassLoader >> addClass: fastClass fromCompilationUnit: unitInfo [

	| classInfo qualifiedName |
	qualifiedName := unitInfo packageName isEmpty
		                 ifTrue: [ fastClass name ]
		                 ifFalse: [
		                 unitInfo packageName , '.' , fastClass name ].

	classInfo := self classNamed: qualifiedName.

	classInfo loaded ifTrue: [
		self error: 'Class already loaded: ' , qualifiedName ].

	classInfo
		name: fastClass name;
		declaringCompilationUnit: unitInfo;
		defineFrom: fastClass.

	unitInfo addClass: classInfo.

	self enrich: classInfo fromFamixNamed: qualifiedName.
	self indexMembersOf: fastClass in: classInfo.
	self indexLocalsOfClass: classInfo.

	classesToLink add: classInfo.

	^ classInfo
]

{ #category : 'adding' }
FamixValueJavaClassLoader >> addCompilationUnit: fastCompilationUnit [

	| unitInfo |
	unitInfo := FamixValueJavaCompilationUnitInfo new
		            fastCompilationUnit: fastCompilationUnit;
		            packageName: (self packageNameOf: fastCompilationUnit);
		            yourself.

	fastCompilationUnit classDeclarations do: [ :fastClass |
		self addClass: fastClass fromCompilationUnit: unitInfo ].

	^ unitInfo
]

{ #category : 'sources' }
FamixValueJavaClassLoader >> addSource: aClassSource [

	sources add: aClassSource
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> binaryNumericTypeOf: leftType with: rightType [

	^ interpreter binaryNumericTypeOfType: leftType with: rightType
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> classNamed: name [

	^ classes at: name ifAbsentPut: [
		  FamixValueJavaClassInfo new
			  name: name;
			  yourself ]
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> classNamed: aName ifAbsent: aBlock [

	^ classes at: aName ifAbsent: aBlock
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexFieldsFrom: declaration in: classInfo [

	| type |
	type := self
		        resolveType: declaration type
		        in: classInfo declaringCompilationUnit.

	declaration declarators do: [ :declarator |
		| name fieldInfo |
		name := declarator variable name.
		fieldInfo := FamixValueJavaFieldInfo new
			             name: name;
			             type: type.

		classInfo famixType ifNotNil: [ :famixType |
			famixType attributes
				detect: [ :attribute | attribute name = name ]
				ifFound: [ :attribute | fieldInfo famixAttribute: attribute ]
				ifNone: [  ] ].

		classInfo addField: fieldInfo ]
]

{ #category : 'indexing' }
FamixValueJavaClassLoader >> indexLocalsOf: methodInfo [

	| unitInfo |
	unitInfo := methodInfo declaringClass declaringCompilationUnit.

	methodInfo fastMethod statementBlock allChildren
		select: [ :entity | entity isVarDeclStatement ]
		thenDo: [ :statement |
			| type |
			type := self resolveType: statement type in: unitInfo.

			statement declarators do: [ :declarator |
				methodInfo localTypes at: declarator variable name put: type ] ]
]

{ #category : 'initialization' }
FamixValueJavaClassLoader >> initialize [

	super initialize.
	classes := Dictionary new.
	primitiveTypes := Dictionary new.
	methods := IdentityDictionary new.
	invocations := IdentityDictionary new.
	sources := OrderedCollection new.
	classesToLink := OrderedCollection new
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> interpreter [

	^ interpreter
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> interpreter: anInterpreter [

	interpreter := anInterpreter
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> link [

	[ classesToLink isNotEmpty ] whileTrue: [
		| classInfo |
		classInfo := classesToLink removeFirst.

		classInfo methods do: [ :methodInfo |
			self linkInvocationsOf: methodInfo ] ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkInvocation: invocation in: methodInfo [

	| receiverType classInfo argumentTypes method |
	(invocations includesKey: invocation) ifTrue: [
		^ invocations at: invocation ].

	receiverType := self staticTypeOf: invocation receiver in: methodInfo.

	classInfo := receiverType.
	classInfo loaded ifFalse: [
		classInfo := self loadClassNamed: classInfo qualifiedName ].

	argumentTypes := invocation arguments collect: [ :argument |
		                 self staticTypeOf: argument in: methodInfo ].

	method := classInfo
		          methodNamed: invocation name
		          applicableToTypes: argumentTypes
		          with: interpreter.

	method ifNil: [
		self error: 'Unable to link invocation ' , receiverType name , '>>'
			, invocation name ].

	invocations at: invocation put: method.

	^ method
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkInvocationsIn: fastEntity in: methodInfo [

	fastEntity allChildren do: [ :child |
		self linkInvocationsIn: child in: methodInfo ].

	fastEntity isInvocation ifTrue: [
		self linkInvocation: fastEntity in: methodInfo ]
]

{ #category : 'linking' }
FamixValueJavaClassLoader >> linkInvocationsOf: methodInfo [

	self
		linkInvocationsIn: methodInfo fastMethod statementBlock
		in: methodInfo
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> loadClassNamed: qualifiedName [

	| classInfo compilationUnit |
	classInfo := self classNamed: qualifiedName.
	classInfo loaded ifTrue: [ ^ classInfo ].

	sources do: [ :source |
		compilationUnit := source loadCompilationUnitForClassNamed:
			                   qualifiedName.

		compilationUnit ifNotNil: [
			self addCompilationUnit: compilationUnit.

			classInfo loaded ifTrue: [ ^ classInfo ].

			self error:
				'Compilation unit does not define expected class ' , qualifiedName ] ].

	FamixValueInterpreterResolveError signalFor: qualifiedName in: self
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> method: methodInfo forInvocation: invocation [

	invocations at: invocation put: methodInfo
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> methodForInvocation: invocation [

	^ invocations at: invocation
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> methodInfoFor: fastMethod in: classInfo [

	| methodInfo unitInfo |
	unitInfo := classInfo declaringCompilationUnit.

	methodInfo := FamixValueJavaMethodInfo new
		              fastMethod: fastMethod;
		              declaringClass: classInfo;
		              parameterTypes:
			              (fastMethod parameters collect: [ :parameter |
					               self resolveType: parameter type in: unitInfo ]);
		              variableArity:
			              (fastMethod parameters isNotEmpty and: [
					               fastMethod parameters last hasVariableArguments ]);
		              returnType: (fastMethod type isVoidTypeExpression
				               ifTrue: [ nil ]
				               ifFalse: [
					               self resolveType: fastMethod type in: unitInfo ]);
		              yourself.

	fastMethod parameters
		with: methodInfo parameterTypes
		do: [ :parameter :type |
			methodInfo localTypes at: parameter variable name put: type ].

	^ methods at: fastMethod put: methodInfo
]

{ #category : 'loading' }
FamixValueJavaClassLoader >> methodInfoForFASTMethod: fastMethod [

	^ methods at: fastMethod
]

{ #category : 'adding' }
FamixValueJavaClassLoader >> packageNameOf: compilationUnit [

	compilationUnit packageDeclaration ifNil: [ ^ '' ].

	^ compilationUnit packageDeclaration name
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
FamixValueJavaClassLoader >> resolveClassNamed: name in: unitInfo [

	| qualifiedName |
	(name includes: $.) ifTrue: [ ^ self classNamed: name ].

	unitInfo ifNil: [ ^ self classNamed: name ].

	qualifiedName := unitInfo packageName isEmpty
		                 ifTrue: [ name ]
		                 ifFalse: [ unitInfo packageName , '.' , name ].

	^ self classNamed: qualifiedName
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveClassType: fastType in: unitInfo [

	^ self resolveClassNamed: fastType typeName name in: unitInfo
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolvePrimitiveType: fastType [

	^ self primitiveTypeNamed: fastType name
]

{ #category : 'resolving' }
FamixValueJavaClassLoader >> resolveType: fastType in: unitInfo [

	^ fastType resolveTypeWith: self in: unitInfo
]

{ #category : 'accessing' }
FamixValueJavaClassLoader >> sources [

	^ sources
]

{ #category : 'typing' }
FamixValueJavaClassLoader >> staticTypeOf: expression in: methodInfo [

	^ expression staticTypeIn: methodInfo with: self
]

{ #category : 'resolution' }
FamixValueJavaClassLoader >> staticTypeOfName: name in: methodInfo [

	name = 'this' ifTrue: [ ^ methodInfo declaringClass ].

	methodInfo localTypes at: name ifPresent: [ :type | ^ type ].

	^ (methodInfo declaringClass fieldNamed: name) type
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
