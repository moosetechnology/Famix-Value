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
		'builder',
		'markedForReflection',
		'constructorCache',
		'staticAttributesCache',
		'objectExportStrategy'
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
							 self makeVariableExpression: objAttribute value ]
							 ifNone: [ "the object does not have the attribute set"
								 paramAttribute declaredType asFASTJavaDefaultValueOn:
									 self model ] ]) ]
]

{ #category : #initialization }
FamixValue2FASTJavaVisitor >> builder [

	^ builder ifNil: [ builder := FASTJavaBuilder new model: self model ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> constructObject: object [

	| constructor |
	constructor := self findConstructorFor: object.
	(self markedForReflection includes: constructor)
		ifFalse: [
			| varDecl |
			varDecl := self statementBlock addStatement:
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
						  self markedForReflection add: constructors first ] ] ]
]

{ #category : #private }
FamixValue2FASTJavaVisitor >> findStaticAttributeMatching: object [
	"Only try to find static attributes for object composed of only primitive values, for now."

	| type staticAttributes objAttributes |
	type := object type.
	((objAttributes := object relevantAttributes) allSatisfy: [
		 :attribute | attribute value isOfPrimitiveType ]) ifFalse: [ ^ nil ].
	"eligible attributes are public, static, of the same type, and have an initializer expression; the conditions are ordered for maximum time efficiency"
	staticAttributes := staticAttributesCache at: type ifAbsentPut: [
		                    type attributes select: [ :attribute |
			                    attribute declaredType == object type and: [
				                    attribute isStaticConstant ] ] ].
	staticAttributes ifEmpty: [ ^ nil ].
	"get a list of the object's attributes represented as source code literals"
	objAttributes := objAttributes collect: [ :objAttribute |
		                 objAttribute value type name = 'String'
			                 ifTrue: [ '"' , objAttribute value value , '"' ]
			                 ifFalse: [ objAttribute value value asString ] ].
	^ staticAttributes
		  detect: [ :attribute |
		  attribute initializerMatchesValues: objAttributes ]
		  ifNone: nil
]

{ #category : #initialization }
FamixValue2FASTJavaVisitor >> initialize [

	constructorCache := IdentityDictionary new.
	staticAttributesCache := IdentityDictionary new
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeClassTypeExpression: typeName [

	^ self model newClassTypeExpression typeName:
		  (model newTypeName name: typeName)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeHelper [
	"The helper should always be generated, regardless of strategy.
	This method must be called after all of the other value exports are done."

	| helperClass |
	self model newCompilationUnit
		packageDeclaration: (model newPackageDeclaration qualifiedName:
					 (model newQualifiedName name: 'fr.evref.modest'));
		importDeclarations: self builder makeImportDeclarations;
		addImportDeclaration: (model newImportDeclaration qualifiedName:
					 (model newQualifiedName name: 'java.io.IOException'));
		addImportDeclaration: (model newImportDeclaration qualifiedName:
					 (model newQualifiedName name:
							  'com.fasterxml.jackson.databind.ObjectMapper'));
		addClassDeclaration: (helperClass := self makeHelperClass).
	self objectExportStrategy addToHelper: helperClass
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeHelperClass [
	"The helper class has static methods used for creating objects.
	It has a private constructor, a Jackson ObjectMapper and a `deserialize` method to handle stubs."

	^ self model newClassDeclaration
		  name: 'ModestHelper';
		  addModifier: (model newModifier token: 'public');
		  declarations: {
				  (model newMethodEntity
					   name: 'ModestHelper';
					   modifiers: { (model newModifier token: 'private') };
					   statementBlock: model newStatementBlock).
				  (model newVarDeclStatement
					   type: (model newClassTypeExpression typeName:
								    (model newTypeName name: 'ObjectMapper'));
					   modifiers: {
							   (model newModifier token: 'private').
							   (model newModifier token: 'static').
							   (model newModifier token: 'final') };
					   declarators: { (model newVariableDeclarator
							    variable: (model newVariableExpression name: 'mapper');
							    expression:
								    (model newNewExpression type:
										     (model newClassTypeExpression typeName:
												      (model newTypeName name: 'ObjectMapper')))) }).
				  (model newMethodEntity
					   typeParameters:
						   { (model newTypeParameterExpression name: 'T') };
					   type:
						   (model newClassTypeExpression typeName:
								    (model newTypeName name: 'T'));
					   name: 'deserialize';
					   parameters: {
							   (model newParameter
								    variable: (model newVariableExpression name: 'json');
								    type: (model newClassTypeExpression typeName:
											     (model newTypeName name: 'String'))).
							   (model newParameter
								    variable: (model newVariableExpression name: 'clazz');
								    type: (model newClassTypeExpression
										     typeName: (model newTypeName name: 'Class');
										     arguments: { (model newClassTypeExpression typeName:
													      (model newTypeName name: 'T')) })) };
					   modifiers: {
							   (model newModifier token: 'public').
							   (model newModifier token: 'static') };
					   statementBlock: (model newStatementBlock statements: {
								    (model newTryCatchStatement
									     try: (model newStatementBlock statements:
												      { (model newReturnStatement expression:
														       (model newMethodInvocation
															        receiver: (model newIdentifier name: 'mapper');
															        name: 'readValue';
															        arguments: {
																	        (model newVariableExpression name: 'json').
																	        (model newVariableExpression name: 'clazz') })) });
									     catches: { (model newCatchPartStatement
											      catchedTypes:
												      { (model newClassTypeExpression typeName:
														       (model newTypeName name: 'IOException')) };
											      body: (model newStatementBlock statements:
														       { (model newExpressionStatement expression:
																        (model newMethodInvocation
																	         receiver: (model newIdentifier name: 'e');
																	         name: 'printStackTrace')) });
											      parameter: (model newVariableExpression name: 'e')) }).
								    (model newReturnStatement expression: model newNullLiteral) })) }
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeNewExpression: object [

	^ self model newNewExpression type:
		  (object asFASTJavaTypeExpressionOn: self)
	"(self makeClassTypeExpression: object type concreteTypeName)"
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeReflectionFieldGetter: attribute [

	^ self model newMethodInvocation
		  receiver: (model newClassProperty
				   type:
					   (self makeClassTypeExpression: attribute object type typeName);
				   fieldName: 'class');
		  name: 'getField';
		  addArgument:
		  (model newStringLiteral primitiveValue: attribute attribute name);
		  yourself
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeReflectionSetterInvocation: attribute [
	"Use reflection to set an attribute on an object."

	self flag: #TODO. "we need to make a variable to hold the field, make it accessible, then use it to set the value."
	self halt. "current implementation does not work"
	self markedForReflection add: attribute attribute.
	self statementBlock addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver: (self makeReflectionFieldGetter: attribute);
				  name: (attribute value type isPrimitiveType
						   ifTrue: [ 'set' , attribute value type name capitalized ]
						   ifFalse: [ 'set' ]);
				  addArgument: (self makeVariableExpression: attribute object);
				  addArgument: (self makeVariableExpression: attribute value);
				  yourself))
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeSetterInvocation: setter for: attribute [

	self
		makeSetterInvocation: setter
		for: attribute
		named: (self varNameFor: attribute value)
]

{ #category : #ast }
FamixValue2FASTJavaVisitor >> makeSetterInvocation: setter for: attribute named: aString [

	self statementBlock addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver: (self makeVariableExpression: attribute object);
				  name: setter name;
				  addArgument: (model newVariableExpression name: aString);
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

	self statementBlock addStatement: (model newVarDeclStatement
			 type: (object asFASTJavaTypeExpressionOn: self);
			 addDeclarator: (model newVariableDeclarator
					  variable: (self makeVariableExpression: object);
					  expression: (model newClassProperty
							   type: (self makeClassTypeExpression: object type name);
							   fieldName: attribute name));
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
FamixValue2FASTJavaVisitor >> objectExportStrategy [

	^ objectExportStrategy ifNil: [
		  objectExportStrategy := FamixValueInlineObjectExportStrategy new ]
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> objectExportStrategy: anObjectExportStrategy [

	objectExportStrategy := anObjectExportStrategy
]

{ #category : #accessing }
FamixValue2FASTJavaVisitor >> statementBlock [

	^ statementBlock ifNil: [
		  statementBlock := self model newStatementBlock ]
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitCollection: collection [
	"Dispatch to type to handle special cases"

	^ collection type acceptValueVisitor: self forCollection: collection
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitCollectionOfRegularType: collection [

	| varName |
	self statementBlock addStatement:
		(self makeVarDeclStatement: collection).
	varName := self varNameDict at: collection.
	collection value do: [ :element |
		self ensureVisited: element value.
		statementBlock addStatement:
			(self model newExpressionStatement expression:
				 (model newMethodInvocation
					  receiver: (model newIdentifier name: varName);
					  name: 'add';
					  addArgument: (self makeVariableExpression: element value);
					  yourself)) ].
	^ statementBlock
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitDictionary: dictionary [

	| varName |
	self statementBlock addStatement:
		(self makeVarDeclStatement: dictionary).
	varName := self varNameDict at: dictionary.
	dictionary value do: [ :association |
		self ensureVisited: association key.
		self ensureVisited: association value.
		statementBlock addStatement:
			(self model newExpressionStatement expression:
				 (model newMethodInvocation
					  receiver: (model newIdentifier name: varName);
					  name: 'put';
					  addArgument: (self makeVariableExpression: association key);
					  addArgument: (self makeVariableExpression: association value);
					  yourself)) ].
	^ statementBlock
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitEnumValue: enumValue [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: enumValue);
		  yourself
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObject: object [
	"Dispatch to type to handle special cases"

	^ object type acceptValueVisitor: self forObject: object
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectAttribute: attribute [

	attribute attribute ifNil: [ "ignore unknown attributes" ^ self ].
	self ensureVisited: attribute value.
	(attribute object type findSetterOf: attribute attribute)
		ifNotNil: [ :setter | self makeSetterInvocation: setter for: attribute ]
		ifNil: [ self makeReflectionSetterInvocation: attribute ]
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectOfRegularType: object [
	"Dispatched here from #visitObject: if the object has a regular creation schema:
	use constructor, then setup each attribute and use setter or reflection."

	(self findStaticAttributeMatching: object)
		ifNotNil: [ :attribute |
			self makeVarDeclStatement: object usingStaticAttribute: attribute ]
		ifNil: [ self objectExportStrategy export: object on: self ].
	^ statementBlock
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitObjectStub: object [

	self statementBlock addStatement: (self model newVarDeclStatement
			 type: (object asFASTJavaTypeExpressionOn: self);
			 addDeclarator: (self model newVariableDeclarator
					  variable: (self makeVariableExpression: object);
					  expression: (model newMethodInvocation
							   name: 'deserialize';
							   arguments: {
									   (model newStringLiteral primitiveValue:
											    object asJsonString).
									   (model newClassProperty
										    type: (object asFASTJavaTypeExpressionOn: self);
										    fieldName: 'class') }));
			 yourself)
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitPrimitive: primitive [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: primitive);
		  yourself
]

{ #category : #visiting }
FamixValue2FASTJavaVisitor >> visitValueOfUnknownType: value [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: value);
		  yourself
]
