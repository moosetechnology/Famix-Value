Class {
	#name : 'FamixValueJavaClassInfo',
	#superclass : 'FamixValueJavaTypeInfo',
	#instVars : [
		'methodsByName',
		'fieldsByName',
		'famixType',
		'fastClass',
		'loaded',
		'declaringCompilationUnit'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'initialization' }
FamixValueJavaClassInfo >> addField: fieldInfo [

	fieldsByName at: fieldInfo name put: fieldInfo
]

{ #category : 'adding' }
FamixValueJavaClassInfo >> addMethod: aMethodInfo [

	methodsByName
		at: aMethodInfo name
		ifPresent: [ :methods | methods add: aMethodInfo ]
		ifAbsentPut: [ OrderedCollection with: aMethodInfo ]
]

{ #category : 'converting' }
FamixValueJavaClassInfo >> asDefaultValueOn: interpreter [

	^ interpreter nullValue
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> declaringCompilationUnit [

	^ declaringCompilationUnit
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> declaringCompilationUnit: aCompilationUnitInfo [

	declaringCompilationUnit := aCompilationUnitInfo
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> defineFrom: aFASTJavaClassDeclaration [

	fastClass := aFASTJavaClassDeclaration.
	loaded := true
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> famixType [

	^ famixType
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> famixType: aFamixType [

	famixType := aFamixType
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> fastClass [

	^ fastClass
]

{ #category : 'initialization' }
FamixValueJavaClassInfo >> fieldNamed: fieldName [

	^ fieldsByName
		  at: fieldName
		  ifAbsent: [
		  FamixValueInterpreterResolveError signalFor: fieldName in: self ]
]

{ #category : 'initialization' }
FamixValueJavaClassInfo >> fieldNamed: fieldName ifAbsent: aBlock [

	^ fieldsByName at: fieldName ifAbsent: aBlock
]

{ #category : 'enumerating' }
FamixValueJavaClassInfo >> fieldsDo: aBlock [

	fieldsByName valuesDo: aBlock
]

{ #category : 'initialization' }
FamixValueJavaClassInfo >> initialize [

	super initialize.
	methodsByName := Dictionary new.
	fieldsByName := Dictionary new.
	loaded := false
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> loaded [

	^ loaded
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> methodNamed: aName applicableToTypes: argumentTypes with: interpreter [

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
FamixValueJavaClassInfo >> methods [

	^ methodsByName values flattened
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> methodsNamed: aName [

	^ methodsByName at: aName ifAbsent: [ #(  ) ]
]

{ #category : 'resolving' }
FamixValueJavaClassInfo >> mostSpecificAmong: methods for: arguments with: interpreter [

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

{ #category : 'resolving' }
FamixValueJavaClassInfo >> potentiallyApplicableMethodsNamed: aName argumentCount: argumentCount [

	^ (self methodsNamed: aName) select: [ :method |
		  method isPotentiallyApplicableToArity: argumentCount ]
]

{ #category : 'accessing' }
FamixValueJavaClassInfo >> qualifiedName [

	| packageName |
	packageName := declaringCompilationUnit packageName.

	packageName isEmptyOrNil ifTrue: [ ^ name ].

	^ packageName , '.' , name
]
