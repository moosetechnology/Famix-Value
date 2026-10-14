Class {
	#name : 'FamixValueJavaInitializerInfo',
	#superclass : 'FamixValueJavaMemberInfo',
	#instVars : [
		'fastInitializer'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaInitializerInfo >> fastInitializer [

	^ fastInitializer
]

{ #category : 'accessing' }
FamixValueJavaInitializerInfo >> fastInitializer: anInitializer [

	fastInitializer := anInitializer
]

{ #category : 'testing' }
FamixValueJavaInitializerInfo >> isInitializer [

	^ true
]

{ #category : 'testing' }
FamixValueJavaInitializerInfo >> isStatic [

	^ fastInitializer isStatic
]
