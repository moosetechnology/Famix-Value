"
My subclasses are used to generate the AST for the source code to instantiate a kind of `FamixValueOfType`.
"
Class {
	#name : #FamixValue2ASTVisitor,
	#superclass : #Object,
	#instVars : [
		'model',
		'varNameDict',
		'id',
		'statementBlock'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #testing }
FamixValue2ASTVisitor class >> isAbstract [

	^ self == FamixValue2ASTVisitor
]

{ #category : #testing }
FamixValue2ASTVisitor >> ensureVisited: value [
	"Visit a value if I have not done it before"

	(self varNameDict includesKey: value) ifFalse: [ value accept: self ]
]

{ #category : #accessing }
FamixValue2ASTVisitor >> model [

	^ model
]

{ #category : #accessing }
FamixValue2ASTVisitor >> model: aModel [

	model := aModel
]

{ #category : #accessing }
FamixValue2ASTVisitor >> nextId [

	^ (id := (id ifNil: 0) + 1) - 1
]

{ #category : #accessing }
FamixValue2ASTVisitor >> statementBlock [

	^ statementBlock
]

{ #category : #accessing }
FamixValue2ASTVisitor >> statementBlock: aStatementSequence [

	statementBlock := aStatementSequence
]

{ #category : #accessing }
FamixValue2ASTVisitor >> varNameDict [

	^ varNameDict ifNil: [ varNameDict := Dictionary new ]
]

{ #category : #naming }
FamixValue2ASTVisitor >> varNameFor: value [
	"IMPORTANT: a named value is considered already exported."

	^ self varNameDict
		  at: value
		  ifAbsentPut: [ value varName , self nextId asString ]
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitCollection: collection [

	self subclassResponsibility
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitDictionary: dictionary [

	self subclassResponsibility
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitEnumValue: enumValue [

	self subclassResponsibility
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitObject: object [

	self subclassResponsibility
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitPrimitive: primitive [

	self subclassResponsibility
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visitValueOfUnknownType: value [

	self subclassResponsibility
]
