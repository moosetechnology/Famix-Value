Class {
	#name : 'FamixValueInterpreter',
	#superclass : 'Object',
	#instVars : [
		'model',
		'entityFinder',
		'frames',
		'globals'
	],
	#category : 'Famix-Value-Interpreter',
	#package : 'Famix-Value-Interpreter'
}

{ #category : 'instance creation' }
FamixValueInterpreter class >> entityFinderClass [

	^ FamixEntityFinder
]

{ #category : 'instance creation' }
FamixValueInterpreter class >> on: aFamixModel [

	^ self new entityFinder: ((self entityFinderClass on: aFamixModel)
			   createNotFound: false;
			   signalNotFound: false)
]

{ #category : 'accessing' }
FamixValueInterpreter >> entityFinder [

	^ entityFinder ifNil: [
		  entityFinder := self class entityFinderClass new
			                  createNotFound: false;
			                  signalNotFound: false ]
]

{ #category : 'accessing' }
FamixValueInterpreter >> entityFinder: anEntityFinder [

	entityFinder := anEntityFinder
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: executable [

	^ self execute: executable on: nil with: #(  )
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: executable on: receiver with: arguments [

	self subclassResponsibility
]

{ #category : 'invoking' }
FamixValueInterpreter >> execute: executable with: arguments [

	^ self execute: executable on: nil with: arguments
]

{ #category : 'accessing' }
FamixValueInterpreter >> frame [

	^ frames top
]

{ #category : 'scoping' }
FamixValueInterpreter >> inFrame: aFrame do: aBlock [

	frames push: aFrame.
	^ [ aBlock value ] ensure: [ frames pop ]
]

{ #category : 'scoping' }
FamixValueInterpreter >> inScopeDo: aBlock [

	self frame pushScope.
	^ [ aBlock value ] ensure: [ self frame popScope ]
]

{ #category : 'initialization' }
FamixValueInterpreter >> initialize [

	super initialize.
	frames := Stack new
]

{ #category : 'resolving' }
FamixValueInterpreter >> locationOf: anExpression [

	self subclassResponsibility
]

{ #category : 'accessing' }
FamixValueInterpreter >> model [

	^ model ifNil: [ model := FamixValueModel new ]
]

{ #category : 'accessing' }
FamixValueInterpreter >> model: aFamixValueModel [

	model := aFamixValueModel
]

{ #category : 'resolving' }
FamixValueInterpreter >> unsupportedLocationOf: anExpression [

	^ FamixValueInterpreterInvalidLocation signalFor: anExpression
]
