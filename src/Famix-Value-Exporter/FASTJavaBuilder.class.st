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

{ #category : #temp }
FASTJavaBuilder >> fullyQualifiedPackageNameFor: aFamixJavaPackage [

	^ aFamixJavaPackage parentPackage
		  ifNil: [ self model newTypeName name: aFamixJavaPackage name ]
		  ifNotNil: [ :parentPackage |
			  self model newQualifiedTypeName
				  name: aFamixJavaPackage name;
				  namespace: (self fullyQualifiedPackageNameFor: parentPackage) ]
]

{ #category : #temp }
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

{ #category : #temp }
FASTJavaBuilder >> makeImportDeclaration: aFamixType [

	^ self model newImportDeclaration qualifiedName:
		  (model newQualifiedName name: aFamixType mooseNameWithDots)
]

{ #category : #temp }
FASTJavaBuilder >> makeImportDeclarations [

	^ typeNameDictionary values collect: [ :type |
		  self makeImportDeclaration: type ]
]

{ #category : #temp }
FASTJavaBuilder >> processType: aFamixType [

	| type |
	type := aFamixType isParameterizedType
		        ifTrue: [
			        aFamixType arguments do: [ :argument |
				        self processType: argument ].
			        aFamixType parameterizableClass ]
		        ifFalse: [ aFamixType ].
	type needsJavaImport ifTrue: [ self registerType: type ]
]

{ #category : #temp }
FASTJavaBuilder >> referType: aFamixType [

	| registeredType |
	self processType: aFamixType.
	registeredType := typeNameDictionary
		                  at: aFamixType name
		                  ifAbsent: nil.
	^ self model newClassTypeExpression typeName:
		  ((registeredType == aFamixType or: [
			    aFamixType needsJavaImport not or: [
				    aFamixType isParameterizedType and: [
					    registeredType == aFamixType parameterizableClass ] ] ])
			   ifTrue: [ "has import"
			   model newTypeName name: aFamixType baseName ]
			   ifFalse: [ "no import"
			   self fullyQualifiedTypeNameFor: aFamixType ])
]

{ #category : #temp }
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
