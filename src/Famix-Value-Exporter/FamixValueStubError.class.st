Class {
	#name : 'FamixValueStubError',
	#superclass : 'FamixValueExporterError',
	#category : 'Famix-Value-Exporter-Exceptions',
	#package : 'Famix-Value-Exporter',
	#tag : 'Exceptions'
}

{ #category : 'exceptioninstantiator' }
FamixValueStubError class >> signalFor: aFamixType [

	^ self signal:
		  'Type Missing from code model: ' , aFamixType mooseName
]
