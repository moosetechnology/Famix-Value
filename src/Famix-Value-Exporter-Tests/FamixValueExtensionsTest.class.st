Class {
	#name : #FamixValueExtensionsTest,
	#superclass : #TestCase,
	#category : #'Famix-Value-Exporter-Tests'
}

{ #category : #tests }
FamixValueExtensionsTest >> testSplitJavaArguments [

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
