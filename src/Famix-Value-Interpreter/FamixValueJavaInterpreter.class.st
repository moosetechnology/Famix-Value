Class {
	#name : 'FamixValueJavaInterpreter',
	#superclass : 'FamixValueInterpreter',
	#instVars : [
		'nullValue',
		'classLoader'
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
	object := self model newOfObject
		          runtimeType: classInfo;
		          yourself.

	classInfo famixType ifNotNil: [ :famixType | object type: famixType ].

	classInfo fieldsDo: [ :fieldInfo |
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
FamixValueJavaInterpreter >> bindArguments: arguments toParametersOf: method in: frame [

	| methodInfo |
	methodInfo := self classLoader methodInfoForFASTMethod: method.

	1 to: method parameters size do: [ :index |
		| parameter argument parameterType |
		parameter := method parameters at: index.
		argument := arguments at: index.
		parameterType := methodInfo parameterTypes at: index.

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

	self flag: #TODO. "JLS 5.1.5 - widening reference conversion."
	^ false
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

	self flag: #TODO. "Check Java assignment compatibility / inheritance."

	^ value
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> currentCompilationUnit [

	^ self currentMethodInfo compilationUnit
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> currentMethodInfo [

	^ self classLoader methodInfoForFASTMethod: self frame method
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
FamixValueJavaInterpreter >> executeMain: main [

	^ self
		  execute: main
		  with:
			  { (self model newOfCollection type:
				   (FamixValueJavaArrayTypeInfo new
					    componentType: main parameters first declaredType;
					    dimensions: 1)) }
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> initialize: object from: newExpression [
	"TODO: execute instance initializers and constructor."

	^ object
]

{ #category : 'instance creation' }
FamixValueJavaInterpreter >> instantiate: newExpression [

	| classInfo object |
	classInfo := self classLoader
		             resolveType: newExpression type
		             in: self currentCompilationUnit.
	object := self allocateObjectOf: classInfo.

	self initialize: object from: newExpression.

	^ object
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
		ifTrue: [ ^ self isType: firstType subtypeOf: secondType ].

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

{ #category : 'testing' }
FamixValueJavaInterpreter >> isType: sourceType subtypeOf: targetType [

	(sourceType isSameTypeAs: targetType) ifTrue: [ ^ true ].

	(sourceType isPrimitiveType or: [ targetType isPrimitiveType ])
		ifTrue: [ ^ false ].

	self flag: #TODO. "JLS 4.10 - reference subtyping."
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
FamixValueJavaInterpreter >> locationOfFieldAccess: expression [

	^ self
		  locationOfFieldNamed: expression fieldName
		  on: (expression receiver accept: self)
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfFieldNamed: name on: receiver [

	| fieldInfo objectAttribute |
	fieldInfo := receiver runtimeType fieldNamed: name.

	objectAttribute := receiver value
		                   detect: [ :each | each runtimeField == fieldInfo ]
		                   ifNone: [
		                   FamixValueInterpreterResolveError
			                   signalFor: name
			                   in: receiver ].

	^ FamixValueInterpreterFieldLocation new
		  objectAttribute: objectAttribute;
		  type: fieldInfo type;
		  yourself
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfName: name [

	(self frame hasLocal: name) ifTrue: [
		^ self frame resolveLocation: name ].

	self frame receiver ifNotNil: [ :receiver |
		^ self locationOfFieldNamed: name on: receiver ].

	FamixValueInterpreterResolveError signalFor: name in: self frame
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> locationOfProperty: property [

	| receiver |
	receiver := property type accept: self.

	^ self locationOfFieldNamed: property fieldName on: receiver
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

{ #category : 'hooks' }
FamixValueJavaInterpreter >> receiverName [

	^ 'this'
]

{ #category : 'resolving' }
FamixValueJavaInterpreter >> resolveType: fastType [

	^ self classLoader
		  resolveType: fastType
		  in: self frameCompilationUnit
]

{ #category : 'invoking' }
FamixValueJavaInterpreter >> returnValue: value from: method [

	| methodInfo |
	methodInfo := self classLoader methodInfoForFASTMethod: method.

	methodInfo returnType ifNil: [ ^ nil ].

	^ self convert: value to: methodInfo returnType
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

	| receiver arguments method |
	receiver := invocation receiver accept: self.

	arguments := invocation arguments collect: [ :argument |
		             argument accept: self ].

	method := self classLoader methodForInvocation: invocation.

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
