"
A visitor for exporting a FamixValue model to the Pharo AST, see `RBEntity` and `RBNode`.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the `withAll:` class method.
"
Class {
	#name : #FamixValue2PharoVisitor,
	#superclass : #FamixValue2ASTVisitor,
	#category : #'Famix-Value-Exporter'
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
				ifTrue: [ self varNameFor: value ]
				ifFalse: [ nil ] ].
	^ node
]

{ #category : #visiting }
FamixValue2PharoVisitor >> findRequiredVariablesFor: rootValue [
	"Values referenced at least twice and the root value will be in variables."

	(FamixValueReferenceCountVisitor visit: rootValue) keysAndValuesDo: [
		:value
		:count |
		count > 1 ifTrue: [ "ifFalse: [ varNameDict at: value put: nil ]"
			self varNameFor: value ] ].
	self varNameFor: rootValue
]

{ #category : #accessing }
FamixValue2PharoVisitor >> statementBlock [

	^ statementBlock ifNil: [ statementBlock := RBSequenceNode new ]
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
					    RBMessageNode
						    receiver: (self ensureVisited: assoc key)
						    selector: #'->'
						    arguments: { (self ensureVisited: assoc value) } ])) }
]

{ #category : #visiting }
FamixValue2PharoVisitor >> visitObject: object [

	| objectNode attributeNodes |
	objectNode := RBMessageNode
		              receiver: (RBVariableNode named: object type name)
		              selector: #new.
	attributeNodes := object value
		                  collect: [ :attribute |
		                  self visitObjectAttribute: attribute ]
		                  thenReject: #isNil.
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
