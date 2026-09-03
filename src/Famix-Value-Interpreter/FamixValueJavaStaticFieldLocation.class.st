Class {
	#name : 'FamixValueJavaStaticFieldLocation',
	#superclass : 'FamixValueInterpreterLocation',
	#instVars : [
		'runtimeType',
		'fieldInfo'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaStaticFieldLocation >> fieldInfo [

	^ fieldInfo
]

{ #category : 'accessing' }
FamixValueJavaStaticFieldLocation >> fieldInfo: aFieldInfo [

	fieldInfo := aFieldInfo
]

{ #category : 'accessing' }
FamixValueJavaStaticFieldLocation >> runtimeType [

	^ runtimeType
]

{ #category : 'accessing' }
FamixValueJavaStaticFieldLocation >> runtimeType: aRuntimeType [

	runtimeType := aRuntimeType
]

{ #category : 'accessing' }
FamixValueJavaStaticFieldLocation >> type [

	^ fieldInfo type
]

{ #category : 'evaluating' }
FamixValueJavaStaticFieldLocation >> value [

	^ runtimeType staticValueOf: fieldInfo
]

{ #category : 'evaluating' }
FamixValueJavaStaticFieldLocation >> value: value [

	^ runtimeType staticValueOf: fieldInfo put: value
]
