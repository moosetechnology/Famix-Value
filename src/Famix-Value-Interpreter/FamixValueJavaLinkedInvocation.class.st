Class {
	#name : 'FamixValueJavaLinkedInvocation',
	#superclass : 'Object',
	#instVars : [
		'method',
		'mode'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'accessing' }
FamixValueJavaLinkedInvocation >> method [

	^ method
]

{ #category : 'accessing' }
FamixValueJavaLinkedInvocation >> method: aMethodInfo [

	method := aMethodInfo
]

{ #category : 'accessing' }
FamixValueJavaLinkedInvocation >> mode [

	^ mode
]

{ #category : 'accessing' }
FamixValueJavaLinkedInvocation >> mode: aSymbol [

	mode := aSymbol
]
