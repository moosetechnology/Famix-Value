"
A visitor for exporting a FamixValue model to the Pharo AST, see `RBNode`.

Object attributes are initialized by finding the corresponding setters.
Collections are constructed using the `withAll:` class method.
Dictionaries are constructed using the `newFrom:` class method.
"
Class {
	#name : 'FamixValue2PharoVisitor',
	#superclass : 'FamixValue2ASTVisitor',
	#instVars : [
		'definedValues',
		'vars'
	],
	#category : 'Famix-Value-Exporter-Visitors',
	#package : 'Famix-Value-Exporter',
	#tag : 'Visitors'
}

{ #category : 'visiting' }
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

{ #category : 'testing' }
FamixValue2PharoVisitor >> ensureVisited: value [

	value isOfPrimitiveType ifTrue: [ ^ value accept: self ].
	^ self varNameDict
		  at: value
		  ifPresent: [ :name | self makeVariableNamed: name ]
		  ifAbsent: [
			  | name node |
			  name := self varNameFor: value.
			  node := value accept: self.
			  "if the value is not inlined (prim or type ref), it was created during the visit so just reference its variable"
			  (value isOfPrimitiveType or: [ value isOfTypeReference ])
				  ifTrue: [ node ]
				  ifFalse: [ self makeVariableNamed: name ] ]
]

{ #category : 'initialization' }
FamixValue2PharoVisitor >> initialize [

	super initialize.

	definedValues := IdentitySet new.
	vars := IdentityDictionary new
]

{ #category : 'testing' }
FamixValue2PharoVisitor >> makeAssignment: aValue to: aVariableName [
	"The number of temporary variables is limited by the stack size limit.
	We use a dictionary to hold all variables to avoid compilation errors.

	^ RBAssignmentNode variable: (self makeVariableNamed: aVariableName) value: aValue"

	^ RBMessageNode
		  receiver: (RBVariableNode named: 'vars')
		  selector: #at:put:
		  arguments: {
				  (RBLiteralNode value: aVariableName).
				  aValue }
]

{ #category : 'ast' }
FamixValue2PharoVisitor >> makeHelper [

	
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> makeVariableExpression: value [

	^ RBVariableNode named: (self varNameFor: value)
]

{ #category : 'testing' }
FamixValue2PharoVisitor >> makeVariableNamed: aString [
	"^ RBVariableNode named: aString"

	^ RBMessageNode
		  receiver: (RBVariableNode named: 'vars')
		  selector: #at:
		  arguments: { (RBLiteralNode value: aString) }
]

{ #category : 'accessing' }
FamixValue2PharoVisitor >> statementBlock [

	^ statementBlock ifNil: [ statementBlock := RBSequenceNode new ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitClosure: closure [

	self flag: #TODO.
	closure variables do: [ :var | self ensureVisited: var value ].

	[ "TODO how to reference variables now that everything is in a dictionary?
	-> probably need to rewrite source..."
	self statementBlock addNode: (self
			 makeAssignment: (RBParser parseExpression: closure sourceCode)
			 to: (self varNameFor: closure)) ]
		on: SyntaxErrorNotification
		do: [ :error | "TODO: fix reflective opperation on block when metalink is installed"
			Transcript crShow: error description.
			error pass ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitCollection: collection [

	| name isArrayed |
	name := self varNameFor: collection.
	self statementBlock addNode: (self
			 makeAssignment: (RBMessageNode
					  receiver: (RBVariableNode named: collection type name)
					  selector: #new:
					  arguments:
					  { (RBLiteralValueNode value: collection value size) })
			 to: name).
	collection value ifEmpty: [ ^ self statementBlock statements last ].

	isArrayed := collection type superclassHierarchy anySatisfy: [
		             :superclass | superclass name = 'ArrayedCollection' ].
	collection value withIndexDo: [ :element :index |
		| elementNode |
		elementNode := self ensureVisited: element value.
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

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitDictionary: dictionary [

	self statementBlock addNode: (self
			 makeAssignment: (RBMessageNode
					  receiver: (RBVariableNode named: dictionary type name)
					  selector: #new:
					  arguments:
					  { (RBLiteralValueNode value: dictionary value size) })
			 to: (self varNameFor: dictionary)).
	dictionary value ifEmpty: [ ^ self statementBlock statements last ].
	dictionary value do: [ :assoc |
		self visitDictionaryAssociation: assoc ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitDictionaryAssociation: association [

	| key value keyNode valueNode |
	key := association key.
	value := association value.
	keyNode := self ensureVisited: key.
	valueNode := self ensureVisited: value.
	self statementBlock addNode: (association dictionary
			 ifNotNil: [ :dictionary | "part of a dictionary"
				 RBMessageNode
					 receiver:
					 (self makeVariableNamed: (self varNameFor: dictionary))
					 selector: #at:put:
					 arguments: {
							 keyNode.
							 valueNode } ]
			 ifNil: [ "standalone association"
				 self
					 makeAssignment: (RBMessageNode
							  receiver: keyNode
							  selector: #'->'
							  arguments: { valueNode })
					 to: (self varNameFor: association) ])
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitEnumValue: enumValue [

	self shouldNotImplement
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitIndexableObjectElements: attribute [
	"The owner is an indexable object with instance variables, and this attribute holds its elements.
	See comment of FamixValuePharoJacksonImporter>>#importObjectAttribute:of:named:"

	| objectName |
	objectName := self varNameFor: attribute object.
	attribute value value withIndexDo: [ :value :index |
		self statementBlock addStatement: (RBMessageNode
				 receiver: (self makeVariableNamed: objectName)
				 selector: #basicAt:put:
				 arguments: {
						 (RBLiteralValueNode value: index).
						 (self ensureVisited: value) }) ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitObject: object [

	self statementBlock addNode: (self
			 makeAssignment: (RBMessageNode
					  receiver: (RBVariableNode named: object type name)
					  selector: #basicNew)
			 to: (self varNameFor: object)).
	object value ifEmpty: [ ^ self statementBlock statements last ].
	object value do: [ :attribute | self visitObjectAttribute: attribute ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitObjectAttribute: attribute [

	| famixAttribute value attributeNode |
	(famixAttribute := attribute attribute) ifNil: [ ^ nil ]. "ignore unknown Famix attributes"
	famixAttribute name = '@' ifTrue: [
		^ self visitIndexableObjectElements: attribute ].
	"exporting a regular object attribute using a setter or reflection"
	value := attribute value.
	attributeNode := self ensureVisited: value.
	self statementBlock addNode:
		((attribute object type findSetterOf: famixAttribute)
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
							 (RBVariableNode named: '#' , famixAttribute name).
							 attributeNode } ])
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitPrimitive: primitive [

	^ RBLiteralValueNode value: primitive value
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitTypeReference: aFamixValueOfTypeReference [

	^ RBVariableNode named: aFamixValueOfTypeReference value name
]
