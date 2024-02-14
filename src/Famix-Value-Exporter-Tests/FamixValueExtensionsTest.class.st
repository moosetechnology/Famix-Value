Class {
	#name : #FamixValueExtensionsTest,
	#superclass : #TestCase,
	#category : #'Famix-Value-Exporter-Tests'
}

{ #category : #tests }
FamixValueExtensionsTest >> test_FamixTParametricEntity_keyType [

	| string integer |
	string := FamixJavaClass named: 'String'.
	integer := FamixJavaClass named: 'Integer'.

	self
		assert: (FamixJavaParametricClass new concreteParameters: {
					 string.
					 integer }) keyType
		equals: string.
	self
		assert: (FamixJavaParametricClass new concreteParameters: {
					 integer.
					 string }) keyType
		equals: integer.
	self
		assert:
		(FamixJavaParametricClass new concreteParameters: { string })
			keyType
		equals: string
]

{ #category : #tests }
FamixValueExtensionsTest >> test_FamixTParametricEntity_typeName [

	| map string integer |
	map := FamixJavaParametricClass named: 'Map'.
	string := FamixJavaClass named: 'String'.
	integer := FamixJavaClass named: 'Integer'.

	self
		assert: (map concreteParameters: {
					 string.
					 integer }) typeName
		equals: 'Map<String, Integer>'.
	self
		assert: (map concreteParameters: {
					 integer.
					 string }) typeName
		equals: 'Map<Integer, String>'.
	self
		assert: (map concreteParameters: { string }) typeName
		equals: 'Map<String, String>'
]

{ #category : #tests }
FamixValueExtensionsTest >> test_FamixTParametricEntity_valueType [

	| string integer |
	string := FamixJavaClass named: 'String'.
	integer := FamixJavaClass named: 'Integer'.

	self
		assert: (FamixJavaParametricClass new concreteParameters: {
					 string.
					 integer }) valueType
		equals: integer.
	self
		assert: (FamixJavaParametricClass new concreteParameters: {
					 integer.
					 string }) valueType
		equals: string.
	self
		assert:
			(FamixJavaParametricClass new concreteParameters: { string })
				valueType
		equals: string
]

{ #category : #tests }
FamixValueExtensionsTest >> test_String_splitJavaArguments [

	self assert: '' splitJavaArguments equals: {  }.
	self
		assert: 'true' splitJavaArguments
		equals: (OrderedCollection with: 'true').
	self
		assert: '0, 1' splitJavaArguments
		equals: (OrderedCollection with: '0' with: '1').
	self
		assert: '"hello, world"' splitJavaArguments
		equals: (OrderedCollection with: '"hello, world"').
	self
		assert: '"\\\",",42 ,''\\''' splitJavaArguments
		equals:
		(OrderedCollection with: '"\\\","' with: '42' with: '''\\''')
]
