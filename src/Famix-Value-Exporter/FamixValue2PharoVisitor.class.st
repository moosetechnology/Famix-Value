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

{ #category : #testing }
FamixValue2PharoVisitor >> ensureVisited: value [

	| node |
	self varNameDict
		at: value
		ifPresent: [ :name | ^ RBVariableNode named: name ]
		ifAbsentPut: [
			node := value accept: self.
			value referenceCount > 1
				ifTrue: [
					| name |
					name := self varNameFor: value.
					node := RBAssignmentNode
						        variable: (RBVariableNode named: name)
						        value: node.
					name ]
				ifFalse: [ nil ] ].
	^ node
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

	| objectNode attributeNodes |
	object value detect: [ :a | a attribute isNil ].
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
FamixValue2PharoVisitor >> visitCollection: collection [

	| collectionNode |
	collectionNode := RBArrayNode statements:
		                  (collection value collect: [ :element |
			                   self ensureVisited: element value ]).
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

	attribute attribute ifNil: [ "ignore unknown attributes" ^ nil ].
	^ (attribute object type findSetterOf: attribute attribute)
		  ifNotNil: [ :setter |
			  RBMessageNode
				  receiver: RBVariableNode new
				  selector: setter name
				  arguments: { (self ensureVisited: attribute value) } ]
		  ifNil: [ "Use reflectivity"
			  RBMessageNode
				  receiver: RBVariableNode new
				  selector: #instVarNamed:put:
				  arguments: {
						  (RBVariableNode named: '#' , attribute attribute name).
						  (self ensureVisited: attribute value) } ]
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitPrimitive: primitive [

	^ RBLiteralValueNode value: primitive value
]
