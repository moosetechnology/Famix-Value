Class {
	#name : #FASTJavaBuilder,
	#superclass : #FASTBuilder,
	#instVars : [
		'imports',
		'typeNameDictionary',
		'registeredTypes'
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

	self reset
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

	| type |
	type := aFamixType isParametricEntity
		        ifTrue: [
			        aFamixType concreteParameters do: [ :parameter |
				        self processType: parameter ].
			        aFamixType genericEntity ]
		        ifFalse: [ aFamixType ].
	type needsJavaImport ifTrue: [ self registerType: type ]
]

{ #category : #processing }
FASTJavaBuilder >> referType: aFamixType [

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

{ #category : #processing }
FASTJavaBuilder >> registerType: aFamixType [
	"If the type is in the typeNameDict, it will be imported."

	registeredTypes add: aFamixType.
	typeNameDictionary at: aFamixType name ifAbsentPut: aFamixType
]

{ #category : #initialization }
FASTJavaBuilder >> reset [

	typeNameDictionary := Dictionary new.
	registeredTypes := IdentitySet new
]
