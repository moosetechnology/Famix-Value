Class {
	#name : 'FamixValueJavaInterpreter',
	#superclass : 'FamixValueInterpreter',
	#instVars : [
		'nullValue',
		'classLoader',
		'runtimeTypes'
	],
	#classVars : [
		'BinaryOperators',
		'UnaryOperators'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaInterpreter class >> entityFinderClass [

	^ FamixJavaEntityFinder
]

{ #category : 'class initialization' }
FamixValueJavaInterpreter class >> initialize [

	UnaryOperators := Dictionary new.
	BinaryOperators := Dictionary new.

	"Unary"
	UnaryOperators at: '+' put: [ :v | v ].
	UnaryOperators at: '-' put: [ :v | 0 - v ].
	UnaryOperators at: '++' put: [ :v | v + 1 ].
	UnaryOperators at: '--' put: [ :v | v - 1 ].
	UnaryOperators at: '~' put: [ :v | v bitInvert ].
	UnaryOperators at: '!' put: [ :v | v not ].

	"Multiplicative"
	BinaryOperators at: '*' put: [ :l :r | l * r ].
	BinaryOperators at: '/' put: [ :l :r | l // r ].
	BinaryOperators at: '%' put: [ :l :r | l \\ r ].

	"Additive"
	BinaryOperators at: '+' put: [ :l :r | l + r ].
	BinaryOperators at: '-' put: [ :l :r | l - r ].

	"Shift"
	BinaryOperators at: '<<' put: [ :l :r | l bitShift: r ].
	BinaryOperators at: '>>' put: [ :l :r | l bitShift: 0 - r ].
	BinaryOperators at: '>>>' put: [ :l :r | l bitShift: 0 - r ].

	"Relational"
	BinaryOperators at: '<' put: [ :l :r | l < r ].
	BinaryOperators at: '<=' put: [ :l :r | l <= r ].
	BinaryOperators at: '>' put: [ :l :r | l > r ].
	BinaryOperators at: '>=' put: [ :l :r | l >= r ].

	"Equality"
	BinaryOperators at: '==' put: [ :l :r | l = r ].
	BinaryOperators at: '!=' put: [ :l :r | l ~= r ].

	"Bitwise"
	BinaryOperators at: '&' put: [ :l :r | l bitAnd: r ].
	BinaryOperators at: '^' put: [ :l :r | l bitXor: r ].
	BinaryOperators at: '|' put: [ :l :r | l bitOr: r ]
]

{ #category : 'adding' }
FamixValueJavaInterpreter >> addField: fieldInfo to: object [

	self model newOfObjectAttribute
		object: object;
		attribute: fieldInfo famixAttribute;
		value: (fieldInfo type asDefaultValueOn: self)
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> allocateArrayOf: arrayType dimensions: dimensions [

	| array size elementType remainingDimensions |
	array := self model newOfCollection runtimeType: arrayType.

	size := (dimensions first accept: self) value.
	elementType := arrayType elementType.
	remainingDimensions := dimensions allButFirst.

	1 to: size do: [ :index |
		array value add: (FamixValueOfCollectionElement new value:
				 (remainingDimensions isEmpty
					  ifTrue: [ elementType asDefaultValueOn: self ]
					  ifFalse: [
						  remainingDimensions first isEmptyDimExpression
							  ifTrue: [ elementType asDefaultValueOn: self ]
							  ifFalse: [
							  self
								  allocateArrayOf: elementType
								  dimensions: remainingDimensions ] ])) ].

	^ array
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> allocateArrayOf: arrayType initializedBy: initializer [

	| array elementType |
	array := self model newOfCollection runtimeType: arrayType.
	elementType := arrayType elementType.

	array value: (initializer initializers collect: [ :expression |
			 FamixValueOfCollectionElement new value: ((expression isKindOf: FASTJavaArrayInitializer)
					  ifTrue: [ self allocateArrayOf: elementType initializedBy: expression ]
					  ifFalse: [ self convertAssignment: (expression accept: self) from: expression to: elementType ]) ]).

	^ array
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> allocateObjectOf: classInfo [

	| object |
	object := self model newOfObject runtimeType: classInfo.

	classInfo famixType ifNotNil: [ :famixType | object type: famixType ].

	classInfo instanceFieldsDo: [ :fieldInfo |
		| objectAttribute |
		objectAttribute := self model newOfObjectAttribute
			                   object: object;
			                   runtimeField: fieldInfo;
			                   value: (fieldInfo type asDefaultValueOn: self);
			                   yourself.

		fieldInfo famixAttribute ifNotNil: [ :famixAttribute |
			objectAttribute attribute: famixAttribute ] ].

	^ object
]

{ #category : 'typing' }
FamixValueJavaInterpreter >> binaryNumericTypeOf: left with: right [

	^ self
		  binaryNumericTypeOfType: left runtimeType
		  with: right runtimeType
]

{ #category : 'typing' }
FamixValueJavaInterpreter >> binaryNumericTypeOfType: leftType with: rightType [

	| leftTypeName rightTypeName |
	leftTypeName := leftType name.
	rightTypeName := rightType name.

	(leftTypeName = 'double' or: [ rightTypeName = 'double' ]) ifTrue: [
		^ self classLoader primitiveTypeNamed: 'double' ].

	(leftTypeName = 'float' or: [ rightTypeName = 'float' ]) ifTrue: [
		^ self classLoader primitiveTypeNamed: 'float' ].

	(leftTypeName = 'long' or: [ rightTypeName = 'long' ]) ifTrue: [
		^ self classLoader primitiveTypeNamed: 'long' ].

	^ self classLoader primitiveTypeNamed: 'int'
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> bindArguments: arguments to: executable in: frame [

	1 to: executable parameterTypes size do: [ :index |
		| parameter argument parameterType |
		parameter := executable fastMethod parameters at: index.
		argument := arguments at: index.
		parameterType := executable parameterTypes at: index.

		frame bind: parameter variable name to: (FamixValueInterpreterLocal
				 type: parameterType
				 value: (self convert: argument to: parameterType)) ]
]

{ #category : 'typing' }
FamixValueJavaInterpreter >> canWidenPrimitive: sourceType to: targetType [

	| source target |
	source := sourceType name.
	target := targetType name.

	source = target ifTrue: [ ^ true ].

	source = 'byte' ifTrue: [
		^ #( 'short' 'int' 'long' 'float' 'double' ) includes: target ].

	source = 'short' ifTrue: [
		^ #( 'int' 'long' 'float' 'double' ) includes: target ].

	source = 'char' ifTrue: [
		^ #( 'int' 'long' 'float' 'double' ) includes: target ].

	source = 'int' ifTrue: [
		^ #( 'long' 'float' 'double' ) includes: target ].

	source = 'long' ifTrue: [ ^ #( 'float' 'double' ) includes: target ].

	source = 'float' ifTrue: [ ^ target = 'double' ].

	^ false
]

{ #category : 'testing' }
FamixValueJavaInterpreter >> canWidenReference: sourceType to: targetType [

	^ sourceType canWidenTo: targetType
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> castPrimitive: value to: targetType [

	| sourceType sourceName targetName |
	sourceType := value runtimeType.
	sourceName := sourceType name.
	targetName := targetType name.
	(sourceType isSameTypeAs: targetType) ifTrue: [ ^ value ].

	(sourceName = 'boolean' or: [ targetName = 'boolean' ]) ifTrue: [ ^ self unsupportedConversionOf: value to: targetType ].

	(self canWidenPrimitive: sourceType to: targetType) ifTrue: [ ^ self convertPrimitive: value to: targetType ].

	((#( 'float' 'double' ) includes: sourceName) and: [ #( 'byte' 'short' 'char' 'int' 'long' ) includes: targetName ]) ifTrue: [
		^ self floatingValue: value value narrowedToIntegralType: targetType ].

	^ self narrowPrimitiveValue: value value from: sourceType to: targetType
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> castReference: value to: targetType [

	(value runtimeType isSameTypeAs: targetType) ifTrue: [ ^ value ].
	(value runtimeType isSubtypeOf: targetType) ifTrue: [ ^ value ].

	^ self unsupportedConversionOf: value to: targetType
]

{ #category : 'accessing' }
FamixValueJavaInterpreter >> classLoader [

	^ classLoader ifNil: [
		  classLoader := FamixValueJavaClassLoader on: self ]
]

{ #category : 'accessing' }
FamixValueJavaInterpreter >> classLoader: aClassLoader [

	classLoader := aClassLoader
]

{ #category : 'assignments' }
FamixValueJavaInterpreter >> compoundAssignment: operator location: location right: rhs [

	| left baseOperator promotedType result |
	left := location value.
	baseOperator := operator allButLast.

	location type name = 'boolean' ifTrue: [
		(#( '&' '|' '^' ) includes: baseOperator) ifFalse: [ self error: 'Invalid boolean compound assignment operator: ' , operator ].
		result := baseOperator = '&'
			          ifTrue: [ left value & rhs value ]
			          ifFalse: [
				          baseOperator = '|'
					          ifTrue: [ left value | rhs value ]
					          ifFalse: [ left value ~= rhs value ] ].
		^ self newBoolean value: result ].

	(#( '<<' '>>' '>>>' ) includes: baseOperator) ifTrue: [
		result := self javaShiftOperation: baseOperator left: left right: rhs.
		^ self narrowCompoundAssignmentValue: result value from: result runtimeType to: location type ].

	promotedType := self binaryNumericTypeOf: left with: rhs.
	result := self
		          javaNumericOperation: baseOperator
		          left: left
		          right: rhs
		          type: promotedType.
	^ self narrowCompoundAssignmentValue: result value from: promotedType to: location type
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> conditionalNumericTypeOf: firstExpression type: firstType and: secondExpression type: secondType [

	| intType |
	intType := self classLoader primitiveTypeNamed: 'int'.

	((firstType name = 'byte' and: [ secondType name = 'short' ]) or: [ firstType name = 'short' and: [ secondType name = 'byte' ] ])
		ifTrue: [ ^ self classLoader primitiveTypeNamed: 'short' ].

	((firstType isSameTypeAs: intType) and: [
		 (#( 'byte' 'short' 'char' ) includes: secondType name) and: [
			 (self isIntegerConstantExpression: firstExpression) and: [
				 self integerValue: (self integerConstantValueOf: firstExpression) isRepresentableIn: secondType ] ] ]) ifTrue: [
		^ secondType ].

	((secondType isSameTypeAs: intType) and: [
		 (#( 'byte' 'short' 'char' ) includes: firstType name) and: [
			 (self isIntegerConstantExpression: secondExpression) and: [
				 self integerValue: (self integerConstantValueOf: secondExpression) isRepresentableIn: firstType ] ] ]) ifTrue: [ ^ firstType ].

	^ self binaryNumericTypeOfType: firstType with: secondType
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convert: value to: targetType [

	value == self nullValue ifTrue: [ ^ self convertNullTo: targetType ].

	(value runtimeType isSameTypeAs: targetType) ifTrue: [ ^ value ].

	(value isOfPrimitiveType and: [ targetType isPrimitiveType ])
		ifTrue: [ ^ self convertPrimitive: value to: targetType ].

	value isOfObject ifTrue: [
		^ self convertReference: value to: targetType ].

	^ self unsupportedConversionOf: value to: targetType
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convertAssignment: value from: expression to: targetType [

	| sourceType targetName integerValue |
	[ ^ self convert: value to: targetType ]
		on: Error
		do: [ :error |
			sourceType := value runtimeType.
			targetName := targetType name.
			(sourceType name = 'int' and: [ #( 'byte' 'short' 'char' ) includes: targetName ]) ifFalse: [ error pass ].
			(self isIntegerConstantExpression: expression) ifFalse: [ error pass ].
			integerValue := self numericOperandValue: value value.
			(self integerValue: integerValue isRepresentableIn: targetType) ifFalse: [ error pass ].
			^ self narrowPrimitiveValue: integerValue from: sourceType to: targetType ]
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convertNullTo: targetType [

	targetType isPrimitiveType ifTrue: [
		self error:
			'Cannot convert null to primitive type ' , targetType name ].

	^ self nullValue
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convertPrimitive: value to: targetType [

	| primitiveValue |
	(self canWidenPrimitive: value runtimeType to: targetType) ifFalse: [
		self error: 'Invalid primitive conversion from ' , value runtimeType name , ' to ' , targetType name ].

	primitiveValue := value value.
	(value runtimeType name = 'char' and: [ targetType name ~= 'char' ]) ifTrue: [ primitiveValue := primitiveValue asInteger ].

	^ self newPrimitiveOfType: targetType value: primitiveValue
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convertReference: value to: targetType [

	(value runtimeType canWidenTo: targetType) ifFalse: [
		^ self unsupportedConversionOf: value to: targetType ].

	^ value
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> currentCompilationUnit [

	^ self frame executable compilationUnit
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> currentExecutable [

	^ self frame executable
]

{ #category : 'declarations' }
FamixValueJavaInterpreter >> declareVariable: declarator ofType: type [

	| location value |
	self frame declare: declarator variable name type: type.

	location := self frame resolveLocation: declarator variable name.

	declarator expression ifNotNil: [ :initializer |
		value := initializer accept: self.
		location value: (self convertAssignment: value from: initializer to: type) ]
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> defaultValueOfPrimitiveType: typeInfo [

	| typeName value |
	typeName := typeInfo name.
	value := typeName = 'boolean'
		         ifTrue: [ false ]
		         ifFalse: [
			         typeName = 'char'
				         ifTrue: [ Character null ]
				         ifFalse: [
					         (#( 'float' 'double' ) includes: typeName)
						         ifTrue: [ 0.0 ]
						         ifFalse: [ 0 ] ] ].

	^ self newPrimitiveOfType: typeInfo value: value
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> execute: fastMethod on: receiver with: arguments [

	^ self
		  executeMethod:
		  (self classLoader executableForFASTMethod: fastMethod)
		  on: receiver
		  with: arguments
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeBodyOf: constructor [

	| statements startIndex result |
	statements := constructor fastMethod statementBlock statements.

	startIndex := constructor hasExplicitConstructorInvocation
		              ifTrue: [ 2 ]
		              ifFalse: [ 1 ].

	startIndex to: statements size do: [ :index |
		result := (statements at: index) accept: self.

		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			^ result ] ].

	^ result
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeConstructor: constructor on: object with: arguments [

	constructor isImplicit ifTrue: [
		^ self executeImplicitConstructor: constructor on: object ].

	^ self
		  executeExplicitConstructor: constructor
		  on: object
		  with: arguments
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeExplicitConstructor: constructor on: object with: arguments [

	| frame |
	frame := FamixValueInterpreterFrame new
		         executable: constructor;
		         receiver: object.

	self bindArguments: arguments to: constructor in: frame.

	^ self inFrame: frame do: [
		  self prepareConstructionFor: constructor on: object.

		  self executeBodyOf: constructor ]
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeFamixMain: famixMethod [

	| arguments |
	famixMethod parentType generateFastIfNotDoneAndBind.

	arguments := { (self model newOfCollection type:
		              (FamixValueJavaArrayTypeInfo new
			               componentType:
				               famixMethod parameters first declaredType;
			               dimensions: 1)) }.

	^ self execute: famixMethod fast with: arguments
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeImplicitConstructor: constructor on: object [

	| frame |
	frame := FamixValueInterpreterFrame new
		         executable: constructor;
		         receiver: object.

	^ self inFrame: frame do: [
		  self initializeSuperclassOf: constructor declaringType on: object.

		  self
			  initializeFieldsDeclaredBy: constructor declaringType
			  on: object ]
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeInitializer: initializerInfo on: receiver [

	| frame |
	frame := FamixValueInterpreterFrame new
		         executable: initializerInfo;
		         receiver: receiver.
	^ self inFrame: frame do: [
		  self executeStatementsOf:
			  initializerInfo fastInitializer statementBlock ]
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeMain: main [

	| methodInfo arrayType argument |
	methodInfo := self classLoader executableForFASTMethod: main.
	arrayType := methodInfo parameterTypes first.

	argument := self model newOfCollection runtimeType: arrayType.

	^ self execute: main with: { argument }
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeMethod: executable on: receiver with: arguments [

	| frame result |
	executable isStatic ifTrue: [
		self initializeType: executable declaringType ].
	frame := FamixValueInterpreterFrame new
		         executable: executable;
		         receiver: receiver.
	self bindArguments: arguments to: executable in: frame.
	result := self
		          inFrame: frame
		          do: [
		          self executeStatementsOf:
			          executable fastMethod statementBlock ].
	(result isKindOf: FamixValueInterpreterReturn) ifTrue: [
		^ self returnValue: result value from: executable ].
	^ result
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> executeStatementsOf: aFASTJavaStatementBlock [

	| result |
	aFASTJavaStatementBlock statements do: [ :statement |
		result := statement accept: self.
		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			^ result ] ].
	^ nil
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> floatingValue: value narrowedToIntegralType: targetType [

	| targetName minimum maximum integerValue intermediateType |
	targetName := targetType name.
	targetName = 'long'
		ifTrue: [
			minimum := -9223372036854775808.
			maximum := 9223372036854775807.
			intermediateType := targetType ]
		ifFalse: [
			minimum := -2147483648.
			maximum := 2147483647.
			intermediateType := self classLoader primitiveTypeNamed: 'int' ].

	integerValue := value isNaN
		                ifTrue: [ 0 ]
		                ifFalse: [
			                value <= minimum
				                ifTrue: [ minimum ]
				                ifFalse: [
					                value >= maximum
						                ifTrue: [ maximum ]
						                ifFalse: [ value truncated ] ] ].

	(targetType isSameTypeAs: intermediateType) ifTrue: [ ^ self newPrimitiveOfType: targetType value: integerValue ].

	^ self narrowPrimitiveValue: integerValue from: intermediateType to: targetType
]

{ #category : 'initialization' }
FamixValueJavaInterpreter >> initialize [

	super initialize.
	runtimeTypes := IdentityDictionary new
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> initialize: object from: newExpression [

	| classInfo arguments argumentTypes constructor |
	classInfo := object runtimeType.

	arguments := newExpression arguments collect: [ :argument |
		             argument accept: self ].

	argumentTypes := arguments collect: [ :argument |
		                 argument runtimeType ].

	constructor := classInfo
		               constructorApplicableToTypes: argumentTypes
		               with: self.

	constructor ifNil: [
		self error:
			'No applicable constructor for ' , classInfo qualifiedName ].

	self executeConstructor: constructor on: object with: arguments.

	^ object
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> initializeField: fieldInfo on: object [

	| frame location value |
	frame := FamixValueInterpreterFrame new
		         executable: fieldInfo;
		         receiver: object.
	value := self
		         inFrame: frame
		         do: [ fieldInfo initializer accept: self ].
	location := self locationOfField: fieldInfo on: object.
	location value: (self convert: value to: fieldInfo type)
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> initializeFieldsDeclaredBy: classInfo on: object [

	classInfo initializationMembersDo: [ :member |
		member isStatic ifFalse: [
			member isField
				ifTrue: [
					member initializer ifNotNil: [
						self initializeField: member on: object ] ]
				ifFalse: [ self executeInitializer: member on: object ] ] ]
]

{ #category : 'class initialization' }
FamixValueJavaInterpreter >> initializeStaticField: fieldInfo in: runtimeType [

	| frame value |
	frame := FamixValueInterpreterFrame new
		         executable: fieldInfo;
		         receiver: nil.

	value := self
		         inFrame: frame
		         do: [ fieldInfo initializer accept: self ].

	runtimeType
		staticValueOf: fieldInfo
		put: (self convert: value to: fieldInfo type)
]

{ #category : 'class initialization' }
FamixValueJavaInterpreter >> initializeStaticFieldsOf: typeInfo in: runtimeType [

	typeInfo initializationMembersDo: [ :member |
		member isStatic ifTrue: [
			member isField
				ifTrue: [
					member initializer ifNotNil: [
						self initializeStaticField: member in: runtimeType ] ]
				ifFalse: [ self executeInitializer: member on: nil ] ] ]
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> initializeSuperclassOf: classInfo on: object [

	| superclass constructor |
	superclass := classInfo superclass.
	superclass ifNil: [ ^ self ].

	constructor := superclass zeroArgumentConstructorWith: self.

	constructor ifNil: [
		self error:
			'No applicable zero-argument constructor for superclass '
			, superclass qualifiedName ].

	self executeConstructor: constructor on: object with: #(  )
]

{ #category : 'class initialization' }
FamixValueJavaInterpreter >> initializeSupertypesOf: typeInfo [

	typeInfo isClass ifFalse: [ ^ self ].

	typeInfo superclass ifNotNil: [ :superclass |
		self initializeType: superclass ].

	typeInfo defaultMethodInitializationDependenciesDo: [ :interface |
		self initializeType: interface ]
]

{ #category : 'class initialization' }
FamixValueJavaInterpreter >> initializeType: typeInfo [

	| runtimeType state |
	runtimeType := self runtimeTypeFor: typeInfo.
	state := runtimeType initializationState.

	state = #initialized ifTrue: [ ^ runtimeType ].
	state = #initializing ifTrue: [ ^ runtimeType ].
	state = #erroneous ifTrue: [
		self error:
			'Type initialization previously failed: ' , typeInfo qualifiedName ].

	runtimeType initializationState: #initializing.

	[
	self initializeSupertypesOf: typeInfo.
	self initializeStaticFieldsOf: typeInfo in: runtimeType.
	runtimeType initializationState: #initialized ]
		on: Error
		do: [ :error |
			runtimeType initializationState: #erroneous.
			error pass ].

	^ runtimeType
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> instantiate: newExpression [

	| classInfo object |
	classInfo := self resolveType: newExpression type.

	self initializeType: classInfo.

	object := self allocateObjectOf: classInfo.
	self initialize: object from: newExpression.

	^ object
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> integerConstantValueOf: expression [

	| operand left right operator |
	(expression isKindOf: FASTJavaIntegerLiteral) ifTrue: [ ^ expression primitiveValue asInteger ].
	(expression isKindOf: FASTJavaCharacterLiteral) ifTrue: [ ^ expression primitiveValue first asInteger ].
	(expression isKindOf: FASTJavaUnaryExpression) ifTrue: [
		operand := self integerConstantValueOf: expression expression.
		expression operator = '+' ifTrue: [ ^ operand ].
		expression operator = '-' ifTrue: [ ^ operand negated ].
		expression operator = '~' ifTrue: [ ^ operand bitInvert ] ].
	(expression isKindOf: FASTJavaInfixOperation) ifTrue: [
		left := self integerConstantValueOf: expression leftOperand.
		right := self integerConstantValueOf: expression rightOperand.
		operator := expression operator.
		operator = '+' ifTrue: [ ^ left + right ].
		operator = '-' ifTrue: [ ^ left - right ].
		operator = '*' ifTrue: [ ^ left * right ].
		operator = '/' ifTrue: [ ^ left quo: right ].
		operator = '%' ifTrue: [ ^ left rem: right ].
		operator = '<<' ifTrue: [ ^ left bitShift: (right bitAnd: 31) ].
		operator = '>>' ifTrue: [ ^ left bitShift: (right bitAnd: 31) negated ].
		operator = '>>>' ifTrue: [ ^ (left bitAnd: 16rFFFFFFFF) bitShift: (right bitAnd: 31) negated ].
		operator = '&' ifTrue: [ ^ left bitAnd: right ].
		operator = '|' ifTrue: [ ^ left bitOr: right ].
		operator = '^' ifTrue: [ ^ left bitXor: right ] ].
	self error: 'Not an integer constant expression'
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> integerValue: value isRepresentableIn: targetType [

	targetType name = 'byte' ifTrue: [ ^ value between: -128 and: 127 ].
	targetType name = 'short' ifTrue: [ ^ value between: -32768 and: 32767 ].
	targetType name = 'char' ifTrue: [ ^ value between: 0 and: 65535 ].
	^ false
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> invokeExplicitConstructorFrom: constructor on: object [

	| invocation arguments |
	invocation := constructor constructorInvocation.

	arguments := invocation arguments collect: [ :argument |
		             argument accept: self ].

	^ self
		  executeConstructor: constructor invokedConstructor
		  on: object
		  with: arguments
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> isIntegerConstantExpression: expression [

	(expression isKindOf: FASTJavaIntegerLiteral) ifTrue: [ ^ true ].
	(expression isKindOf: FASTJavaCharacterLiteral) ifTrue: [ ^ true ].
	(expression isKindOf: FASTJavaUnaryExpression) ifTrue: [
		^ (#( '+' '-' '~' ) includes: expression operator) and: [ self isIntegerConstantExpression: expression expression ] ].
	(expression isKindOf: FASTJavaInfixOperation) ifTrue: [
		^ (#( '*' '/' '%' '+' '-' '<<' '>>' '>>>' '&' '^' '|' ) includes: expression operator) and: [
			  (self isIntegerConstantExpression: expression leftOperand) and: [ self isIntegerConstantExpression: expression rightOperand ] ] ].

	^ false
]

{ #category : 'testing' }
FamixValueJavaInterpreter >> isRelationalOperator: operator [

	^ #( '<' '<=' '>' '>=' ) includes: operator
]

{ #category : 'testing' }
FamixValueJavaInterpreter >> isType: sourceType compatibleByLooseInvocationWith: targetType [

	(self isType: sourceType compatibleByStrictInvocationWith: targetType)
		ifTrue: [ ^ true ].

	self flag: #TODO. "JLS 5.3: boxing/unboxing invocation conversion."
	^ false
]

{ #category : 'testing' }
FamixValueJavaInterpreter >> isType: sourceType compatibleByStrictInvocationWith: targetType [

	(sourceType isSameTypeAs: targetType) ifTrue: [ ^ true ].

	(sourceType isPrimitiveType and: [ targetType isPrimitiveType ])
		ifTrue: [ ^ self canWidenPrimitive: sourceType to: targetType ].

	^ self canWidenReference: sourceType to: targetType
]

{ #category : 'testing' }
FamixValueJavaInterpreter >> isType: firstType moreSpecificThan: secondType for: argumentType [
	"JLS 15.12.2.5, subset currently supported: ordinary non-poly expressions and non-generic methods."

	(firstType isSameTypeAs: secondType) ifTrue: [ ^ true ].

	"Reference types: ordinary subtyping."
	(firstType isPrimitiveType not and: [ secondType isPrimitiveType not ])
		ifTrue: [ ^ firstType isSubtypeOf: secondType ].

	"Primitive overloads: compare applicability from the
	static argument type."
	(firstType isPrimitiveType and: [ secondType isPrimitiveType ])
		ifTrue: [
			^ (self
				   isType: argumentType
				   compatibleByStrictInvocationWith: firstType) and: [
				  (self
					   isType: argumentType
					   compatibleByStrictInvocationWith: secondType) and: [
					  self canWidenPrimitive: firstType to: secondType ] ] ].

	^ false
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> javaNumericOperation: operator left: left right: right type: type [

	| leftValue rightValue value |
	leftValue := self numericOperandValue: left value.
	rightValue := self numericOperandValue: right value.

	(operator = '/' and: [ #( 'int' 'long' ) includes: type name ]) ifTrue: [
		value := leftValue quo: rightValue.
		^ self narrowPrimitiveValue: value from: type to: type ].

	(operator = '%' and: [ #( 'int' 'long' ) includes: type name ]) ifTrue: [
		value := leftValue rem: rightValue.
		^ self narrowPrimitiveValue: value from: type to: type ].

	value := self operate: operator with: left with: right.
	^ self narrowPrimitiveValue: value from: type to: type
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> javaShiftOperation: operator left: left right: right [

	| type leftValue distance width mask unsigned value |
	type := self unaryNumericTypeOf: left.
	leftValue := self numericOperandValue: left value.
	distance := (self numericOperandValue: right value) asInteger.
	width := type name = 'long'
		         ifTrue: [ 64 ]
		         ifFalse: [ 32 ].
	distance := distance bitAnd: width - 1.

	operator = '<<' ifTrue: [
		value := leftValue bitShift: distance.
		^ self narrowPrimitiveValue: value from: type to: type ].

	operator = '>>' ifTrue: [
		value := leftValue bitShift: 0 - distance.
		^ self narrowPrimitiveValue: value from: type to: type ].

	mask := (1 bitShift: width) - 1.
	unsigned := leftValue bitAnd: mask.
	value := unsigned bitShift: 0 - distance.
	^ self narrowPrimitiveValue: value from: type to: type
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOf: expression [

	^ expression locationIn: self
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfArrayAccess: access [

	| array index |
	array := access array accept: self.
	index := (access expression accept: self) value + 1.

	^ FamixValueInterpreterArrayElementLocation new
		  array: array;
		  index: index;
		  type: array runtimeType elementType
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfField: fieldInfo on: receiver [

	| objectAttribute |
	objectAttribute := receiver value
		                   detect: [ :each | each runtimeField == fieldInfo ]
		                   ifNone: [
			                   FamixValueInterpreterResolveError
				                   signalFor: fieldInfo name
				                   in: receiver ].

	^ FamixValueInterpreterFieldLocation new
		  objectAttribute: objectAttribute;
		  type: fieldInfo type
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfFieldAccess: fieldAccess [

	| fieldInfo receiver |
	fieldInfo := self classLoader fieldForAccess: fieldAccess.
	receiver := fieldAccess receiver accept: self.

	^ self locationOfField: fieldInfo on: receiver
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfFieldNamed: name on: receiver [

	^ self
		  locationOfField: (receiver runtimeType fieldNamed: name)
		  on: receiver
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfName: name [

	(self frame hasLocal: name) ifTrue: [
		^ self frame resolveLocation: name ].

	self currentExecutable declaringType
		fieldNamed: name
		ifPresent: [ :field |
			field isStatic ifTrue: [ ^ self locationOfStaticField: field ] ].

	self frame receiver ifNotNil: [ :receiver |
		^ self locationOfFieldNamed: name on: receiver ].

	FamixValueInterpreterResolveError signalFor: name in: self frame
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfProperty: property [

	| fieldInfo |
	fieldInfo := self classLoader fieldForAccess: property.

	fieldInfo isStatic ifTrue: [ ^ self locationOfStaticField: fieldInfo ].

	^ self locationOfField: fieldInfo on: (property type accept: self)
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfStaticField: fieldInfo [

	^ FamixValueJavaStaticFieldLocation new
		  runtimeType: (self initializeType: fieldInfo declaringType);
		  fieldInfo: fieldInfo
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfVariable: expression [

	expression name = self receiverName ifTrue: [
		^ self unsupportedLocationOf: expression ].

	^ self locationOfName: expression name
]

{ #category : 'accessing' }
FamixValueJavaInterpreter >> model: aFamixValueJavaModel [

	model := aFamixValueJavaModel.
	nullValue := nil
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> narrowCompoundAssignmentValue: value from: sourceType to: targetType [

	((#( 'float' 'double' ) includes: sourceType name) and: [ #( 'byte' 'short' 'char' 'int' 'long' ) includes: targetType name ])
		ifTrue: [ ^ self floatingValue: value narrowedToIntegralType: targetType ].

	^ self narrowPrimitiveValue: value from: sourceType to: targetType
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> narrowPrimitiveValue: value from: sourceType to: targetType [

	| targetName integerValue narrowed |
	targetName := targetType name.
	integerValue := self numericOperandValue: value.

	narrowed := targetName = 'byte'
		            ifTrue: [
			            integerValue := integerValue asInteger bitAnd: 16rFF.
			            integerValue >= 16r80
				            ifTrue: [ integerValue - 16r100 ]
				            ifFalse: [ integerValue ] ]
		            ifFalse: [
			            targetName = 'short'
				            ifTrue: [
					            integerValue := integerValue asInteger bitAnd: 16rFFFF.
					            integerValue >= 16r8000
						            ifTrue: [ integerValue - 16r10000 ]
						            ifFalse: [ integerValue ] ]
				            ifFalse: [
					            targetName = 'char'
						            ifTrue: [ Character value: (integerValue asInteger bitAnd: 16rFFFF) ]
						            ifFalse: [
							            targetName = 'int'
								            ifTrue: [
									            integerValue := integerValue asInteger bitAnd: 16rFFFFFFFF.
									            integerValue >= 16r80000000
										            ifTrue: [ integerValue - 16r100000000 ]
										            ifFalse: [ integerValue ] ]
								            ifFalse: [
									            targetName = 'long'
										            ifTrue: [
											            integerValue := integerValue asInteger bitAnd: 16rFFFFFFFFFFFFFFFF.
											            integerValue >= 16r8000000000000000
												            ifTrue: [ integerValue - 16r10000000000000000 ]
												            ifFalse: [ integerValue ] ]
										            ifFalse: [ value ] ] ] ] ].

	^ self newPrimitiveOfType: targetType value: narrowed
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newBoolean [

	^ self newPrimitiveOfTypeNamed: 'boolean'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newByte [

	^ self newPrimitiveOfTypeNamed: 'byte'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newCharacter [

	^ self newPrimitiveOfTypeNamed: 'char'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newDouble [

	^ self newPrimitiveOfTypeNamed: 'double'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newFloat [

	^ self newPrimitiveOfTypeNamed: 'float'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newInteger [

	^ self newPrimitiveOfTypeNamed: 'int'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newLong [

	^ self newPrimitiveOfTypeNamed: 'long'
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newPrimitiveOfType: typeInfo value: value [

	^ self model newOfPrimitiveType
		  type: typeInfo famixType;
		  runtimeType: typeInfo;
		  value: value
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newPrimitiveOfTypeNamed: typeName [

	| typeInfo |
	typeInfo := self classLoader primitiveTypeNamed: typeName.

	^ self model newOfPrimitiveType
		  type: typeInfo famixType;
		  runtimeType: typeInfo
]

{ #category : 'runtime types' }
FamixValueJavaInterpreter >> newRuntimeTypeFor: typeInfo [

	| runtimeType |
	runtimeType := FamixValueJavaRuntimeType of: typeInfo.

	typeInfo fieldsDo: [ :fieldInfo |
		fieldInfo isStatic ifTrue: [
			runtimeType
				staticValueOf: fieldInfo
				put: (fieldInfo type asDefaultValueOn: self) ] ].

	^ runtimeType
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> newShort [

	^ self newPrimitiveOfTypeNamed: 'short'
]

{ #category : 'accessing' }
FamixValueJavaInterpreter >> nullValue [

	^ nullValue ifNil: [ nullValue := self model newOfUnknownType ]
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> numericOperandValue: value [

	^ value isCharacter
		  ifTrue: [ value asInteger ]
		  ifFalse: [ value ]
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> operate: operator with: value [

	^ UnaryOperators
		  at: operator
		  ifPresent: [ :operation | operation value: (self numericOperandValue: value value) ]
		  ifAbsent: [ FamixValueInterpreterUnknownOperator signalFor: operator ]
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> operate: operator with: left with: right [

	^ BinaryOperators
		  at: operator
		  ifPresent: [ :operation |
		  operation value: (self numericOperandValue: left value) value: (self numericOperandValue: right value) ]
		  ifAbsent: [ FamixValueInterpreterUnknownOperator signalFor: operator ]
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> prepareConstructionFor: constructor on: object [

	| invocation |
	invocation := constructor constructorInvocation.

	invocation ifNil: [
		self initializeSuperclassOf: constructor declaringType on: object.
		^ self
			  initializeFieldsDeclaredBy: constructor declaringType
			  on: object ].

	invocation name = 'this' ifTrue: [
		^ self invokeExplicitConstructorFrom: constructor on: object ].

	"super(...)"
	self invokeExplicitConstructorFrom: constructor on: object.

	self initializeFieldsDeclaredBy: constructor declaringType on: object
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> receiverForFieldAccess: fieldAccess [

	| receiver |
	receiver := fieldAccess receiver.

	(receiver isVariableExpression and: [ receiver name = 'super' ])
		ifTrue: [ ^ self frame receiver ].

	^ receiver accept: self
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> receiverForInvocation: invocation linkedAs: linkedInvocation [

	| syntacticReceiver |
	syntacticReceiver := invocation receiver.

	syntacticReceiver ifNil: [
		^ linkedInvocation mode = #static
			  ifTrue: [ nil ]
			  ifFalse: [ self frame receiver ] ].

	syntacticReceiver name = 'super' ifTrue: [ ^ self frame receiver ].

	linkedInvocation mode = #static ifTrue: [ ^ nil ].

	^ syntacticReceiver accept: self
]

{ #category : 'hooks' }
FamixValueJavaInterpreter >> receiverName [

	^ 'this'
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> resolveType: fastType [

	^ self classLoader
		  resolveType: fastType
		  in: self currentCompilationUnit
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> returnValue: value from: executable [

	executable returnType ifNil: [ ^ nil ].

	^ self convert: value to: executable returnType
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> runtimeMethodFor: linkedInvocation on: receiver [

	linkedInvocation mode = #virtual ifTrue: [
		^ receiver runtimeType implementationOf: linkedInvocation method ].

	linkedInvocation mode = #interface ifTrue: [
		^ receiver runtimeType implementationOf: linkedInvocation method ].

	^ linkedInvocation method
]

{ #category : 'runtime types' }
FamixValueJavaInterpreter >> runtimeTypeFor: typeInfo [

	^ runtimeTypes
		  at: typeInfo
		  ifAbsentPut: [ self newRuntimeTypeFor: typeInfo ]
]

{ #category : 'typing' }
FamixValueJavaInterpreter >> unaryNumericTypeOf: value [

	^ self unaryNumericTypeOfType: value runtimeType
]

{ #category : 'typing' }
FamixValueJavaInterpreter >> unaryNumericTypeOfType: type [

	(#( 'byte' 'short' 'char' ) includes: type name) ifTrue: [
		^ self classLoader primitiveTypeNamed: 'int' ].

	^ type
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> unsupportedConversionOf: value to: targetType [

	| sourceName |
	sourceName := value runtimeType
		              ifNil: [ value class name ]
		              ifNotNil: [ :type | type name ].

	self error:
		'Unsupported conversion from ' , sourceName , ' to '
		, targetType name
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitAnd: expression [

	| left |
	left := expression leftOperand accept: self.
	left value ifFalse: [ ^ self newBoolean value: false ].

	^ self newBoolean value: (expression rightOperand accept: self) value
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitComparison: expression [

	| left right result |
	left := expression leftOperand accept: self.
	right := expression rightOperand accept: self.

	result := self operate: expression operator with: left with: right.

	^ self newBoolean value: result
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitEquality: expression [

	| left right equal |
	left := expression leftOperand accept: self.
	right := expression rightOperand accept: self.

	equal := (left isOfPrimitiveType and: [ right isOfPrimitiveType ])
		         ifTrue: [ left value = right value ]
		         ifFalse: [ left == right ].

	expression operator = '!=' ifTrue: [ equal := equal not ].

	^ self newBoolean value: equal
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaArrayAccess: access [

	^ (self locationOfArrayAccess: access) value
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaAssignmentExpression: assignment [

	| location rhs newValue |
	location := self locationOf: assignment variable.
	rhs := assignment expression accept: self.

	newValue := assignment operator = '='
		            ifTrue: [ self convertAssignment: rhs from: assignment expression to: location type ]
		            ifFalse: [ self compoundAssignment: assignment operator location: location right: rhs ].

	location value: newValue.
	^ newValue
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaBooleanLiteral: literal [

	^ self newBoolean value: literal primitiveValue = 'true'
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaBreakStatement: aFASTJavaBreakStatement [

	^ FamixValueInterpreterBreak new
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaCastExpression: expression [

	| value targetType |
	value := expression expression accept: self.
	targetType := self resolveType: expression type.

	value == self nullValue ifTrue: [ ^ self convertNullTo: targetType ].

	(value isOfPrimitiveType and: [ targetType isPrimitiveType ]) ifTrue: [ ^ self castPrimitive: value to: targetType ].

	(value isOfObject and: [ targetType isPrimitiveType not ]) ifTrue: [ ^ self castReference: value to: targetType ].

	^ self unsupportedConversionOf: value to: targetType
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaCharacterLiteral: literal [

	^ self newCharacter value: literal primitiveValue first
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaClassProperty: property [

	^ (self locationOfProperty: property) value
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaConditionalExpression: expression [

	(expression condition accept: self) value ifTrue: [ ^ expression thenPart accept: self ].

	^ expression elsePart accept: self
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaContinueStatement: aFASTJavaContinueStatement [

	^ FamixValueInterpreterContinue new
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaDoWhileStatement: aFASTJavaDoWhileStatement [

	| continue |
	continue := true.
	[ continue ] whileTrue: [
		| result |
		result := aFASTJavaDoWhileStatement body accept: self.
		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			result isReturn ifTrue: [ ^ result ].
			result isBreak ifTrue: [ ^ nil ] ].
		continue := (aFASTJavaDoWhileStatement condition accept: self) value ].
	^ nil
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaDoubleLiteral: literal [

	^ self newDouble value: literal primitiveValue asNumber
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaExpressionStatement: aFASTJavaExpressionStatement [

	aFASTJavaExpressionStatement expression accept: self
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> visitFASTJavaFieldAccess: expression [

	^ (self locationOfFieldAccess: expression) value
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaFloatLiteral: literal [

	| primitiveValue |
	primitiveValue := literal primitiveValue.

	((primitiveValue endsWith: 'f') or: [ primitiveValue endsWith: 'F' ])
		ifTrue: [ ^ self newFloat value: primitiveValue allButLast asNumber ].

	((primitiveValue endsWith: 'd') or: [ primitiveValue endsWith: 'D' ])
		ifTrue: [ primitiveValue := primitiveValue allButLast ].

	^ self newDouble value: primitiveValue asNumber
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaForEachStatement: statement [

	| collection variableType variableName |
	collection := statement list accept: self.
	variableType := self resolveType: statement type.
	variableName := statement fieldname name.

	^ self inScopeDo: [
		  | location |
		  self frame declare: variableName type: variableType.
		  location := self frame resolveLocation: variableName.
		  collection value do: [ :element |
			  | result |
			  location value: (self convert: element value to: variableType).
			  result := statement body accept: self.
			  (result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
				  result isReturn ifTrue: [ ^ result ].
				  result isBreak ifTrue: [ ^ nil ] ] ].
		  nil ]
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaForStatement: aFASTJavaForStatement [

	^ self inScopeDo: [
		  aFASTJavaForStatement initializer ifNotNil: [ :initializer | initializer accept: self ].
		  [ aFASTJavaForStatement condition ifNil: [ true ] ifNotNil: [ :condition | (condition accept: self) value ] ] whileTrue: [
			  | result |
			  result := aFASTJavaForStatement body accept: self.
			  (result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
				  result isReturn ifTrue: [ ^ result ].
				  result isBreak ifTrue: [ ^ nil ] ].
			  aFASTJavaForStatement incrementor ifNotNil: [ :incrementor | incrementor accept: self ] ].
		  nil ]
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaIdentifier: identifier [

	^ (self locationOfName: identifier name) value
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaIfStatement: aFASTJavaIfStatement [

	(aFASTJavaIfStatement condition accept: self) value ifTrue: [
		^ aFASTJavaIfStatement thenPart accept: self ].

	^ aFASTJavaIfStatement elsePart ifNotNil: [ :else |
		  else accept: self ]
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaInfixOperation: expression [

	expression operator = '&&' ifTrue: [ ^ self visitAnd: expression ].

	expression operator = '||' ifTrue: [ ^ self visitOr: expression ].

	(#( '==' '!=' ) includes: expression operator) ifTrue: [
		^ self visitEquality: expression ].

	(self isRelationalOperator: expression operator) ifTrue: [
		^ self visitRelationalOperation: expression ].

	^ self visitNumericOperation: expression
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaIntegerLiteral: literal [

	| primitiveValue |
	primitiveValue := literal primitiveValue.

	((primitiveValue endsWith: 'l') or: [ primitiveValue endsWith: 'L' ])
		ifTrue: [ ^ self newLong value: primitiveValue allButLast asInteger ].

	^ self newInteger value: primitiveValue asInteger
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaLongLiteral: literal [

	^ self newLong value: literal primitiveValue asInteger
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaMethodInvocation: invocation [

	| linkedInvocation receiver arguments method |
	linkedInvocation := self classLoader linkedInvocationFor: invocation.

	receiver := self
		            receiverForInvocation: invocation
		            linkedAs: linkedInvocation.

	arguments := invocation arguments collect: [ :argument |
		             argument accept: self ].

	method := self runtimeMethodFor: linkedInvocation on: receiver.

	^ self execute: method fastMethod on: receiver with: arguments
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaNewArray: newArray [

	| baseType arrayType |
	baseType := self resolveType: newArray type.

	arrayType := FamixValueJavaArrayTypeInfo new
		             componentType: baseType;
		             dimensions: newArray arguments size;
		             yourself.

	newArray initializer ifNotNil: [ :initializer | ^ self allocateArrayOf: arrayType initializedBy: initializer ].

	^ self allocateArrayOf: arrayType dimensions: newArray arguments
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaNewExpression: expression [

	^ self instantiate: expression
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaNullLiteral: aNullLiteral [

	^ self nullValue
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaReturnStatement: aFASTJavaReturnStatement [
	"Load the return value into the register. If nil, it means the method did not return anything."

	^ FamixValueInterpreterReturn value:
		  (aFASTJavaReturnStatement expression ifNotNil: [ :expression |
			   expression accept: self ])
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaStatementBlock: aFASTJavaStatementBlock [

	^ self inScopeDo: [
		  self executeStatementsOf: aFASTJavaStatementBlock ]
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaThis: aFASTJavaThis [

	^ self frame receiver
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaUnaryExpression: expression [

	| operand type result |
	(#( '++' '--' ) includes: expression operator) ifTrue: [ ^ self visitIncrementOrDecrement: expression ].

	expression operator = '!' ifTrue: [
		^ self newBoolean value: (self operate: expression operator with: (expression expression accept: self)) ].

	operand := expression expression accept: self.
	type := self unaryNumericTypeOf: operand.
	result := self operate: expression operator with: operand.

	^ self narrowPrimitiveValue: result from: type to: type
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaVarDeclStatement: statement [

	| type |
	type := self resolveType: statement type.

	statement declarators do: [ :declarator |
		self declareVariable: declarator ofType: type ]
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaVariableExpression: expression [

	expression name = self receiverName ifTrue: [ ^ self frame receiver ].

	^ (self locationOfName: expression name) value
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaWhileStatement: aFASTJavaWhileStatement [

	[ (aFASTJavaWhileStatement condition accept: self) value ] whileTrue: [
		| result |
		result := aFASTJavaWhileStatement body accept: self.
		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			result isReturn ifTrue: [ ^ result ].
			result isBreak ifTrue: [ ^ nil ] ] ].
	^ nil
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitIncrementOrDecrement: expression [

	| location oldValue promotedType result newValue |
	location := self locationOf: expression expression.
	oldValue := location value.
	promotedType := self unaryNumericTypeOf: oldValue.
	result := self operate: expression operator with: oldValue.
	result := self narrowPrimitiveValue: result from: promotedType to: promotedType.
	newValue := self narrowPrimitiveValue: result value from: promotedType to: location type.

	location value: newValue.

	^ expression isPrefixedUnaryExpression
		  ifTrue: [ newValue ]
		  ifFalse: [ oldValue ]
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitNumericOperation: expression [

	| left right type |
	left := expression leftOperand accept: self.
	right := expression rightOperand accept: self.

	(#( '<<' '>>' '>>>' ) includes: expression operator) ifTrue: [
		^ self javaShiftOperation: expression operator left: left right: right ].

	type := self binaryNumericTypeOf: left with: right.

	^ self
		  javaNumericOperation: expression operator
		  left: left
		  right: right
		  type: type
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitOr: expression [

	| left |
	left := expression leftOperand accept: self.
	left value ifTrue: [ ^ self newBoolean value: true ].

	^ self newBoolean value: (expression rightOperand accept: self) value
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitRelationalOperation: expression [

	| left right value |
	left := expression leftOperand accept: self.
	right := expression rightOperand accept: self.

	value := self operate: expression operator with: left with: right.

	^ self newBoolean value: value
]
