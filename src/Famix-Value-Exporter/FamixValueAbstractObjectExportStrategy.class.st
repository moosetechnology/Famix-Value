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
FamixValueAbstractObjectExportStrategy >> addToHelper: helperClass [
	"Hook to add strategy specifics to the helper class. By default, do nothing."
]

{ #category : 'ast' }
FamixValueAbstractObjectExportStrategy >> dependencyImportsOn: aFASTModel [

	^ {  }
]

{ #category : 'exporting' }
FamixValueAbstractObjectExportStrategy >> export: object on: visitor [

	self subclassResponsibility
]
