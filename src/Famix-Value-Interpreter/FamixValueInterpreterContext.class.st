Class {
	#name : #FamixValueInterpreterContext,
	#superclass : #Object,
	#instVars : [
		'bindings',
		'parentContext'
	],
	#category : #'Famix-Value-Interpreter'
}

{ #category : #binding }
FamixValueInterpreterContext >> bind: varName to: value [

	^ bindings at: varName put: value
]

{ #category : #initialization }
FamixValueInterpreterContext >> initialize [

	bindings := Dictionary new
]

{ #category : #accessing }
FamixValueInterpreterContext >> parentContext [

	^ parentContext
]

{ #category : #accessing }
FamixValueInterpreterContext >> parentContext: context [

	parentContext := context
]

{ #category : #binding }
FamixValueInterpreterContext >> resolve: identifier [
	"Can reference a local variable or an attribute."

	^ bindings at: identifier ifAbsent: [
		  parentContext
			  ifNotNil: [ parentContext resolve: identifier ]
			  ifNil: [ self halt. "what could it be?" ] ]
]
