Class {
	#name : 'FamixValueJavaClassInfoTest',
	#superclass : 'TestCase',
	#category : 'Famix-Value-Interpreter-Tests',
	#package : 'Famix-Value-Interpreter-Tests'
}

{ #category : 'tests' }
FamixValueJavaClassInfoTest >> testClassInfoHasSimpleAndQualifiedName [

	| classInfo |
	classInfo := FamixValueJavaClassInfo named: 'foo.bar.Test'.

	self assert: classInfo name equals: 'Test'.
	self assert: classInfo qualifiedName equals: 'foo.bar.Test'
]
