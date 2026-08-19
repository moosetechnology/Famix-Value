Class {
	#name : 'FamixValueJavaMethodInfo',
	#superclass : 'Object',
	#instVars : [
		'fastMethod',
		'parameterTypes',
		'variableArity',
		'localTypes',
		'declaringClass',
		'returnType'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaMethodInfo class >> on: aFASTJavaMethodEntity [

	^ self new fastMethod: aFASTJavaMethodEntity
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> compilationUnit [

	^ declaringClass declaringCompilationUnit
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> declaringClass [

	^ declaringClass
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> declaringClass: classInfo [

	declaringClass := classInfo
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> fastMethod [

	^ fastMethod
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> fastMethod: aFASTJavaMethodEntity [

	fastMethod := aFASTJavaMethodEntity
]

{ #category : 'initialization' }
FamixValueJavaMethodInfo >> initialize [

	super initialize.
	localTypes := Dictionary new
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isApplicableByLooseInvocationToTypes: argumentTypes with: interpreter [

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
FamixValueJavaMethodInfo >> isApplicableByStrictInvocationToTypes: argumentTypes with: interpreter [

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
FamixValueJavaMethodInfo >> isApplicableByVariableArityInvocationToTypes: argumentTypes with: interpreter [

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
FamixValueJavaMethodInfo >> isMoreSpecificThan: anotherMethod for: argumentTypes with: interpreter [

	self parameterCount = anotherMethod parameterCount ifFalse: [
		^ false ].

	1 to: parameterTypes size do: [ :index |
		(interpreter
			 isType: (parameterTypes at: index)
			 moreSpecificThan: (anotherMethod parameterTypes at: index)
			 for: (argumentTypes at: index)) ifFalse: [ ^ false ] ].

	^ true
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> isPotentiallyApplicableToArity: argumentCount [

	variableArity ifFalse: [ ^ self parameterCount = argumentCount ].

	^ argumentCount >= self parameterCount - 1
]

{ #category : 'testing' }
FamixValueJavaMethodInfo >> isStrictlyMoreSpecificThan: anotherMethod for: argumentTypes with: interpreter [

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
FamixValueJavaMethodInfo >> isVoid [

	^ returnType isNil
]

{ #category : 'initialization' }
FamixValueJavaMethodInfo >> localTypes [

	^ localTypes
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> name [

	^ fastMethod name
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> parameterCount [

	^ parameterTypes size
]

{ #category : 'typing' }
FamixValueJavaMethodInfo >> parameterTypes [

	^ parameterTypes
]

{ #category : 'typing' }
FamixValueJavaMethodInfo >> parameterTypes: aCollection [

	parameterTypes := aCollection
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> parameters [

	^ fastMethod parameters
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> returnType [

	^ returnType
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> returnType: aType [

	returnType := aType
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> variableArity [

	^ variableArity
]

{ #category : 'accessing' }
FamixValueJavaMethodInfo >> variableArity: aBoolean [

	variableArity := aBoolean
]
