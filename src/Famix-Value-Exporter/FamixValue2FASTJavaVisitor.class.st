"
A visitor to export a FamixValue model to FASTJava.
The generated code is a block statement with a variable declared for each value.

Object attributes are initialized by finding the corresponding setters.
Collections and Dictionaries are constructed with the methods `add(element)` and `put(key, value)` respectively.

When exporting a `FamixValueOfObjectAttribute`, if the setter for its `FamixTAttribute` cannot be found, it is set using the Java Reflection API.
All attributes that fall into this category are added as `markedForReflection`.
"
Class {
	#name : 'FamixValue2FASTJavaVisitor',
	#superclass : 'FamixValue2ASTVisitor',
	#instVars : [
		'builder',
		'constructorCache',
		'staticAttributesCache',
		'objectExportStrategy',
		'reflections',
		'defaultHelperPackage'
	],
	#category : 'Famix-Value-Exporter-Visitors',
	#package : 'Famix-Value-Exporter',
	#tag : 'Visitors'
}

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> addAttributesFrom: object asArgumentsTo: invocation usingConstructor: constructor [

	(constructorCache
		 at: constructor
		 ifAbsentPut: [ constructor mapConstructorParametersToAttributes ])
		withIndexDo: [ :paramAttribute :index |
			invocation addArgument: (paramAttribute
					 ifNil: [ "Constructor parameter is not mapped to an attribute
						 => Give it a default value"
						 (constructor parameters at: index) declaredType
							 ifNil: [ "TODO fix Java parser
								 If it's unknown then it must be a class, otherwise the parser would have found it
								 => The default for class instances is `null`"
								 self model newNullLiteral ]
							 ifNotNil: [ :declaredType |
							 declaredType asFASTJavaDefaultValueOn: self model ] ]
					 ifNotNil: [ "Parameter is mapped to attribute"
						 object value
							 detect: [ :objAttribute | "Find the matching value attribute"
								 objAttribute attribute == paramAttribute ]
							 ifFound: [ :objAttribute | "Dispatch for var naming context"
								 objectExportStrategy
									 makeVariableExpression: objAttribute value
									 on: self ]
							 ifNone: [ "The object does not have the attribute set"
								 paramAttribute declaredType asFASTJavaDefaultValueOn:
									 self model ] ]) ]
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> builder [

	^ builder ifNil: [ builder := FASTJavaBuilder new model: self model ]
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> constructObject: object [
	"Build code to instantiate the object and store it in a variable"

	| constructor invocation |
	constructor := self findConstructorFor: object.

	"Make the constructor invocation"
	invocation := self reflections
		              at: constructor
		              ifPresent: [ :varName | "Use reflection: var contains the Constructor object"
			              self
				              makeReflectionConstructorInvocation: varName
				              for: object ]
		              ifAbsent: [ "Regular use of the constructor"
			              self
				              makeConstructorInvocation: constructor
				              for: object ].

	"Add arguments to match constructor parameters"
	constructor parameters ifNotEmpty: [
		self
			addAttributesFrom: object
			asArgumentsTo: invocation
			usingConstructor: constructor ]
]

{ #category : 'exporting' }
FamixValue2FASTJavaVisitor >> defaultHelperPackage [

	^ defaultHelperPackage ifNil: [ defaultHelperPackage := 'org.modest' ]
]

{ #category : 'exporting' }
FamixValue2FASTJavaVisitor >> defaultHelperPackage: aString [

	defaultHelperPackage := aString
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> ensureReflection [
	"Ensure that the infrastructure needed to use reflection is generated.
	A static method called `initializeReflection` is created and will be populated by calls to `ensureReflectionField:` and `ensureReflectionConstructor:`.
	To handle exceptions that can be thrown by these operations, a static initializer calls this method with a trycatch.
	Finally, the convenience methods `setField` and `instantiate` are created to handle exceptions during reflexive operations: .
	Return the statement block of `initializeReflection` for callers to populate."

	| declarations declaration initStatementBlock |
	declarations := self objectExportStrategy currentDeclarations. "does not work for inline strategy..."

	"check if already defined and return the body of initializeReflection()"
	declarations at: -3 ifPresent: [ :decl | ^ decl statementBlock ].

	"static {
		try {
			initializeReflection();
		} catch (Exception e) {
			new RuntimeException(e);
		}
	}"
	declaration := self model newInitializer isStatic: true.
	declaration cacheAt: #order put: -4.
	declarations at: -4 put: declaration.
	declaration statementBlock:
		(model newStatementBlock statements: { (model newTryCatchStatement
				  try: (model newStatementBlock statements:
							   { (model newExpressionStatement expression:
									    (model newMethodInvocation name: 'initializeReflection')) });
				  catches: { (model newCatchPartStatement
						   catchedTypes: { (model newClassTypeExpression typeName:
									    (model newTypeName name: 'Exception')) };
						   body: (model newStatementBlock statements:
									    { (model newThrowStatement expression:
											     (model newNewExpression
												      type: (model newClassTypeExpression typeName:
															       (model newTypeName name: 'RuntimeException'));
												      arguments:
													      { (model newVariableExpression name: 'e') })) });
						   parameter: (model newVariableExpression name: 'e')) }) }).

	"private static void initializeReflection() throws NoSuchFieldException, NoSuchMethodException, SecurityException {
		// fields and constructors will be obtained and set as accessible here
	}"
	declaration := model newMethodEntity name: 'initializeReflection'.
	declaration cacheAt: #order put: -3.
	declarations at: -3 put: declaration.
	declaration
		type: (model newVoidTypeExpression name: 'void');
		modifiers: {
				(model newModifier token: 'private').
				(model newModifier token: 'static') };
		throws: {
				(model newClassTypeExpression typeName:
						 (model newTypeName name: 'NoSuchFieldException')).
				(model newClassTypeExpression typeName:
						 (model newTypeName name: 'NoSuchMethodException')).
				(model newClassTypeExpression typeName:
						 (model newTypeName name: 'SecurityException')) };
		statementBlock: (initStatementBlock := model newStatementBlock).

	"public static void setField(Object object, Field field, Object value) {
		try {
			field.set(object, value);
		} catch (IllegalAccessException e) {
			throw new RuntimeException(e);
		}
	}"
	declaration := model newMethodEntity name: 'setField'.
	declaration cacheAt: #order put: -2.
	declarations at: -2 put: declaration.
	declaration
		type: (model newVoidTypeExpression name: 'void');
		parameters: {
				(model newParameter
					 variable: (model newVariableExpression name: 'object');
					 type: (model newClassTypeExpression typeName:
								  (model newTypeName name: 'Object'))).
				(model newParameter
					 variable: (model newVariableExpression name: 'field');
					 type: (model newClassTypeExpression typeName:
								  (model newTypeName name: 'Field'))).
				(model newParameter
					 variable: (model newVariableExpression name: 'value');
					 type: (model newClassTypeExpression typeName:
								  (model newTypeName name: 'Object'))) };
		modifiers: {
				(model newModifier token: 'public').
				(model newModifier token: 'static') };
		statementBlock:
			(model newStatementBlock statements: { (model newTryCatchStatement
					  try: (model newStatementBlock statements:
								   { (model newExpressionStatement expression:
										    (model newMethodInvocation
											     receiver: (model newVariableExpression name: 'field');
											     name: 'set';
											     arguments: {
													     (model newVariableExpression name: 'object').
													     (model newVariableExpression name: 'value') })) });
					  catches: { (model newCatchPartStatement
							   catchedTypes: { (model newClassTypeExpression typeName:
										    (model newTypeName name: 'IllegalAccessException')) };
							   body: (model newStatementBlock statements:
										    { (model newThrowStatement expression:
												     (model newNewExpression
													      type: (model newClassTypeExpression typeName:
																       (model newTypeName name: 'RuntimeException'));
													      arguments:
														      { (model newVariableExpression name: 'e') })) });
							   parameter: (model newVariableExpression name: 'e')) }) }).

	"private static <T> T instantiate(Constructor<T> constructor, Object... arguments) {
		T instance;
		try {
			instance = constructor.newInstance(arguments);
		} catch (Exception e) {
			throw new RuntimeException(e);
		}
		return instance;
	}"
	declaration := model newMethodEntity name: 'instantiate'.
	declaration cacheAt: #order put: -1.
	declarations at: -1 put: declaration.
	declaration
		typeParameters: { (model newTypeParameterExpression name: 'T') };
		type:
			(model newClassTypeExpression typeName:
					 (model newTypeName name: 'T'));
		parameters: {
				(model newParameter
					 variable: (model newVariableExpression name: 'constructor');
					 type: (model newClassTypeExpression
							  arguments: { (model newClassTypeExpression typeName:
										   (model newTypeName name: 'T')) };
							  typeName: (model newTypeName name: 'Constructor'))).
				(model newParameter
					 variable: (model newVariableExpression name: 'arguments');
					 type: (model newClassTypeExpression typeName:
								  (model newTypeName name: 'Object'));
					 hasVariableArguments: true) };
		modifiers: {
				(model newModifier token: 'private').
				(model newModifier token: 'static') };
		statementBlock: (model newStatementBlock statements: {
					 (model newVarDeclStatement
						  type:
							  (model newClassTypeExpression typeName:
									   (model newTypeName name: 'T'));
						  declarators: { (model newVariableDeclarator variable:
									   (model newVariableExpression name: 'instance')) }).
					 (model newTryCatchStatement
						  try: (model newStatementBlock statements:
									   { (model newExpressionStatement expression:
											    (model newAssignmentExpression
												     variable:
													     (model newVariableExpression name: 'instance');
												     expression: (model newMethodInvocation
														      receiver:
															      (model newIdentifier name: 'constructor');
														      name: 'newInstance';
														      arguments:
															      { (model newVariableExpression name: 'arguments') });
												     operator: '=')) });
						  catches: { (model newCatchPartStatement
								   catchedTypes: { (model newClassTypeExpression typeName:
											    (model newTypeName name: 'Exception')) };
								   body: (model newStatementBlock statements:
											    { (model newThrowStatement expression:
													     (model newNewExpression
														      type: (model newClassTypeExpression typeName:
																	       (model newTypeName name: 'RuntimeException'));
														      arguments:
															      { (model newVariableExpression name: 'e') })) });
								   parameter: (model newVariableExpression name: 'e')) }).
					 (model newReturnStatement expression:
						  (model newVariableExpression name: 'instance')) }).

	^ initStatementBlock
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> ensureReflectionConstructor: aFamixJavaMethod [

	| declarations initStatementBlock varName |
	declarations := self objectExportStrategy currentDeclarations.
	initStatementBlock := self ensureReflection.
	varName := aFamixJavaMethod name asUppercase.
	self reflections at: aFamixJavaMethod put: varName.

	declarations
		at: varName
		ifPresent: [ "handle naming collisions, some ideas:
				- use fully qualified type name (only when necessary?)
				- use a HashMap to store the fields based on class and attribute name"
			self shouldBeImplemented ]
		ifAbsentPut: [
			model newVarDeclStatement
				type: (model newClassTypeExpression
						 typeName: (model newTypeName name: 'Constructor');
						 arguments:
							 { (self builder referType: aFamixJavaMethod parentType) });
				modifiers: {
						(model newModifier token: 'private').
						(model newModifier token: 'static') };
				declarators: { (model newVariableDeclarator variable:
						 (model newVariableExpression name: varName)) } ].

	"add the code in `initializeReflection` to get the Field and set it as accessible:
	CLASSNAME = CLASS.class.getDeclaredConstructor(PARAMETER_CLASSES);
	CLASSNAME.setAccessible(true);"
	initStatementBlock addStatement:
		(model newExpressionStatement expression:
			 (model newAssignmentExpression
				  variable: (model newVariableExpression name: varName);
				  expression: (model newMethodInvocation
						   receiver: (model newClassProperty
								    type:
									    (self builder referType: aFamixJavaMethod parentType);
								    fieldName: 'class');
						   name: 'getDeclaredConstructor';
						   arguments:
							   (aFamixJavaMethod sortedParameters collect: [ :parameter |
								    model newClassProperty
									    type: (self builder referType: parameter declaredType);
									    fieldName: 'class' ]));
				  operator: '=')).
	initStatementBlock addStatement:
		(model newExpressionStatement expression:
			 (model newMethodInvocation
				  receiver: (model newVariableExpression name: varName);
				  name: 'setAccessible';
				  arguments: { (model newBooleanLiteral primitiveValue: 'true') }))
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> ensureReflectionField: aFamixJavaAttribute [
	"Ensure an attribute exists to hold the java.lang.reflect.Field for the given attribute."

	^ self reflections at: aFamixJavaAttribute ifAbsentPut: [
		  | declarations initStatementBlock varName |
		  declarations := self objectExportStrategy currentDeclarations.
		  initStatementBlock := self ensureReflection.
		  varName := aFamixJavaAttribute parentType name asUppercase , '_'
		             , aFamixJavaAttribute name asUppercase.

		  declarations
			  at: varName
			  ifPresent: [ "handle naming collisions, some ideas:
				- use fully qualified type name (only when necessary?)
				- use a HashMap to store the fields based on class and attribute name"
				  self shouldBeImplemented ]
			  ifAbsentPut: [
				  model newVarDeclStatement
					  type: (model newClassTypeExpression typeName:
								   (model newTypeName name: 'Field'));
					  modifiers: {
							  (model newModifier token: 'private').
							  (model newModifier token: 'static') };
					  declarators: { (model newVariableDeclarator variable:
								   (model newVariableExpression name: varName)) } ].

		  "add the code in `initializeReflection` to get the Field and set it as accessible:
		  CLASSNAME_FIELDNAME = CLASS.class.getDeclaredField(FIELDNAME);
		  CLASSNAME.setAccessible(true);"
		  initStatementBlock addStatement:
			  (model newExpressionStatement expression:
				   (model newAssignmentExpression
					    variable: (model newVariableExpression name: varName);
					    expression: (model newMethodInvocation
							     receiver: (model newClassProperty
									      type:
										      (self builder referType:
												       aFamixJavaAttribute parentType);
									      fieldName: 'class');
							     name: 'getDeclaredField';
							     arguments:
							     { (model newStringLiteral primitiveValue:
								      aFamixJavaAttribute name) });
					    operator: '=')).
		  initStatementBlock addStatement:
			  (model newExpressionStatement expression:
				   (model newMethodInvocation
					    receiver: (model newVariableExpression name: varName);
					    name: 'setAccessible';
					    arguments:
						    { (model newBooleanLiteral primitiveValue: 'true') })).
		  varName ]
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> filterAttributesToSet: attributes for: type [
	"No need to set attributes that are set in the constructor."

	| attributesToIgnore |
	"there can be more attributes to ignore in the future"
	attributesToIgnore := type entityCache
		                      at: #syntheticOuterInstance
		                      ifPresent: [ :field | { field } ]
		                      ifAbsent: [ #(  ) ].

	^ constructorCache
		  at: type
		  ifPresent: [ :constructor |
			  constructorCache
				  at: constructor
				  ifPresent: [ :constructorAttributes |
					  attributes reject: [ :attribute |
						  | codeAttribute |
						  codeAttribute := attribute attribute.
						  (constructorAttributes includes: codeAttribute) or: [
							  attributesToIgnore includes: codeAttribute ] ] ]
				  ifAbsent: [ attributes ] ]
		  ifAbsent: [ attributes ]
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> finalizeHelpers [
	"This method must be called after all of the other value exports are done."

	self objectExportStrategy makeHelpersOn: self
]

{ #category : 'private' }
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
					  ifNone: [ "fallback to using reflection with constructor with best score"
						  | constructor |
						  constructor := constructors first.
						  self ensureReflectionConstructor: constructor.
						  constructor ] ] ]
]

{ #category : 'private' }
FamixValue2FASTJavaVisitor >> findStaticAttributeMatching: object [
	"Only try to find static attributes for object composed of only primitive values, for now."

	| type staticAttributes objAttributes |
	type := object type.
	((objAttributes := object relevantAttributes) allSatisfy: [
		 :attribute | attribute value isOfPrimitiveType ]) ifFalse: [ ^ nil ].
	"eligible attributes are public, static, of the same type, and have an initializer expression; the conditions are ordered for time efficiency"
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

{ #category : 'exporting' }
FamixValue2FASTJavaVisitor >> helperPackageFor: type [
	"Most helper methods will be put in a common helper class in a default location.
	However, types with protected or package-private visibility need to be created in the same package they are declared in.
	This means a helper class should be created in the same package."

	| container |
	type isPublic ifTrue: [ ^ self defaultHelperPackage ].

	(type isProtected or: [ type isPackageVisibility ]) ifFalse: [
		FamixValueExporterError signal:
			'Cannot recreate object of private class: ' , type mooseName ].

	"requires the helper to be in the same package"
	container := type.
	[ (container := container typeContainer) isPackage ] whileFalse.
	^ container mooseName
]

{ #category : 'initialization' }
FamixValue2FASTJavaVisitor >> initialize [

	constructorCache := IdentityDictionary new.
	staticAttributesCache := IdentityDictionary new
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeClassTypeExpression: typeName [

	^ self model newClassTypeExpression typeName:
		  (model newTypeName name: typeName)
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeConstructorInvocation: constructor for: object [
	"Make the statement calling the constructor and return the invocation expression."

	| invocation statement |
	statement := self makeVarDeclStatement: object.
	invocation := statement declarators first expression.

	"If the object is a non-static inner class, it has a reference to its enclosing instance.
	It must be exported beforehand, and it must be the receiver of the invocation."
	object type cacheAt: #syntheticOuterInstance ifPresent: [ :field |
		| outerInstance |
		outerInstance := object value detect: [ :attribute |
			                 attribute attribute == field ].
		self ensureVisited: outerInstance value.
		invocation receiver: (self objectExportStrategy
				 makeVariableExpression: outerInstance
				 on: self) ].

	"handle exceptions thrown by the constructor and rethrow as an unchecked RuntimeException"
	constructor thrownExceptions ifNotEmpty: [ :exceptions |
		statement := self makeTry: statement catch: exceptions ].

	self statementBlock addStatement: statement.
	^ invocation
]

{ #category : 'helpers' }
FamixValue2FASTJavaVisitor >> makeDefaultHelper [
	"The default helper should always be generated, regardless of strategy."

	self makeHelperInPackage: self defaultHelperPackage
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeHelperClass [
	"The helper class should not be instantiated so it has a private constructor."

	^ self model newClassDeclaration
		  name: 'ModestHelper';
		  addModifier: (model newModifier token: 'public');
		  addDeclaration: (model newMethodEntity
				   name: 'ModestHelper';
				   addModifier: (model newModifier token: 'private');
				   statementBlock: model newStatementBlock);
		  yourself
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeHelperInPackage: aPackageName [

	| helperClass compilationUnit |
	helperClass := self makeHelperClass.
	(compilationUnit := self model newCompilationUnit)
		packageDeclaration: (model newPackageDeclaration qualifiedName:
					 (model newQualifiedName name: aPackageName));
		importDeclarations: self builder makeImportDeclarations;
		addClassDeclaration: helperClass.

	reflections ifNotNil: [ "TODO reflections per package"
		compilationUnit
			addImportDeclaration: (model newImportDeclaration qualifiedName:
						 (model newQualifiedName name: 'java.lang.reflect.Field'));
			addImportDeclaration: (model newImportDeclaration qualifiedName:
						 (model newQualifiedName name: 'java.lang.reflect.Constructor'));
			addImportDeclaration: (model newImportDeclaration qualifiedName:
						 (model newQualifiedName name:
								  'java.lang.reflect.InvocationTargetException')) ].

	^ helperClass
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeNewExpression: object [

	^ self model newNewExpression type:
		  (object asFASTJavaTypeExpressionOn: self)
	"(self makeClassTypeExpression: object type concreteTypeName)"
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeReflectionConstructorInvocation: constructorVarName for: object [
	"Use `T instantiate(Constructor<T> constructor, Object... arguments)` from the UT helper.
	constructorVarName is the name of the variable that contains the Constructor object."

	| invocation |
	(invocation := model newMethodInvocation name: 'instantiate')
		addArgument: (model newVariableExpression name: constructorVarName).

	"If the object is a non-static inner class, it has a reference to its enclosing instance.
	It must be exported beforehand, and it must be the first argument of the invocation."
	object type cacheAt: #syntheticOuterInstance ifPresent: [ :field |
		| outerInstance |
		outerInstance := object value detect: [ :attribute |
			                 attribute attribute == field ].
		self ensureVisited: outerInstance value.
		invocation addArgument: (self objectExportStrategy
				 makeVariableExpression: outerInstance
				 on: self) ].

	"invoke the method and store the result in a variable"
	(self statementBlock addStatement: self model newVarDeclStatement)
		type: (self builder referType: object type);
		addDeclarator: (model newVariableDeclarator
				 variable: (self makeVariableExpression: object);
				 expression: invocation).
	^ invocation
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeReflectionFieldGetter: attribute [

	^ self model newMethodInvocation
		  receiver: (model newClassProperty
				   type:
					   (self makeClassTypeExpression: attribute object type typeName);
				   fieldName: 'class');
		  name: 'getDeclaredField';
		  addArgument:
		  (model newStringLiteral primitiveValue: attribute attribute name);
		  yourself
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeReflectionSetterInvocation: attribute [
	"Use reflection to set an attribute on an object."

	| fieldName |
	fieldName := self ensureReflectionField: attribute attribute.
	self statementBlock addStatement:
		(self model newExpressionStatement expression:
			 (model newMethodInvocation
				  name: 'setField';
				  arguments: {
						  (self makeVariableExpression: attribute object).
						  (model newVariableExpression name: fieldName).
						  (model newVariableExpression name: attribute value varName) }))
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeSetterInvocation: setter for: attribute [

	self
		makeSetterInvocation: setter
		for: attribute
		named: (self varNameFor: attribute value)
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeSetterInvocation: setter for: attribute named: aString [

	| invocation |
	(invocation := self model newExpressionStatement) expression:
		(model newMethodInvocation
			 receiver: (self makeVariableExpression: attribute object);
			 name: setter name;
			 addArgument: (model newVariableExpression name: aString);
			 famixMethod: setter).

	self statementBlock addStatement: (setter thrownExceptions
			 ifEmpty: [ invocation ]
			 ifNotEmpty: [ :exceptions | "handle setters that can throw exceptions to rethrow an unchecked exception"
				 self makeTry: invocation catch: exceptions ])
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeTry: statement catch: exceptions [
	"Wrap the statement in a try-catch for the given exceptions, and rethrow as an unchecked RuntimeException."

	^ self model newTryCatchStatement
		  try: (model newStatementBlock
				   addStatement: statement;
				   yourself);
		  addCatch: (model newCatchPartStatement
				   catchedTypes: (exceptions collect: [ :exception |
							    exception asFASTJavaTypeExpressionOn: self ]);
				   parameter: (model newVariableExpression name: 'e');
				   body: (model newStatementBlock
						    addStatement:
							    (model newThrowStatement expression:
									     (model newNewExpression
										      type: (model newClassTypeExpression typeName:
													       (model newTypeName name: 'RuntimeException'));
										      addArgument: (model newVariableExpression name: 'e');
										      yourself));
						    yourself));
		  yourself
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeVarDeclStatement: value [

	^ self model newVarDeclStatement
		  type: (value asFASTJavaTypeExpressionOn: self);
		  addDeclarator: (self makeVariableDeclarator: value);
		  yourself
]

{ #category : 'ast' }
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

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeVariableDeclarator: value [

	^ self model newVariableDeclarator
		  variable: (self makeVariableExpression: value);
		  expression: (value asFASTJavaExpressionOn: self)
]

{ #category : 'ast' }
FamixValue2FASTJavaVisitor >> makeVariableExpression: value [

	^ self model newVariableExpression name: (self varNameFor: value)
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> model [

	^ model ifNil: [ model := FASTJavaModel new ]
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> objectExportStrategy [

	^ objectExportStrategy ifNil: [
		  objectExportStrategy := FamixValueInlineObjectExportStrategy new ]
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> objectExportStrategy: anObjectExportStrategy [

	objectExportStrategy := anObjectExportStrategy
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> reflections [

	^ reflections ifNil: [ reflections := IdentityDictionary new ]
]

{ #category : 'accessing' }
FamixValue2FASTJavaVisitor >> statementBlock [

	^ statementBlock ifNil: [
		  statementBlock := self model newStatementBlock ]
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitCollection: collection [
	"Dispatch to type to handle special cases"

	^ collection type acceptValueVisitor: self forCollection: collection
]

{ #category : 'visiting' }
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

{ #category : 'visiting' }
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

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitEnumValue: enumValue [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: enumValue);
		  yourself
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitObject: object [
	"Dispatch to type to handle special cases"

	^ object type acceptValueVisitor: self forObject: object
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitObjectAttribute: attribute [

	attribute attribute ifNil: [ "ignore unknown attributes" ^ self ].
	self ensureVisited: attribute value.
	(attribute object type findSetterOf: attribute attribute)
		ifNotNil: [ :setter | self makeSetterInvocation: setter for: attribute ]
		ifNil: [ self makeReflectionSetterInvocation: attribute ]
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitObjectOfRegularType: object [
	"Dispatched here from #visitObject: if the object has a regular creation schema:
	use constructor, then setup each attribute and use setter or reflection."

	(self findStaticAttributeMatching: object)
		ifNotNil: [ :attribute |
			self makeVarDeclStatement: object usingStaticAttribute: attribute ]
		ifNil: [ self objectExportStrategy export: object on: self ].
	^ statementBlock
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitObjectStub: object [
	"Previously tried to recreate stubs by deserializing their JSON representation, but getting a correct JSON string is a challenge."

	FamixUTStubError signal: object type
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitPrimitive: primitive [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: primitive);
		  yourself
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitTypeReference: aFamixValueOfTypeReference [
	"Class xxx = MyClass.class;"

	^ self statementBlock
		  addStatement: (model newVarDeclStatement
				   type: (self makeClassTypeExpression: 'Class');
				   addDeclarator: (model newVariableDeclarator
						    variable:
							    (self makeVariableExpression: aFamixValueOfTypeReference);
						    expression: (model newClassProperty
								     type:
									     (self makeClassTypeExpression:
											      aFamixValueOfTypeReference value name);
								     fieldName: 'class'));
				   yourself);
		  yourself
]

{ #category : 'visiting' }
FamixValue2FASTJavaVisitor >> visitValueOfUnknownType: value [

	^ self statementBlock
		  addStatement: (self makeVarDeclStatement: value);
		  yourself
]
