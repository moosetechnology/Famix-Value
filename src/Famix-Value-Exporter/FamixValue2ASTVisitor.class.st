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
		'statements'
	],
	#category : #'Famix-Value-Exporter'
}

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
FamixValue2ASTVisitor >> statements [

	^ statements
]

{ #category : #accessing }
FamixValue2ASTVisitor >> statements: aStatementSequence [

	statements := aStatementSequence
]

{ #category : #accessing }
FamixValue2ASTVisitor >> varNameDict [

	^ varNameDict ifNil: [ varNameDict := Dictionary new ]
]

{ #category : #naming }
FamixValue2ASTVisitor >> varNameFor: value [

	^ self varNameDict at: value ifAbsentPut: [ 
		  (value typedEntity ifNotNil: [ value typedEntity name ] ifNil: [ 
			   value attributeInObjects size = 1
				   ifTrue: [ value attributeInObjects first attribute name ]
				   ifFalse: [ value type baseName uncapitalized ] ])
		  , self nextId asString ]
]

{ #category : #visiting }
FamixValue2ASTVisitor >> visit: value [

	^ value accept: self
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
