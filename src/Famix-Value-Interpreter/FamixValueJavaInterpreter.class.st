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

	self error: 'Compound assignment conversion not implemented yet'
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
FamixValueJavaInterpreter >> convertNullTo: targetType [

	targetType isPrimitiveType ifTrue: [
		self error:
			'Cannot convert null to primitive type ' , targetType name ].

	^ self nullValue
]

{ #category : 'converting' }
FamixValueJavaInterpreter >> convertPrimitive: value to: targetType [

	(self canWidenPrimitive: value runtimeType to: targetType) ifFalse: [
		self error:
			'Invalid primitive conversion from ' , value runtimeType name
			, ' to ' , targetType name ].

	^ self newPrimitiveOfType: targetType value: value value
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

	| location |
	self frame declare: declarator variable name type: type.

	location := self frame resolveLocation: declarator variable name.

	declarator expression ifNotNil: [ :initializer |
		location value: (self convert: (initializer accept: self) to: type) ]
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
		          do: [ executable fastMethod statementBlock accept: self ].

	(result isKindOf: FamixValueInterpreterReturn) ifTrue: [
		^ self returnValue: result value from: executable ].

	^ result
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
FamixValueJavaInterpreter >> initializeFieldsDeclaredBy: classInfo on: object [

	classInfo fieldsDo: [ :fieldInfo |
		(fieldInfo isStatic not and: [ fieldInfo initializer isNotNil ])
			ifTrue: [
				| frame location value |
				frame := FamixValueInterpreterFrame new
					         executable: fieldInfo;
					         receiver: object.

				value := self
					         inFrame: frame
					         do: [ fieldInfo initializer accept: self ].

				location := self locationOfField: fieldInfo on: object.
				location value: (self convert: value to: fieldInfo type) ] ]
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

	typeInfo fieldsDo: [ :fieldInfo |
		(fieldInfo isStatic and: [ fieldInfo initializer isNotNil ])
			ifTrue: [ self initializeStaticField: fieldInfo in: runtimeType ] ]
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
FamixValueJavaInterpreter >> operate: operator with: value [

	^ UnaryOperators
		  at: operator
		  ifPresent: [ :operation | operation value: value value ]
		  ifAbsent: [
		  FamixValueInterpreterUnknownOperator signalFor: operator ]
]

{ #category : 'operations' }
FamixValueJavaInterpreter >> operate: operator with: left with: right [

	^ BinaryOperators
		  at: operator
		  ifPresent: [ :operation |
		  operation value: left value value: right value ]
		  ifAbsent: [
		  FamixValueInterpreterUnknownOperator signalFor: operator ]
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
		            ifTrue: [ self convert: rhs to: location type ]
		            ifFalse: [
			            self
				            compoundAssignment: assignment operator
				            location: location
				            right: rhs ].

	location value: newValue.
	^ newValue
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaBooleanLiteral: literal [

	^ self newBoolean value: literal primitiveValue = 'true'
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
FamixValueJavaInterpreter >> visitFASTJavaForStatement: aFASTJavaForStatement [

	^ self inScopeDo: [
		  aFASTJavaForStatement initializer accept: self.
		  [ (aFASTJavaForStatement condition accept: self) value ]
			  whileTrue: [
				  | result |
				  result := aFASTJavaForStatement body accept: self.
				  (result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
					  ^ result ].
				  aFASTJavaForStatement incrementor accept: self ].
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

	aFASTJavaStatementBlock statements do: [ :statement |
		| result |
		result := statement accept: self.
		(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
			^ result ] ].
	^ nil
]

{ #category : 'visiting' }
FamixValueJavaInterpreter >> visitFASTJavaUnaryExpression: expression [

	| operand |
	(#( '++' '--' ) includes: expression operator) ifTrue: [
		^ self visitIncrementOrDecrement: expression ].

	expression operator = '!' ifTrue: [
		^ self newBoolean value: (self
				   operate: expression operator
				   with: (expression expression accept: self)) ].

	operand := expression expression accept: self.

	^ self
		  newPrimitiveOfType: (self unaryNumericTypeOf: operand)
		  value: (self operate: expression operator with: operand)
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

	[ (aFASTJavaWhileStatement condition accept: self) value ]
		whileTrue: [
			| result |
			result := aFASTJavaWhileStatement body accept: self.
			(result isKindOf: FamixValueInterpreterControlFlow) ifTrue: [
				^ result ] ].
	^ nil
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitIncrementOrDecrement: expression [

	| location oldValue newValue |
	location := self locationOf: expression expression.
	oldValue := location value.

	newValue := self
		            newPrimitiveOfType: oldValue runtimeType
		            value:
		            (self operate: expression operator with: oldValue).

	location value: newValue.

	^ expression isPrefixedUnaryExpression
		  ifTrue: [ newValue ]
		  ifFalse: [ oldValue ]
]

{ #category : 'visiting - helpers' }
FamixValueJavaInterpreter >> visitNumericOperation: expression [

	| left right type value |
	left := expression leftOperand accept: self.
	right := expression rightOperand accept: self.

	type := self binaryNumericTypeOf: left with: right.

	value := self operate: expression operator with: left with: right.

	^ self newPrimitiveOfType: type value: value
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
