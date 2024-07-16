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
		'definedValues'
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
		  ifPresent: [ :name |
			  | varName |
			  varName := RBVariableNode named: name.
			  (definedValues includes: value)
				  ifTrue: [ varName ]
				  ifFalse: [
					  definedValues add: value.
					  RBAssignmentNode
						  variable: varName
						  value: value asPharoInitializationAST ] ]
		  ifAbsent: [
			  | name node |
			  name := self varNameFor: value.
			  node := value accept: self.
			  value isReferencedInLoop
				  ifTrue: [
					  (node isCascade and: [
						   node messages first receiver isAssignment not ])
						  ifTrue: [ "add parenthesis"
							  | receiver |
							  receiver := node messages first receiver.
							  node messages first receiver: (RBAssignmentNode
									   variable: (RBVariableNode named: name)
									   value: receiver).
							  node ]
						  ifFalse: [
						  RBAssignmentNode
							  variable: (RBVariableNode named: name)
							  value: node ] ]
				  ifFalse: [ node ] ]
]

{ #category : #initialization }
FamixValue2PharoVisitor >> initialize [

	super initialize.

	definedValues := IdentitySet new
]

{ #category : #ast }
FamixValue2PharoVisitor >> makeHelper [

	
]

{ #category : #visiting }
FamixValue2PharoVisitor >> makeVariableExpression: value [

	^ RBVariableNode named: (self varNameFor: value)
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
FamixValue2PharoVisitor >> visitClosure: object [

	object variables do: [ :var |
		| varNode value newNode |
		value := var value.
		newNode := self ensureVisited: value.

		(value isOfObject or: [
			 value isOfCollection or: [ value isOfDictionary ] ])
			ifTrue: [
				| name |
				name := self varNameFor: value.
				self statementBlock addNode: (RBAssignmentNode
						 variable: (RBVariableNode named: name)
						 value: newNode).
				varNode := RBVariableNode named: name ]
			ifFalse: [ varNode := newNode ].

		statementBlock addNodeFirst: (RBAssignmentNode
				 variable: (RBVariableNode named: var name)
				 value: varNode) ].
	^ [ RBParser parseExpression: object sourceCode ]
		  on: SyntaxErrorNotification
		  do: [ :error | "TODO: fix reflective opperation on block when metalink is installed"
			  Transcript crShow: error description.
			  error pass ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitCollection: collection [

	| collectionNode |
	collectionNode := RBArrayNode statements:
		                  (collection value collect: [ :element |
			                   | newNode elementNode value |
			                   value := element value.
			                   newNode := self ensureVisited: value.
			                   (value isOfObject or: [
				                    value isOfCollection or: [
					                    value isOfDictionary ] ])
				                   ifTrue: [
					                   | name |
					                   name := self varNameFor: value.
					                   self statementBlock addNode:
						                   (RBAssignmentNode
							                    variable: (RBVariableNode named: name)
							                    value: newNode).
					                   elementNode := RBVariableNode named: name ]
				                   ifFalse: [ elementNode := newNode ].
			                   (value isReferencedInLoop and: [
				                    elementNode isAssignment and: [
					                    elementNode isVariable not and: [
						                    elementNode value isLiteralNode not ] ] ])
				                   ifTrue: [ elementNode addParenthesisToVariable ]
				                   ifFalse: [ elementNode ] ]).
	^ collection type name = 'Array'
		  ifTrue: [ collectionNode ]
		  ifFalse: [
			  RBMessageNode
				  receiver: (RBVariableNode named: collection type name)
				  selector: #withAll:
				  arguments: { collectionNode } ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitDictionary: dictionary [

	^ RBMessageNode
		  receiver: (RBVariableNode named: dictionary type name)
		  selector: #newFrom:
		  arguments:
			  { (RBArrayNode statements: (dictionary value collect: [ :assoc |
					    self visitDictionaryAssociation: assoc ])) }
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitDictionaryAssociation: association [

	| key value keyNode valueNode newNode |
	key := association key.
	value := association value.

	newNode := self ensureVisited: key.
	(key isOfObject or: [ key isOfCollection or: [ key isOfDictionary ] ])
		ifTrue: [
			| name |
			name := self varNameFor: value.
			self statementBlock addNode: (RBAssignmentNode
					 variable: (RBVariableNode named: name)
					 value: newNode).
			keyNode := RBVariableNode named: name ]
		ifFalse: [ keyNode := newNode ].

	newNode := self ensureVisited: value.
	(value isOfObject or: [
		 value isOfCollection or: [ value isOfDictionary ] ])
		ifTrue: [
			| name |
			name := self varNameFor: value.
			self statementBlock addNode: (RBAssignmentNode
					 variable: (RBVariableNode named: name)
					 value: newNode).
			valueNode := RBVariableNode named: name ]
		ifFalse: [ valueNode := newNode ].

	^ RBMessageNode
		  receiver: keyNode
		  selector: #'->'
		  arguments: { valueNode }
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitEnumValue: enumValue [

	self shouldNotImplement
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObject: object [

	| objectNode attributeNodes |
	objectNode := object isReferencedInLoop
		              ifTrue: [
		              RBVariableNode named: (self varNameFor: object) ]
		              ifFalse: [
			              RBMessageNode
				              receiver: (RBVariableNode named: object type name)
				              selector: #new ].
	attributeNodes := (object value
		                   collect: [ :attribute |
		                   self visitObjectAttribute: attribute ]
		                   as: OrderedCollection) reject: #isNil.
	attributeNodes ifEmpty: [ ^ objectNode ].
	attributeNodes first receiver: objectNode.
	attributeNodes add:
		(RBMessageNode receiver: RBVariableNode new selector: #yourself).
	^ RBCascadeNode messages: attributeNodes
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObjectAttribute: attribute [

	| newNode value attributeNode |
	attribute attribute ifNil: [ "ignore unknown attributes" ^ nil ].
	value := attribute value.
	newNode := self ensureVisited: value.
	(value isOfObject or: [
		 value isOfCollection or: [ value isOfDictionary ] ])
		ifTrue: [
			| name |
			name := self varNameFor: value.
			self statementBlock addNode: (RBAssignmentNode
					 variable: (RBVariableNode named: name)
					 value: newNode).
			attributeNode := RBVariableNode named: name ]
		ifFalse: [ attributeNode := newNode ].
	(attribute object type findSetterOf: attribute attribute)
		ifNotNil: [ :setter |
			newNode := RBMessageNode
				           receiver: RBVariableNode new
				           selector: setter name
				           arguments: { attributeNode } ]
		ifNil: [ "Use reflectivity"
			newNode := RBMessageNode
				           receiver: RBVariableNode new
				           selector: #instVarNamed:put:
				           arguments: {
						           (RBVariableNode named: '#' , attribute attribute name).
						           attributeNode } ].

	(attribute value isReferencedInLoop and: [
		 newNode isVariable not and: [
			 newNode value isLiteralNode not and: [
				 newNode isMessage not and: [ newNode isAssignment ] ] ] ])
		ifTrue: [ ^ newNode addParenthesisToVariable ].
	^ newNode
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitPrimitive: primitive [

	^ RBLiteralValueNode value: primitive value
]
