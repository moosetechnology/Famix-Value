Class {
	#name : 'FamixValueJavaCompilationUnitInfo',
	#superclass : 'Object',
	#instVars : [
		'fastCompilationUnit',
		'packageName',
		'singleTypeImports',
		'onDemandImports',
		'declaredTypes'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'adding' }
FamixValueJavaCompilationUnitInfo >> addOnDemandImport: qualifiedName [

	onDemandImports add: qualifiedName
]

{ #category : 'adding' }
FamixValueJavaCompilationUnitInfo >> addSingleTypeImport: qualifiedName [

	| simpleName dotIndex |
	dotIndex := qualifiedName lastIndexOf: $..
	simpleName := dotIndex = 0
		              ifTrue: [ qualifiedName ]
		              ifFalse: [
		              qualifiedName
			              copyFrom: dotIndex + 1
			              to: qualifiedName size ].

	singleTypeImports
		at: simpleName
		ifPresent: [ :existing |
			existing = qualifiedName ifFalse: [
				self error: 'Conflicting imports for ' , simpleName ] ]
		ifAbsentPut: [ qualifiedName ]
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> addType: classInfo [

	declaredTypes at: classInfo name put: classInfo
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> fastCompilationUnit [

	^ fastCompilationUnit
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> fastCompilationUnit: aCompilationUnit [

	fastCompilationUnit := aCompilationUnit
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> initialize [

	super initialize.
	declaredTypes := Dictionary new.
	singleTypeImports := Dictionary new.
	onDemandImports := OrderedCollection new
]

{ #category : 'adding' }
FamixValueJavaCompilationUnitInfo >> onDemandImportsDo: aBlock [

	onDemandImports do: aBlock
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> packageName [

	^ packageName
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> packageName: aString [

	packageName := aString
]

{ #category : 'adding' }
FamixValueJavaCompilationUnitInfo >> singleTypeImportNamed: name ifPresent: aBlock [

	^ singleTypeImports at: name ifPresent: aBlock
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> typeNamed: simpleName [

	^ declaredTypes at: simpleName ifAbsent: [ nil ]
]
