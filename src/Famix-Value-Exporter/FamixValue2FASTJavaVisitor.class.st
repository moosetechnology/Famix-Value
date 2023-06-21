"
A visitor for exporting a FamixValue model to FASTJava.
The generated code is a block statement with a variable declared for each value.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the `add(element)` and `put(key, value)` methods respectively.
"
Class {
	#name : #FamixValue2FASTJavaVisitor,
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
FamixValue2FASTJavaVisitor >> ensureVisited: value [

	"Visit a value if I have not done it before"

	(self varNameDict includesKey: value) ifFalse: [ value accept: self ]
]

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
FamixValue2FASTJavaVisitor >> model: aFASTJavaModel [

	model := aFASTJavaModel
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> nextId [

	^ (id := (id ifNil: 0) + 1) - 1
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> statements [

	^ statements ifNil: [ statements := self model newStatementBlock ]
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> statements: aStatementCollection [

	statements := aStatementCollection
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> varNameDict [

	^ varNameDict ifNil: [ varNameDict := Dictionary new ]
]

{ #category : #naming }
FamixValue2FASTJavaVisitor >> varNameFor: value [

	^ self varNameDict at: value ifAbsentPut: [ 
		  (value typedEntity ifNotNil: [ value typedEntity name ] ifNil: [ 
			   value attributeInObjects size = 1
				   ifTrue: [ value attributeInObjects first attribute name ]
				   ifFalse: [ value type baseName uncapitalized ] ])
		  , self nextId asString ]
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitCollection: collection [

	self statements addStatement: (self makeVarDeclStatement: collection).
	collection value do: [ :element | 
		self visitCollection: collection element: element ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitCollection: collection element: element [

	self ensureVisited: element value.
	self statements addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver:
					  (model newIdentifier name: (self varNameDict at: collection));
				  name: #add;
				  addArgument: (model newVariableExpression name:
							   (self varNameDict at: element value));
				  yourself))
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitDictionary: dictionary [

	self statements addStatement: (self makeVarDeclStatement: dictionary).
	dictionary value do: [ :association | 
		self visitDictionaryAssociation: association ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitDictionaryAssociation: association [

	self ensureVisited: association key.
	self ensureVisited: association value.
	self statements addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver: (model newIdentifier name:
							   (self varNameDict at: association dictionary));
				  name: #put;
				  addArgument: (model newVariableExpression name:
							   (self varNameDict at: association key));
				  addArgument: (model newVariableExpression name:
							   (self varNameDict at: association value));
				  yourself))
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
				  yourself))
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectOfRegularType: object [

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
