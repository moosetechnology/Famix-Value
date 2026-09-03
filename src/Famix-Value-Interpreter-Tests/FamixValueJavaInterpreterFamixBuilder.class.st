Class {
	#name : 'FamixValueJavaInterpreterFamixBuilder',
	#superclass : 'FASTJavaVisitor',
	#instVars : [
		'model',
		'entityFinder',
		'currentType'
	],
	#category : 'Famix-Value-Interpreter-Tests',
	#package : 'Famix-Value-Interpreter-Tests'
}

{ #category : 'building' }
FamixValueJavaInterpreterFamixBuilder class >> buildFrom: aFASTEntity [

	| builder |
	builder := self new.
	aFASTEntity accept: builder.
	^ builder model
]

{ #category : 'building' }
FamixValueJavaInterpreterFamixBuilder class >> expand: aFamixJavaModel from: aFASTEntity [

	| builder |
	builder := self new model: aFamixJavaModel.
	aFASTEntity accept: builder.
	^ aFamixJavaModel
]

{ #category : 'accessing' }
FamixValueJavaInterpreterFamixBuilder >> model [

	^ model ifNil: [ self model: FamixJavaModel new ]
]

{ #category : 'accessing' }
FamixValueJavaInterpreterFamixBuilder >> model: aFamixJavaModel [

	model := aFamixJavaModel.
	entityFinder := FamixJavaEntityFinder on: model.
	entityFinder createWhenNotFound
]

{ #category : 'helpers' }
FamixValueJavaInterpreterFamixBuilder >> resolveType: aFASTTypeExpression [

	aFASTTypeExpression isPrimitiveTypeExpression ifTrue: [
		^ entityFinder
			  expecting: FamixJavaPrimitiveType
			  do: [ entityFinder findTypeNamed: aFASTTypeExpression name ] ].

	aFASTTypeExpression isClassTypeExpression ifTrue: [
		^ entityFinder
			  expecting: FamixJavaClass
			  do: [
			  entityFinder findTypeNamed: aFASTTypeExpression typeName name ] ].

	self error:
		'Unsupported FAST Java type: ' , aFASTTypeExpression class name
]

{ #category : 'visiting' }
FamixValueJavaInterpreterFamixBuilder >> visitFASTJavaClassDeclaration: aClass [

	| previousType |
	previousType := currentType.

	currentType := entityFinder
		               expecting: FamixJavaClass
		               do: [ entityFinder findTypeNamed: aClass name ].

	aClass declarations do: [ :declaration | declaration accept: self ].

	currentType := previousType
]

{ #category : 'visiting' }
FamixValueJavaInterpreterFamixBuilder >> visitFASTJavaClassTypeExpression: typeExpression [

	^ self resolveType: typeExpression
]

{ #category : 'visiting' }
FamixValueJavaInterpreterFamixBuilder >> visitFASTJavaInterfaceDeclaration: anInterface [

	| previousType |
	previousType := currentType.

	currentType := entityFinder
		               expecting: FamixJavaInterface
		               do: [ entityFinder findTypeNamed: anInterface name ].

	anInterface declarations do: [ :declaration |
		declaration accept: self ].

	currentType := previousType
]

{ #category : 'visiting' }
FamixValueJavaInterpreterFamixBuilder >> visitFASTJavaMethodEntity: fastMethod [

	| famixMethod |
	famixMethod := model newMethodNamed: fastMethod name.
	currentType addMethod: famixMethod.

	famixMethod fast: fastMethod
]

{ #category : 'visiting' }
FamixValueJavaInterpreterFamixBuilder >> visitFASTJavaVarDeclStatement: declaration [

	declaration declarators do: [ :declarator |
		| attribute |
		attribute := model newAttributeNamed: declarator variable name.

		attribute declaredType: (self resolveType: declaration type).

		currentType addAttribute: attribute ]
]
