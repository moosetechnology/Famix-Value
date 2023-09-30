"
A visitor for exporting a FamixValue model to FASTJava.
The generated code is a block statement with a variable declared for each value.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the `add(element)` and `put(key, value)` methods respectively.
"
Class {
	#name : #FamixValue2FASTJavaVisitor,
	#superclass : #FamixValue2ASTVisitor,
	#category : #'Famix-Value-Exporter'
}

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeClassTypeExpression: typeName [

	^ self model newClassTypeExpression typeName:
		  (model newTypeName name: typeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeNewExpression: object [

	^ self model newNewExpression type:
		  (self makeClassTypeExpression: object type concreteTypeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVarDeclStatement: value [

	^ self model newVarDeclStatement
		  type: (value asFASTJavaTypeExpressionOn: self);
		  addDeclarator: (self makeVariableDeclarator: value);
		  yourself
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVariableDeclarator: value [

	^ self model newVariableDeclarator
		  variable:
			  (self model newVariableExpression name: (self varNameFor: value));
		  expression: (value asFASTJavaExpressionOn: self)
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> statements [

	^ statements ifNil: [ statements := self model newStatementBlock ]
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitCollection: collection [

	| varName |
	self statements addStatement: (self makeVarDeclStatement: collection).
	varName := self varNameDict at: collection.
	collection value do: [ :element | 
		self ensureVisited: element value.
		self statements addStatement:
			(self model newExpressionStatement expression:
				 (model newMethodInvocation
					  receiver: (model newIdentifier name: varName);
					  name: 'add';
					  addArgument: (model newVariableExpression name:
								   (self varNameDict at: element value));
					  yourself)) ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitDictionary: dictionary [

	| varName |
	self statements addStatement: (self makeVarDeclStatement: dictionary).
	varName := self varNameDict at: dictionary.
	dictionary value do: [ :association | 
		self ensureVisited: association key.
		self ensureVisited: association value.
		self statements addStatement:
			(self model newExpressionStatement expression:
				 (model newMethodInvocation
					  receiver: (model newIdentifier name: varName);
					  name: 'put';
					  addArgument: (model newVariableExpression name:
								   (self varNameDict at: association key));
					  addArgument: (model newVariableExpression name:
								   (self varNameDict at: association value));
					  yourself)) ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitEnumValue: enumValue [

	^ self statements
		  addStatement: (self makeVarDeclStatement: enumValue);
		  yourself
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObject: object [

	"Dispatch to type to handle special cases"

	^ object type acceptValueVisitor: self for: object
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectAttribute: attribute [

	| value setter |
	attribute attribute ifNil: [ "ignore unknown attributes" ^ self ].
	self ensureVisited: (value := attribute value).
	setter := attribute object type findSetterFor: attribute attribute.
	self statements addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver:
					  (model newIdentifier name:
							   (self varNameDict at: attribute object));
				  name: setter name;
				  addArgument:
					  (model newVariableExpression name: (self varNameDict at: value));
				  famixInvocation: (FamixJavaInvocation new addCandidate: setter);
				  yourself))
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectOfRegularType: object [

	"Dispatched here from #visitObject: if the object has a regular creation schema:
	use constructor, then setup each attribute and use setter or reflection."

	self statements addStatement: (self makeVarDeclStatement: object).
	object value do: [ :attribute | self visitObjectAttribute: attribute ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitPrimitive: primitive [

	^ self statements
		  addStatement: (self makeVarDeclStatement: primitive);
		  yourself
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitValueOfUnknownType: value [

	^ self statements
		  addStatement: (self makeVarDeclStatement: value);
		  yourself
]
