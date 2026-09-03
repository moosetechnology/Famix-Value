Class {
	#name : 'FamixValueJavaRuntimeType',
	#superclass : 'Object',
	#instVars : [
		'typeInfo',
		'initializationState',
		'staticFields'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueJavaRuntimeType class >> of: aTypeInfo [

	^ self new typeInfo: aTypeInfo
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> initializationState [

	^ initializationState
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> initializationState: aSymbol [

	initializationState := aSymbol
]

{ #category : 'initialization' }
FamixValueJavaRuntimeType >> initialize [

	initializationState := #uninitialized.
	staticFields := IdentityDictionary new
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> staticValueOf: fieldInfo [

	^ staticFields at: fieldInfo
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> staticValueOf: fieldInfo put: value [

	^ staticFields at: fieldInfo put: value
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> typeInfo [

	^ typeInfo
]

{ #category : 'accessing' }
FamixValueJavaRuntimeType >> typeInfo: aTypeInfo [

	typeInfo := aTypeInfo
]
