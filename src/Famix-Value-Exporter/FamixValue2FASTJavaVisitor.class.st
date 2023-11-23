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
		'markedForReflection',
		'constructorCache'
	],
	#category : #'Famix-Value-Exporter'
}

{ #category : #private }
FamixValue2FASTJavaVisitor >> addAttributesFrom: object asArgumentsTo: newExpression usingConstructor: constructor [

	(constructorCache
		 at: constructor
		 ifAbsentPut: [ constructor mapConstructorParametersToAttributes ]) 
		withIndexDo: [ :paramAttribute :index | 
			newExpression addArgument: (paramAttribute
					 ifNil: [ 
						 (constructor parameters at: index) declaredType 
							 asFASTJavaDefaultValueOn: self model ]
					 ifNotNil: [ 
						 object value
							 detect: [ :objAttribute | 
							 objAttribute attribute == paramAttribute ]
							 ifOne: [ :objAttribute | 
							 self makeIdentifier: objAttribute value ]
							 ifNone: [ "the object does not have the attribute set" 
								 paramAttribute declaredType asFASTJavaDefaultValueOn:
									 self model ] ]) ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> chooseNonPublicConstructorAmong: constructors [

	self flag: #TODO. "don't just choose first constructor, find the best one"
	self halt.
	^ self markedForReflection add: constructors anyOne
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> constructObject: object [

	| constructor varDecl |
	constructor := self findConstructorFor: object.
	(self markedForReflection includes: constructor)
		ifFalse: [ 
			varDecl := self statements addStatement:
				           (self makeVarDeclStatement: object).
			constructor parameters ifNotEmpty: [ 
				self
					addAttributesFrom: object
					asArgumentsTo: varDecl declarators first expression
					usingConstructor: constructor ] ]
		ifTrue: [ "use reflection" self halt ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> findConstructorFor: object [

	"Order all constructors according to attributes set and number of parameters, then choose best public one.
	If no constructor is explicitly declared, use the default constructor. Otherwise, rely on reflection."

	| type |
	type := object type.
	^ constructorCache at: type ifAbsentPut: [ 
		  type constructorsOrderedByScore
			  ifEmpty: [ "use default constructor, this acts as a null object" 
				  FamixJavaMethod new ]
			  ifNotEmpty: [ :constructors | 
				  constructors
					  detect: [ :constructor | constructor isPublic ]
					  ifNone: [ "fallback to using reflection" 
						  self markedForReflection add: constructors anyOne ] ] ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> findConstructorFor: object among: constructors [

	self flag: #legacy.
	(constructors isEmpty or: [ "no point using a constructor which does not set attributes" 
		 constructors anyOne allAccessedAttributes isEmpty ]) ifTrue: [ 
		^ nil ].
	constructors size = 1 ifTrue: [ ^ constructors anyOne ].
	"TODO choose the constructor which shares the most attributes with object"
	constructors do: [ :constructor | 
		self halt.
		constructor allAccessedAttributes ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> findStaticAttributeMatching: object [
	"Only try to find static attributes for object composed of only primitive values, for now."

	| typeAttributes objAttributes |
	(object value allSatisfy: [ :attribute |
		 attribute value isOfPrimitiveType ]) ifFalse: [ ^ nil ].
	"eligible attributes are public, static, of the same type, and have an initializer expression; the conditions are ordered for maximum time efficiency"
	typeAttributes := object type attributes select: [ :attribute |
		                  attribute declaredType == object type and: [
			                  attribute isStaticConstant ] ].
	typeAttributes ifEmpty: [ ^ nil ].
	"get a list of the objetct's attributes represented as source code literals"
	objAttributes := object value collect: [ :objAttribute |
		                 objAttribute value type name = 'String'
			                 ifTrue: [ '"' , objAttribute value value , '"' ]
			                 ifFalse: [ objAttribute value value asString ] ].
	^ typeAttributes
		  detect: [ :attribute |
		  attribute initializerMatchesValues: objAttributes ]
		  ifNone: [ nil ]
]

{ #category : #initialization }
FamixValue2FASTJavaVisitor >> initialize [

	constructorCache := IdentityDictionary new
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> legacyFindConstructorFor: object [

	"Find the constructor which accesses the most attributes and with the most parameters.
	If no constructor is declared explicitly, use the default constructor if possible.
	If the default constructor is not usable, rely on reflection."

	| type |
	self flag: #legacy.
	type := object type.
	^ constructorCache at: type ifAbsentPut: [ 
		  (self
			   findConstructorFor: object
			   among: type publicConstructorsWithMostImpact)
			  ifNotNil: [ :constructor | constructor ]
			  ifNil: [ "either we can use the default constructor, or we must use reflection"
				  (object type methods select: [ :method | method isConstructor ])
					  ifNotEmpty: [ :constructors | 
					  self chooseNonPublicConstructorAmong: constructors ]
					  ifEmpty: [ "default constructor" FamixJavaMethod new ] ] ]
]

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
				  famixMethod: setter))
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeVarDeclStatement: value [

	^ self model newVarDeclStatement
		  type: (value asFASTJavaTypeExpressionOn: self);
		  addDeclarator: (self makeVariableDeclarator: value);
		  yourself
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> makeVarDeclStatement: object usingStaticAttribute: attribute [

	"Declare a variable for object, initialized with the value of the given static attribute.
	For example: MyClass myClass = MyClass.MY_STATIC_ATTRIBUTE;"

	self statements addStatement: (model newVarDeclStatement
			 type: (object asFASTJavaTypeExpressionOn: self);
			 addDeclarator: (model newVariableDeclarator
					  variable: (self makeVariableExpression: object);
					  expression: (model newClassProperty
							   fieldName: attribute name;
							   type: (self makeClassTypeExpression: object type name)));
			 yourself)
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

	^ markedForReflection ifNil: [ 
		  markedForReflection := IdentitySet new ]
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

	(self findStaticAttributeMatching: object)
		ifNotNil: [ :attribute | 
			self makeVarDeclStatement: object usingStaticAttribute: attribute ]
		ifNil: [ 
			self flag: #TODO. "redo object visit, we need to have attributes ready when calling the constructor.
	We need to know if an attribute has been set using the constructor or if it will be set using a setter!"
			self constructObject: object.
			object value do: [ :attribute | 
				self visitObjectAttribute: attribute ] ].
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
