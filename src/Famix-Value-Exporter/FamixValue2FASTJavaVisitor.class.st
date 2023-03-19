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

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeClassTypeExpression: typeName [

	^ self newClassTypeExpression typeName:
		  (self newTypeName name: typeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeNewExpression: object [

	^ self newNewExpression type:
		  (self makeClassTypeExpression: object type concreteTypeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVarDeclStatement: value [

	^ self newVarDeclStatement
		  type: (value asFASTJavaTypeExpressionOn: self);
		  addDeclarator: (self makeVariableDeclarator: value);
		  yourself
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVariableDeclarator: value [

	^ self newVariableDeclarator
		  variable: (self makeVariableExpression: value);
		  expression: (value asFASTJavaExpressionOn: self)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVariableExpression: value [

	^ self newVariableExpression name: (self varNameFor: value)
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newBooleanLiteral [

	^ self model silentlyAdd: FASTJavaBooleanLiteral new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newBooleanTypeExpression [

	^ self model silentlyAdd: FASTJavaBooleanTypeExpression new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newClassProperty [

	^ self model silentlyAdd: FASTJavaClassProperty new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newClassTypeExpression [

	^ self model silentlyAdd: FASTJavaClassTypeExpression new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newExpressionStatement [

	^ self model silentlyAdd: FASTJavaExpressionStatement new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newIdentifier [

	^ self model silentlyAdd: FASTJavaIdentifier new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newIntTypeExpression [

	^ self model silentlyAdd: FASTJavaIntTypeExpression new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newIntegerLiteral [

	^ self model silentlyAdd: FASTJavaIntegerLiteral new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newMethodInvocation [

	^ self model silentlyAdd: FASTJavaMethodInvocation new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newNewClassExpression [

	^ self model silentlyAdd: FASTJavaNewClassExpression new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newNewExpression [

	^ self model silentlyAdd: FASTJavaNewExpression new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newNullLiteral [

	^ self model silentlyAdd: FASTJavaNullLiteral new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newStatementBlock [

	^ self model silentlyAdd: FASTJavaStatementBlock new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newStringLiteral [

	^ self model silentlyAdd: FASTJavaStringLiteral new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newTypeName [

	^ self model silentlyAdd: FASTJavaTypeName new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newVarDeclStatement [

	^ self model silentlyAdd: FASTJavaVarDeclStatement new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newVariableDeclarator [

	^ self model silentlyAdd: FASTJavaVariableDeclarator new
]

{ #category : #'entity creation' }
FamixValue2FASTJavaVisitor >> newVariableExpression [

	^ self model silentlyAdd: FASTJavaVariableExpression new
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> nextId [

	^ (id := (id ifNil: 0) + 1) - 1
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> statements [

	^ statements ifNil: [ statements := self newStatementBlock ]
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> varNameDict [

	^ varNameDict ifNil: [ varNameDict := Dictionary new ]
]

{ #category : #naming }
FamixValue2FASTJavaVisitor >> varNameFor: value [

	^ self varNameDict at: value ifAbsentPut: [ 
		  (value typedEntity
			   ifNotNil: [ value typedEntity name ]
			   ifNil: [ value type baseName uncapitalized ])
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

	element accept: self.
	self statements addStatement:
		(self newExpressionStatement expression: (self newMethodInvocation
				  receiver:
					  (self newIdentifier name: (self varNameDict at: collection));
				  name: #add;
				  addArgument:
					  (self newVariableExpression name:
							   (self varNameDict at: element));
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

	association key accept: self.
	association value accept: self.
	self statements addStatement:
		(self newExpressionStatement expression: (self newMethodInvocation
				  receiver: (self newIdentifier name:
							   (self varNameDict at: association dictionary));
				  name: #put;
				  addArgument: (self newVariableExpression name:
							   (self varNameDict at: association key));
				  addArgument: (self newVariableExpression name:
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

	self statements addStatement: (self makeVarDeclStatement: object).
	object value do: [ :attribute | 
		self visitObject: object attribute: attribute ].
	^ statements
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObject: object attribute: attribute [

	| setter |
	attribute typedEntity ifNil: [ "ignore unknown attributes" ^ self ].
	attribute accept: self. "generate var for attribute"
	setter := object type allMethods detect: [ :method | 
		          method isSetter and: [ 
			          method name
				          endsWith: attribute typedEntity name
				          caseSensitive: false ] ].
	self statements addStatement:
		(self newExpressionStatement expression: (self newMethodInvocation
				  receiver:
					  (self newIdentifier name: (self varNameDict at: object));
				  name: setter name;
				  addArgument:
					  (self newVariableExpression name:
							   (self varNameDict at: attribute));
				  yourself))
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
