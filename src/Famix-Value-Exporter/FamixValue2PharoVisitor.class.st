"
A visitor for exporting a FamixValue model to the Pharo AST, see `RBNode`.

Object attributes are initialized by finding the corresponding setters.
Collections are constructed using the `withAll:` class method.
Dictionaries are constructed using the `newFrom:` class method.
"
Class {
	#name : #FamixValue2PharoVisitor,
	#superclass : #FamixValue2ASTVisitor,
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

	^ self varNameDict
		  at: value
		  ifPresent: [ :name | RBVariableNode named: name ]
		  ifAbsent: [
			  | name node |
			  name := self varNameFor: value.
			  value isOfPrimitiveType ifFalse: [
				  self varNameDict at: value put: name ].
			  node := value accept: self.
			  value isReferencedInLoop
				  ifTrue: [
				  RBAssignmentNode
					  variable: (RBVariableNode named: name)
					  value: node ]
				  ifFalse: [ node ] ]
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
		| visitedVar |
		visitedVar := self ensureVisited: var value.
		statementBlock addNodeFirst: (RBAssignmentNode
				 variable: (RBVariableNode named: var name)
				 value: visitedVar) ].
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
			                   | newNode |
			                   newNode := self ensureVisited: element value.
			                   (element value isReferencedInLoop and: [
				                    newNode isVariable not and: [
					                    newNode value isLiteralNode not ] ])
				                   ifTrue: [ newNode addParenthesisToVariable ]
				                   ifFalse: [ newNode ] ]).
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

	^ RBMessageNode
		  receiver: (self ensureVisited: association key)
		  selector: #'->'
		  arguments: { (self ensureVisited: association value) }
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitEnumValue: enumValue [

	self shouldNotImplement
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObject: object [

	| objectNode attributeNodes |
	object type name = 'FullBlockClosure' ifTrue: [
		^ self visitClosure: object ].
	objectNode := RBMessageNode
		              receiver: (RBVariableNode named: object type name)
		              selector: #new.
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

	| newNode |
	attribute attribute ifNil: [ "ignore unknown attributes" ^ nil ].
	(attribute object type findSetterOf: attribute attribute)
		ifNotNil: [ :setter |
			newNode := RBMessageNode
				           receiver: RBVariableNode new
				           selector: setter name
				           arguments: { (self ensureVisited: attribute value) } ]
		ifNil: [ "Use reflectivity"
			newNode := RBMessageNode
				           receiver: RBVariableNode new
				           selector: #instVarNamed:put:
				           arguments: {
						           (RBVariableNode named: '#' , attribute attribute name).
						           (self ensureVisited: attribute value) } ].

	attribute value isReferencedInLoop ifTrue: [
		^ newNode addParenthesisToVariable].
	^ newNode
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitPrimitive: primitive [

	^ RBLiteralValueNode value: primitive value
]
