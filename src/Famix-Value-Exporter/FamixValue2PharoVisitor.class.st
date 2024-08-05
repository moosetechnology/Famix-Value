"
A visitor for exporting a FamixValue model to the Pharo AST, see `RBNode`.

Object attributes are initialized by finding the corresponding setters.
Collections are constructed using the `withAll:` class method.
Dictionaries are constructed using the `newFrom:` class method.
"
Class {
	#name : #FamixValue2PharoVisitor,
	#superclass : #FamixValue2ASTVisitor,
	#instVars : [
		'definedValues',
		'vars'
	],
	#category : #'Famix-Value-Exporter-Visitors'
}

{ #category : #visiting }
FamixValue2PharoVisitor >> addParenthesis: aNode [
	"add parenthesis when the node as multiple references"

	| receiver newNode |
	receiver := RBAssignmentNode new
		            variable: aNode variable;
		            value: (aNode value messages at: 1) receiver.
	newNode := aNode value.
	(newNode messages at: 1) receiver: receiver.
	^ newNode
]

{ #category : #testing }
FamixValue2PharoVisitor >> ensureVisited: value [

	value isOfPrimitiveType ifTrue: [ ^ value accept: self ].
	^ self varNameDict
		  at: value
		  ifPresent: [ :name | self makeVariableNamed: name ]
		  ifAbsent: [
			  self varNameFor: value.
			  value accept: self ]
]

{ #category : #initialization }
FamixValue2PharoVisitor >> initialize [

	super initialize.

	definedValues := IdentitySet new.
	vars := IdentityDictionary new
]

{ #category : #testing }
FamixValue2PharoVisitor >> makeAssignmentFor: aVariableName and: aValue [
	"^ RBAssignmentNode variable: (self makeVariableNamed: aVariableName) value: aValue"

	^ RBMessageNode
		  receiver: (RBVariableNode named: 'vars')
		  selector: #at:put:
		  arguments: {
				  (RBLiteralNode value: aVariableName).
				  aValue }
]

{ #category : #ast }
FamixValue2PharoVisitor >> makeHelper [

	
]

{ #category : #visiting }
FamixValue2PharoVisitor >> makeVariableExpression: value [

	^ RBVariableNode named: (self varNameFor: value)
]

{ #category : #testing }
FamixValue2PharoVisitor >> makeVariableNamed: aString [
	"^ RBVariableNode named: aString"

	^ RBMessageNode
		  receiver: (RBVariableNode named: 'vars')
		  selector: #at:
		  arguments: { (RBLiteralNode value: aString) }
]

{ #category : #accessing }
FamixValue2PharoVisitor >> statementBlock [

	^ statementBlock ifNil: [ statementBlock := RBSequenceNode new ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitClassReference: aFamixValueOfClassReference [

	^ RBVariableNode named: aFamixValueOfClassReference value name
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitClosure: closure [

	closure variables do: [ :var | self ensureVisited: var value ].

	[
	self statementBlock addNode: (self
			 makeAssignmentFor: (self varNameFor: closure)
			 and: (RBParser parseExpression: closure sourceCode)) ]
		on: SyntaxErrorNotification
		do: [ :error | "TODO: fix reflective opperation on block when metalink is installed"
			Transcript crShow: error description.
			error pass ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitCollection: collection [

	| name isArrayed |
	name := self varNameFor: collection.
	self statementBlock addNode:
		(self makeAssignmentFor: name and: (RBMessageNode
				  receiver: (RBVariableNode named: collection type name)
				  selector: #new:
				  arguments: { (RBLiteralValueNode value: collection value size) })).
	collection value ifEmpty: [ ^ self statementBlock statements last ].

	isArrayed := collection type superclassHierarchy anySatisfy: [
		             :superclass | superclass name = 'ArrayedCollection' ].
	collection value withIndexDo: [ :element :index |
		| elementNode |
		elementNode := self ensureVisited: element value.
		(element value isOfPrimitiveType or: [
			 element value isOfClassReference ]) ifFalse: [
			elementNode := self makeVariableNamed:
				               (self varNameFor: element value) ].
		self statementBlock addNode: (isArrayed
				 ifTrue: [
					 RBMessageNode
						 receiver: (self makeVariableNamed: name)
						 selector: #at:put:
						 arguments: {
								 (RBLiteralValueNode value: index).
								 elementNode } ]
				 ifFalse: [
					 RBMessageNode
						 receiver: (self makeVariableNamed: name)
						 selector: #add:
						 arguments: { elementNode } ]) ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitDictionary: dictionary [

	self statementBlock addNode: (self
			 makeAssignmentFor: (self varNameFor: dictionary)
			 and: (RBMessageNode
					  receiver: (RBVariableNode named: dictionary type name)
					  selector: #new:
					  arguments:
					  { (RBLiteralValueNode value: dictionary value size) })).
	dictionary value ifEmpty: [ ^ self statementBlock statements last ].
	dictionary value do: [ :assoc |
		self visitDictionaryAssociation: assoc ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitDictionaryAssociation: association [

	| key value keyNode valueNode |
	key := association key.
	value := association value.
	keyNode := self ensureVisited: key.
	valueNode := self ensureVisited: value.
	self statementBlock addNode: (RBMessageNode
			 receiver:
			 (self makeVariableNamed: (self varNameFor: association dictionary))
			 selector: #at:put:
			 arguments: {
					 ((key isOfPrimitiveType or: [ key isOfClassReference ])
						  ifTrue: [ keyNode ]
						  ifFalse: [ self makeVariableNamed: (self varNameFor: key) ]).
					 ((value isOfPrimitiveType or: [ value isOfClassReference ])
						  ifTrue: [ valueNode ]
						  ifFalse: [ self makeVariableNamed: (self varNameFor: value) ]) })
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitEnumValue: enumValue [

	self shouldNotImplement
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObject: object [

	self statementBlock addNode: (self
			 makeAssignmentFor: (self varNameFor: object)
			 and: (RBMessageNode
					  receiver: (RBVariableNode named: object type name)
					  selector: #basicNew)).
	object value ifEmpty: [ ^ self statementBlock statements last ].
	object value do: [ :attribute | self visitObjectAttribute: attribute ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObjectAttribute: attribute [

	| value attributeNode |
	attribute attribute ifNil: [ "ignore unknown attributes" ^ nil ].
	value := attribute value.
	attributeNode := self ensureVisited: value.
	(value isOfPrimitiveType or: [ value isOfClassReference ]) ifFalse: [ "TODO?"
		attributeNode := self makeVariableNamed: (self varNameFor: value) ].
	self statementBlock addNode:
		((attribute object type findSetterOf: attribute attribute)
			 ifNotNil: [ :setter |
				 RBMessageNode
					 receiver:
					 (self makeVariableNamed: (self varNameFor: attribute object))
					 selector: setter name
					 arguments: { attributeNode } ]
			 ifNil: [ "Use reflectivity"
				 RBMessageNode
					 receiver:
					 (self makeVariableNamed: (self varNameFor: attribute object))
					 selector: #instVarNamed:put:
					 arguments: {
							 (RBVariableNode named: '#' , attribute attribute name).
							 attributeNode } ])
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitPrimitive: primitive [

	^ RBLiteralValueNode value: primitive value
]
