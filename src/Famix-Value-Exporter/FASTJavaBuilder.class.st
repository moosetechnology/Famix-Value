Class {
	#name : #FASTJavaBuilder,
	#superclass : #FASTBuilder,
	#instVars : [
		'imports',
		'typeNameDictionary'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #ast }
FASTJavaBuilder >> fullyQualifiedPackageNameFor: aFamixJavaPackage [

	^ aFamixJavaPackage parentPackage
		  ifNil: [ self model newTypeName name: aFamixJavaPackage name ]
		  ifNotNil: [ :parentPackage |
			  self model newQualifiedTypeName
				  name: aFamixJavaPackage name;
				  namespace: (self fullyQualifiedPackageNameFor: parentPackage) ]
]

{ #category : #ast }
FASTJavaBuilder >> fullyQualifiedTypeNameFor: aFamixJavaType [

	^ self model newQualifiedTypeName
		  name: aFamixJavaType baseName;
		  namespace:
			  (self fullyQualifiedPackageNameFor: aFamixJavaType typeContainer)
]

{ #category : #initialization }
FASTJavaBuilder >> initialize [

	typeNameDictionary := Dictionary new
]

{ #category : #ast }
FASTJavaBuilder >> makeImportDeclaration: aFamixType [

	^ self model newImportDeclaration qualifiedName:
		  (model newQualifiedName name: aFamixType mooseNameWithDots)
]

{ #category : #ast }
FASTJavaBuilder >> makeImportDeclarations [
	"Make an import declaration for each type processed by this builder."

	^ typeNameDictionary values collect: [ :type |
		  self makeImportDeclaration: type ]
]

{ #category : #ast }
FASTJavaBuilder >> makeImportDeclarations: anEntity [
	"Make import declarations for all types related to the given entity."

	^ (anEntity allTypes select: [ :type | type needsJavaImport ])
		  collect: [ :type | self makeImportDeclaration: type ]
		  as: OrderedCollection
]

{ #category : #processing }
FASTJavaBuilder >> processType: aFamixType [
	"Process the given type and its related types, for example if it has concrete type parameters.
	This lets the builder know how to refer to the type.
	If the type is in the typeNameDict, it will be imported, so it can be referenced by its unqualified name."

	| type |
	type := aFamixType isParametricEntity
		        ifTrue: [
			        aFamixType concreteParameters do: [ :parameter |
				        self processType: parameter ].
			        aFamixType genericEntity ]
		        ifFalse: [ aFamixType ].
	type needsJavaImport ifTrue: [
		typeNameDictionary at: aFamixType name ifAbsentPut: aFamixType ]
]

{ #category : #processing }
FASTJavaBuilder >> referType: aFamixType [
	"Process a type and return a FAST expression to reference it.
	Use its unqualified name when importing the type, otherwise use its fully qualified name."

	| registeredType |
	self processType: aFamixType.
	registeredType := typeNameDictionary
		                  at: aFamixType name
		                  ifAbsent: nil.
	^ self model newClassTypeExpression typeName:
		  ((registeredType == aFamixType or: [
			    aFamixType needsJavaImport not or: [
				    aFamixType isParametricEntity and: [
					    registeredType == aFamixType genericEntity ] ] ])
			   ifTrue: [ "has import"
			   model newTypeName name: aFamixType baseName ]
			   ifFalse: [ "no import"
			   self fullyQualifiedTypeNameFor: aFamixType ])
]
