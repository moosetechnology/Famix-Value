Class {
	#name : 'FamixValueJavaExecutableInfo',
	#superclass : 'FamixValueJavaMemberInfo',
	#instVars : [
		'fastMethod',
		'parameterTypes',
		'variableArity',
		'returnType',
		'localTypes'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> fastMethod [

	^ fastMethod
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> fastMethod: aFASTJavaMethodEntity [

	fastMethod := aFASTJavaMethodEntity
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> hasSameSignatureAs: anotherExecutable [

	self name = anotherExecutable name ifFalse: [ ^ false ].
	parameterTypes size = anotherExecutable parameterTypes size ifFalse: [
		^ false ].

	parameterTypes
		with: anotherExecutable parameterTypes
		do: [ :first :second |
		(first isSameTypeAs: second) ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'initialization' }
FamixValueJavaExecutableInfo >> initialize [

	super initialize.
	variableArity := false.
	localTypes := Dictionary new
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isApplicableByLooseInvocationToTypes: argumentTypes with: interpreter [

	self parameterCount = argumentTypes size ifFalse: [ ^ false ].

	argumentTypes
		with: parameterTypes
		do: [ :argumentType :parameterType |
			(interpreter
				 isType: argumentType
				 compatibleByLooseInvocationWith: parameterType) ifFalse: [
				^ false ] ].

	^ true
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isApplicableByStrictInvocationToTypes: argumentTypes with: interpreter [

	self parameterCount = argumentTypes size ifFalse: [ ^ false ].

	argumentTypes
		with: parameterTypes
		do: [ :argumentType :parameterType |
			(interpreter
				 isType: argumentType
				 compatibleByStrictInvocationWith: parameterType) ifFalse: [
				^ false ] ].

	^ true
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isApplicableByVariableArityInvocationToTypes: argumentTypes with: interpreter [

	| fixedCount varargType |
	variableArity ifFalse: [ ^ false ].

	fixedCount := self parameterCount - 1.
	argumentTypes size < fixedCount ifTrue: [ ^ false ].

	1 to: fixedCount do: [ :index |
		(interpreter
			 isType: (argumentTypes at: index)
			 compatibleByLooseInvocationWith: (parameterTypes at: index))
			ifFalse: [ ^ false ] ].

	varargType := parameterTypes last elementType.

	fixedCount + 1 to: argumentTypes size do: [ :index |
		(interpreter
			 isType: (argumentTypes at: index)
			 compatibleByLooseInvocationWith: varargType) ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isExecutable [

	^ true
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isMoreSpecificThan: anotherMethod for: argumentTypes with: interpreter [

	self parameterCount = anotherMethod parameterCount ifFalse: [
		^ false ].

	1 to: parameterTypes size do: [ :index |
		(interpreter
			 isType: (parameterTypes at: index)
			 moreSpecificThan: (anotherMethod parameterTypes at: index)
			 for: (argumentTypes at: index)) ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isPotentiallyApplicableToArity: argumentCount [

	variableArity ifFalse: [ ^ self parameterCount = argumentCount ].

	^ argumentCount >= self parameterCount - 1
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isStrictlyMoreSpecificThan: anotherMethod for: argumentTypes with: interpreter [

	^ (self
		   isMoreSpecificThan: anotherMethod
		   for: argumentTypes
		   with: interpreter) and: [
		  (anotherMethod
			   isMoreSpecificThan: self
			   for: argumentTypes
			   with: interpreter) not ]
]

{ #category : 'testing' }
FamixValueJavaExecutableInfo >> isVoid [

	^ returnType isNil
]

{ #category : 'resolving' }
FamixValueJavaExecutableInfo >> localTypeNamed: name ifPresent: aBlock [

	^ localTypes at: name ifPresent: aBlock
]

{ #category : 'initialization' }
FamixValueJavaExecutableInfo >> localTypes [

	^ localTypes
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> name [

	^ fastMethod name
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> parameterCount [

	^ parameterTypes size
]

{ #category : 'typing' }
FamixValueJavaExecutableInfo >> parameterTypes [

	^ parameterTypes
]

{ #category : 'typing' }
FamixValueJavaExecutableInfo >> parameterTypes: aCollection [

	parameterTypes := aCollection
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> parameters [

	^ fastMethod parameters
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> returnType [

	^ returnType
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> returnType: aType [

	returnType := aType
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> variableArity [

	^ variableArity
]

{ #category : 'accessing' }
FamixValueJavaExecutableInfo >> variableArity: aBoolean [

	variableArity := aBoolean
]
