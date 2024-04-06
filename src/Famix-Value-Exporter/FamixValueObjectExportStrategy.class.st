Class {
	#name : #FamixValueObjectExportStrategy,
	#superclass : #Object,
	#category : #'Famix-Value-Exporter-Strategies'
}

{ #category : #testing }
FamixValueObjectExportStrategy class >> isAbstract [

	^ self == FamixValueObjectExportStrategy
]

{ #category : #ast }
FamixValueObjectExportStrategy >> addToHelper: helperClass [
	"Hook to add strategy specifics to the helper class. By default, do nothing."
]

{ #category : #ast }
FamixValueObjectExportStrategy >> dependencyImportsOn: aFASTModel [

	^ {  }
]

{ #category : #exporting }
FamixValueObjectExportStrategy >> export: object on: visitor [

	self subclassResponsibility
]
