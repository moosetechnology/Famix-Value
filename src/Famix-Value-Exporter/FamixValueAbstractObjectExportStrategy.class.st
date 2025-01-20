"
I am a strategy for exporting objects used by the `FamixValue2ASTVisitor` hierarchy of classes.
Objects can be complex to recreate due to deep nesting and circular dependencies, resulting in a lot of code. My subclasses define where that code goes.
"
Class {
	#name : 'FamixValueAbstractObjectExportStrategy',
	#superclass : 'Object',
	#category : 'Famix-Value-Exporter-Strategies',
	#package : 'Famix-Value-Exporter',
	#tag : 'Strategies'
}

{ #category : 'testing' }
FamixValueAbstractObjectExportStrategy class >> isAbstract [

	^ self == FamixValueAbstractObjectExportStrategy
]

{ #category : 'ast' }
FamixValueAbstractObjectExportStrategy >> dependencyImportsOn: aFASTModel [

	^ {  }
]

{ #category : 'exporting' }
FamixValueAbstractObjectExportStrategy >> export: object on: visitor [

	self subclassResponsibility
]

{ #category : 'ast' }
FamixValueAbstractObjectExportStrategy >> makeHelpersOn: visitor [
	"Hook to create helper classes.
	By default, create the default helper and add nothing to it.
	If reflection is required, it will contain the corresponding helper methods."

	"TODO only make if strictly necessary"

	visitor makeDefaultHelper
]
