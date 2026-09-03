Class {
	#name : 'FamixValueJavaSourceDirectoryTest',
	#superclass : 'TestCase',
	#category : 'Famix-Value-Interpreter-Tests',
	#package : 'Famix-Value-Interpreter-Tests'
}

{ #category : 'tests' }
FamixValueJavaSourceDirectoryTest >> testSourceDirectoryMapsQualifiedNameToFile [

	| source |
	source := FamixValueJavaSourceDirectory on:
		          FileLocator temp / 'FamixValueInterpreter' / 'src'
		          / 'main' / 'java'.

	self
		assert: (source fileForTypeNamed: 'com.example.Foo') pathString
		equals:
			(FileLocator temp / 'FamixValueInterpreter' / 'src' / 'main'
			 / 'java' / 'com' / 'example' / 'Foo.java') pathString
]
