"
A FamixValue2FASTJavaVisitorTest is a test class for testing the behavior of FamixValue2FASTJavaVisitor
"
Class {
	#name : #FamixValue2FASTJavaVisitorTest,
	#superclass : #TestCase,
	#instVars : [
		'arrayList',
		'stringType',
		'intPrimitive',
		'boolPrimitive',
		'stringPrimitive',
		'nullString'
	],
	#category : #'Famix-Value-Exporter-Tests'
}

{ #category : #running }
FamixValue2FASTJavaVisitorTest >> setUp [

	| langPackage utilPackage |
	super setUp.
	(FamixJavaPackage new name: 'java') childEntities: {
			(langPackage := FamixJavaPackage named: 'lang').
			(utilPackage := FamixJavaPackage named: 'util') }.
	arrayList := FamixJavaParametricClass new
		             name: 'ArrayList';
		             typeContainer: utilPackage.
	stringType := FamixJavaClass new
		              name: 'String';
		              typeContainer: langPackage.
	intPrimitive := FamixValueOfPrimitiveType new
		                value: 1;
		                type: (FamixJavaPrimitiveType new name: 'int').
	boolPrimitive := FamixValueOfPrimitiveType new
		                 value: true;
		                 type: (FamixJavaPrimitiveType new name: 'boolean').
	stringPrimitive := FamixValueOfPrimitiveType new
		                   value: 'hello';
		                   type: stringType.
	nullString := FamixValueOfUnknownType new
		              value: nil;
		              type: stringType
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitCollection [

	| collection |
	collection := FamixValueOfCollection new type:
		              (FamixJavaParametricClass new
			               name: 'ArrayList';
			               genericization:
				               (FamixJavaConcretization new genericEntity:
						                (FamixJavaParametricClass named: 'ArrayList'));
			               concreteParameters: { stringType }).

	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
}
'.

	collection addValue:
		(FamixValueOfCollectionElement new value: stringPrimitive).
	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
  String string1 = "hello";
  arrayList0.add(string1);
}
'.

	collection addValue:
		(FamixValueOfCollectionElement new value: nullString).
	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
  String string1 = "hello";
  arrayList0.add(string1);
  String string2 = null;
  arrayList0.add(string2);
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitDeepCollection [

	| object collection element |
	object := FamixJavaParametricClass named: 'Object'.
	collection := FamixValueOfCollection new type:
		              (FamixJavaParametricClass new
			               name: 'ArrayList';
			               genericization:
				               (FamixJavaConcretization new genericEntity:
						                arrayList);
			               concreteParameters:
				               { (FamixJavaParametricInterface new
					                name: 'List';
					                genericization:
						                (FamixJavaConcretization new genericEntity:
								                 (FamixJavaParametricInterface named: 'List'));
					                concreteParameters: { object }) }).
	element := FamixValueOfCollection new type:
		           (FamixJavaParametricClass new
			            name: 'ArrayList';
			            genericization:
				            (FamixJavaConcretization new genericEntity: arrayList);
			            concreteParameters: { object }).

	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
}
'.

	collection addValue:
		(FamixValueOfCollectionElement new value: element).
	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
  ArrayList arrayList1 = new ArrayList();
  arrayList0.add(arrayList1);
}
'.

	element addValue:
		(FamixValueOfCollectionElement new value: nullString).
	self assert: collection asJavaSourceCode equals: '{
  ArrayList arrayList0 = new ArrayList();
  ArrayList arrayList1 = new ArrayList();
  String string2 = null;
  arrayList1.add(string2);
  arrayList0.add(arrayList1);
}
'
]

{ #category : #tests }
FamixValue2FASTJavaVisitorTest >> testVisitDictionary [

	| dictionary |
	dictionary := FamixValueOfDictionary new type:
		              (FamixJavaParametricClass new
			               name: 'HashMap';
			               genericization:
				               (FamixJavaConcretization new genericEntity:
						                (FamixJavaParametricClass named: 'HashMap'));
			               concreteParameters:
				               { (FamixJavaClass named: 'Object') }).

	self assert: dictionary asJavaSourceCode equals: '{
  HashMap hashMap0 = new HashMap();
}
'.

	dictionary addValue: (FamixValueOfDictionaryAssociation new
			 key: stringPrimitive;
			 value: intPrimitive).
	self assert: dictionary asJavaSourceCode equals: '{
  HashMap hashMap0 = new HashMap();
  String string1 = "hello";
  int int2 = 1;
  hashMap0.put(string1, int2);
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

	| object attribute |
	"Class with a method that answers true to isSetter."
	object := FamixValueOfObject new
		          type: (FamixJavaClass new
				           name: 'MyClass';
				           addAttribute:
					           (attribute := FamixJavaAttribute new name: 'foo');
				           addMethod: (FamixJavaMethod new
						            name: 'setFoo';
						            declaredType: (FamixJavaType new name: 'void');
						            parameters: { FamixJavaParameter new };
						            accesses:
							            { (FamixJavaAccess new variable: attribute) }));
		          yourself.

	"no attributes"
	self assert: object asJavaSourceCode equals: '{
  MyClass myClass0 = new MyClass();
}
'.

	"with an attribute"
	object addValue: (FamixValueOfObjectAttribute new
			 value: boolPrimitive;
			 attribute: object type attributes first).
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
'.
	"number primitives"
	self
		assert: (FamixValueOfPrimitiveType new
				 value: 1;
				 type: (FamixJavaPrimitiveType new name: 'long')) asJavaSourceCode
		equals: '{
  long long0 = 1L;
}
'.
	self
		assert: (FamixValueOfPrimitiveType new
				 value: 1.0;
				 type: (FamixJavaPrimitiveType new name: 'double'))
				asJavaSourceCode
		equals: '{
  double double0 = 1.0;
}
'.
	self
		assert: (FamixValueOfPrimitiveType new
				 value: 1.0;
				 type: (FamixJavaPrimitiveType new name: 'float'))
				asJavaSourceCode
		equals: '{
  float float0 = 1.0f;
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
