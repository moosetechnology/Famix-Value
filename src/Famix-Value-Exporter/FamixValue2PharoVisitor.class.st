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
		'useTempVars'
	],
	#category : 'Famix-Value-Exporter-Visitors',
	#package : 'Famix-Value-Exporter',
	#tag : 'Visitors'
}

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
	useTempVars := false "See #makeVariableNamed:"
]

{ #category : 'testing' }
FamixValue2PharoVisitor >> makeAssignment: aValue to: aVariableName [
	"The number of temporary variables is limited by the stack size limit.
	We can use a dictionary to hold all variables to avoid compilation errors."

	^ useTempVars
		  ifTrue: [
			  RBAssignmentNode
				  variable: (self makeVariableNamed: aVariableName)
				  value: aValue ]
		  ifFalse: [
			  RBMessageNode
				  receiver: (RBVariableNode named: 'vars')
				  selector: #at:put:
				  arguments: {
						  (RBLiteralNode value: aVariableName).
						  aValue } ]
]

{ #category : 'ast' }
FamixValue2PharoVisitor >> makeHelper [

	
]

{ #category : 'ast' }
FamixValue2PharoVisitor >> makeVariableExpression: value [

	^ RBVariableNode named: (self varNameFor: value)
]

{ #category : 'testing' }
FamixValue2PharoVisitor >> makeVariableNamed: aString [
	"The default is to not use temp vars, but to store values in a dict instead.
	This is a workaround to store an indefinite amount of variables in a Pharo method, which are normally limited to 255."

	^ useTempVars
		  ifTrue: [ RBVariableNode named: aString ]
		  ifFalse: [
			  RBMessageNode
				  receiver: (RBVariableNode named: 'vars')
				  selector: #at:
				  arguments: { (RBLiteralNode value: aString) } ]
]

{ #category : 'accessing' }
FamixValue2PharoVisitor >> statementBlock [

	^ statementBlock ifNil: [ statementBlock := RBSequenceNode new ]
]

{ #category : 'ast' }
FamixValue2PharoVisitor >> useTempVarsDuring: aBlock [
	"Force using temporary variables to rebuild values during a block.
	See #makeVariableNamed: for the explanation about why this is needed."

	| wasUsingTempVars |
	wasUsingTempVars := useTempVars.
	useTempVars := true.
	^ [ aBlock value ] ensure: [ useTempVars := wasUsingTempVars ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitClosure: closure [

	self flag: #TODO.
	closure variables do: [ :var | self ensureVisited: var value ].

	^ [ "TODO how to reference variables now that everything is in a dictionary?
		  -> probably need to rewrite source..."
	  self statementBlock addNode: (self
			   makeAssignment: (RBParser parseExpression: closure sourceCode)
			   to: (self varNameFor: closure)) ]
		  on: CodeError
		  do: [ :error | "TODO: fix reflective operation on block when metalink is installed"
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

	collection value ifEmpty: [ "Inline empty collections in tests"
		^ self statementBlock statements last ].

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

	dictionary value ifEmpty: [ "Inline empty dictionaries in tests"
		^ self statementBlock statements last ].

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

	^ self statementBlock addNode: (association dictionary
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
	"Smalltalk does not have enumerations"

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

	object value ifEmpty: [ "Inline empty objects in tests"
		^ self statementBlock statements last ].

	object value do: [ :attribute | self visitObjectAttribute: attribute ]
]

{ #category : 'visiting' }
FamixValue2PharoVisitor >> visitObjectAttribute: attribute [

	| famixAttribute value attributeNode |
	(famixAttribute := attribute attribute) ifNil: [ ^ nil ]. "Ignore unknown Famix attributes"
	famixAttribute name = '@' ifTrue: [
		^ self visitIndexableObjectElements: attribute ].

	"Exporting a regular object attribute using a setter or reflection"
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
