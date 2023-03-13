"
A FamixValue2FASTJavaVisitorTest is a test class for testing the behavior of FamixValue2FASTJavaVisitor
"
Class {
	#name : #FamixValue2FASTJavaVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'intPrimitive',
		'boolPrimitive',
		'stringPrimitive',
		'collection',
		'dictionary',
		'object',
		'dictAssoc1',
		'attribute',
		'nullString',
		'enumValue'
	],
	#category : #'Famix-Value-Exporter-Tests'
}

{ #category : #running }
FamixValue2FASTJavaVisitorTest >> setUp [

	super setUp.

	intPrimitive := FamixValueOfPrimitiveType new
		                value: 1;
		                type: (FamixJavaPrimitiveType new name: 'int').
	boolPrimitive := FamixValueOfPrimitiveType new
		                 value: true;
		                 type: (FamixJavaPrimitiveType new name: 'boolean').
	stringPrimitive := FamixValueOfPrimitiveType new
		                   value: 'hello';
		                   type: (FamixJavaClass new name: 'String').
	nullString := FamixValueOfUnknownType new
		              value: nil;
		              type: (FamixJavaClass new name: 'String').
	collection := FamixValueOfCollection new type:
		              (FamixJavaParameterizedType new
			               parameterizableClass:
				               (FamixJavaParameterizableClass new name:
						                'ArrayList');
			               addArgument: (FamixJavaClass new name: 'String');
			               yourself).
	dictionary := FamixValueOfDictionary new type:
		              (FamixJavaClass new name: 'HashMap').
	dictAssoc1 := FamixValueOfDictionaryAssociation new
		              key: stringPrimitive;
		              value: intPrimitive.
	"Class with a method that answers true to isSetter. FamixValue and FamixJava are not linked yet, they will be in the test."
	object := FamixValueOfObject new
		          type: (FamixJavaClass new
				           name: 'MyClass';
				           addAttribute: (FamixJavaAttribute new name: 'foo');
				           addMethod: (FamixJavaMethod new
						            name: 'setFoo';
						            declaredType: (FamixJavaType new name: 'void');
						            parameters: { FamixJavaParameter new }));
		          yourself.

	enumValue := FamixValueOfEnum new
		             value: (FamixJavaEnumValue new name: 'ENUM_VALUE');
		             type: (FamixJavaEnum new name: 'MyEnum')
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitCollection [

	self assert: collection asJavaSourceCode equals: '{
  ArrayList<String> arrayList0 = new ArrayList<String>();
}'.

	collection addValue: stringPrimitive.
	self assert: collection asJavaSourceCode equals: '{
  ArrayList<String> arrayList0 = new ArrayList<String>();
  String string1 = "hello";
  arrayList0.add(string1);
}'.

	collection addValue: nullString.
	self assert: collection asJavaSourceCode equals: '{
  ArrayList<String> arrayList0 = new ArrayList<String>();
  String string1 = "hello";
  arrayList0.add(string1);
  String string2 = null;
  arrayList0.add(string2);
}'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitDictionary [

	self assert: dictionary asJavaSourceCode equals: '{
  HashMap hashMap0 = new HashMap();
}'.

	dictionary addValue: dictAssoc1.
	self assert: dictionary asJavaSourceCode equals: '{
  HashMap hashMap0 = new HashMap();
  String string1 = "hello";
  int int2 = 1;
  hashMap0.put(string1, int2);
}'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitEnumValue [

	self assert: enumValue asJavaSourceCode equals: '{
  MyEnum myEnum0 = MyEnum.ENUM_VALUE;
}'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitObject [

	"no attributes"

	self assert: object asJavaSourceCode equals: '{
  MyClass myClass0 = new MyClass();
}'.

	"with an attribute"
	object addValue: boolPrimitive.
	boolPrimitive typedEntity: object type attributes first.
	self assert: object asJavaSourceCode equals: '{
  MyClass myClass0 = new MyClass();
  boolean foo1 = true;
  myClass0.setFoo(foo1);
}'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitPrimitive [

	self assert: intPrimitive asJavaSourceCode equals: '{
  int int0 = 1;
}'.
	self assert: boolPrimitive asJavaSourceCode equals: '{
  boolean boolean0 = true;
}'.
	self assert: stringPrimitive asJavaSourceCode equals: '{
  String string0 = "hello";
}'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitValueOfUnknownType [

	self assert: nullString asJavaSourceCode equals: '{
  String string0 = null;
}'
]
