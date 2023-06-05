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
		'nullString'
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
		              type: (FamixJavaClass new name: 'String')
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitCollection [

	| collection |
	collection := FamixValueOfCollection new type:
		              (FamixJavaParameterizedType new
			               parameterizableClass:
				               (FamixJavaParameterizableClass new name: 'List');
			               arguments: { (FamixJavaClass new name: 'String') }).

	self assert: collection asJavaSourceCode equals: '{
  List<String> list0 = new ArrayList<String>();
}
'.

	collection addValue:
		(FamixValueOfCollectionElement new value: stringPrimitive).
	self assert: collection asJavaSourceCode equals: '{
  List<String> list0 = new ArrayList<String>();
  String string1 = "hello";
  list0.add(string1);
}
'.

	collection addValue:
		(FamixValueOfCollectionElement new value: nullString).
	self assert: collection asJavaSourceCode equals: '{
  List<String> list0 = new ArrayList<String>();
  String string1 = "hello";
  list0.add(string1);
  String string2 = null;
  list0.add(string2);
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitDictionary [

	| dictionary |
	dictionary := FamixValueOfDictionary new type:
		              (FamixJavaParameterizedType new
			               parameterizableClass:
				               (FamixJavaParameterizableClass new name: 'Map');
			               arguments: { (FamixJavaClass new name: 'Object') }).
	self assert: dictionary asJavaSourceCode equals: '{
  Map<Object, Object> map0 = new HashMap<Object, Object>();
}
'.

	dictionary addValue: (FamixValueOfDictionaryAssociation new
			 key: stringPrimitive;
			 value: intPrimitive).
	self assert: dictionary asJavaSourceCode equals: '{
  Map<Object, Object> map0 = new HashMap<Object, Object>();
  String string1 = "hello";
  int int2 = 1;
  map0.put(string1, int2);
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitEnumValue [

	| enumValue |
	enumValue := FamixValueOfEnum new
		             value: (FamixJavaEnumValue new name: 'ENUM_VALUE');
		             type: (FamixJavaEnum new name: 'MyEnum').

	self assert: enumValue asJavaSourceCode equals: '{
  MyEnum myEnum0 = MyEnum.ENUM_VALUE;
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitObject [

	| object |
	"Class with a method that answers true to isSetter."
	object := FamixValueOfObject new
		          type: (FamixJavaClass new
				           name: 'MyClass';
				           addAttribute: (FamixJavaAttribute new name: 'foo');
				           addMethod: (FamixJavaMethod new
						            name: 'setFoo';
						            declaredType: (FamixJavaType new name: 'void');
						            parameters: { FamixJavaParameter new }));
		          yourself.

	"no attributes"
	self assert: object asJavaSourceCode equals: '{
  MyClass myClass0 = new MyClass();
}
'.

	"with an attribute"
	object addValue:
		(FamixValueOfObjectAttribute new value: boolPrimitive).
	boolPrimitive typedEntity: object type attributes first.
	self assert: object asJavaSourceCode equals: '{
  MyClass myClass0 = new MyClass();
  boolean foo1 = true;
  myClass0.setFoo(foo1);
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitPrimitive [

	self assert: intPrimitive asJavaSourceCode equals: '{
  int int0 = 1;
}
'.
	self assert: boolPrimitive asJavaSourceCode equals: '{
  boolean boolean0 = true;
}
'.
	self assert: stringPrimitive asJavaSourceCode equals: '{
  String string0 = "hello";
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitValueOfUnknownType [

	self assert: nullString asJavaSourceCode equals: '{
  String string0 = null;
}
'
]
