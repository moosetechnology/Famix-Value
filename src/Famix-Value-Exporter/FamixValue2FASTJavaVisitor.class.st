"
A visitor for exporting a FamixValue model to FASTJava.
The generated code is a block statement with a variable declared for each value.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the `add(element)` and `put(key, value)` methods respectively.

When exporting a `FamixValueOfObjectAttribute`, if the setter for its `FamixTAttribute` cannot be found, they are set using the Java Reflection API.
All attributes that fall in this category are added as `markedForReflection`.
"
Class {
	#name : #FamixValue2FASTJavaVisitor,
	#superclass : #FamixValue2ASTVisitor,
	#instVars : [
		'markedForReflection'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeClassTypeExpression: typeName [

	^ self model newClassTypeExpression typeName:
		  (model newTypeName name: typeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeIdentifier: value [

	^ self model newIdentifier name: (self varNameFor: value)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeNewExpression: object [

	^ self model newNewExpression type:
		  (self makeClassTypeExpression: object type concreteTypeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeReflectionFieldGetter: attribute [

	^ self model newMethodInvocation
		  receiver: (model newClassProperty type:
					   (self makeClassTypeExpression: attribute object type typeName));
		  name: 'getField';
		  addArgument:
			  (model newStringLiteral primitiveValue: attribute attribute name);
		  yourself
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeReflectionSetter: attribute [

	self markedForReflection add: attribute attribute.
	^ self model newMethodInvocation
		  receiver: (self makeReflectionFieldGetter: attribute);
		  name: (attribute value type isPrimitiveType
				   ifTrue: [ 'set' , attribute value type name capitalized ]
				   ifFalse: [ 'set' ]);
		  addArgument: (self makeVariableExpression: attribute object);
		  addArgument: (self makeVariableExpression: attribute value);
		  yourself
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeSetter: setter for: attribute [

	self statements addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver: (self makeIdentifier: attribute object);
				  name: setter name;
				  addArgument: (self makeVariableExpression: attribute value);
				  "famixInvocation: (FamixJavaInvocation new addCandidate: setter);"
					  yourself))
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
		  variable: (self makeVariableExpression: value);
		  expression: (value asFASTJavaExpressionOn: self)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVariableExpression: value [

	^ self model newVariableExpression name: (self varNameFor: value)
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> markedForReflection [

	^ markedForReflection ifNil: [ markedForReflection := Set new ]
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
					  addArgument: (self makeVariableExpression: element value);
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
					  addArgument: (self makeVariableExpression: association key);
					  addArgument: (self makeVariableExpression: association value);
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

	attribute attribute ifNil: [ "ignore unknown attributes" ^ self ].
	self ensureVisited: attribute value.
	(attribute object type findSetterOf: attribute attribute)
		ifNotNil: [ :setter | self makeSetter: setter for: attribute ]
		ifNil: [ self makeReflectionSetter: attribute ]
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
