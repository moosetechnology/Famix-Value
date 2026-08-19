Class {
	#name : 'FamixValueJavaCompilationUnitInfo',
	#superclass : 'Object',
	#instVars : [
		'fastCompilationUnit',
		'packageName',
		'classes'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> addClass: classInfo [

	classes at: classInfo name put: classInfo
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
	classes := Dictionary new
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> packageName [

	^ packageName
]

{ #category : 'initialization' }
FamixValueJavaCompilationUnitInfo >> packageName: aString [

	packageName := aString
]
