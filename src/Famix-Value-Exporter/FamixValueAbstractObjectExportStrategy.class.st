Class {
	#name : #FamixValueAbstractObjectExportStrategy,
	#superclass : #Object,
	#category : #'Famix-Value-Exporter-Strategies'
}

{ #category : #testing }
FamixValueAbstractObjectExportStrategy class >> isAbstract [

	^ self == FamixValueAbstractObjectExportStrategy
]

{ #category : #ast }
FamixValueAbstractObjectExportStrategy >> addToHelper: helperClass [
	"Hook to add strategy specifics to the helper class. By default, do nothing."
]

{ #category : #ast }
FamixValueAbstractObjectExportStrategy >> dependencyImportsOn: aFASTModel [

	^ {  }
]

{ #category : #exporting }
FamixValueAbstractObjectExportStrategy >> export: object on: visitor [

	self subclassResponsibility
]
