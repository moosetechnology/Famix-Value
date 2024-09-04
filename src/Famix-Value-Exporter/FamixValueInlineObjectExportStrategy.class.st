"
I recreate objects inline.
The context of the visitor will contain the code to recreate the objects.
"
Class {
	#name : 'FamixValueInlineObjectExportStrategy',
	#superclass : 'FamixValueAbstractObjectExportStrategy',
	#category : 'Famix-Value-Exporter-Strategies',
	#package : 'Famix-Value-Exporter',
	#tag : 'Strategies'
}

{ #category : 'exporting' }
FamixValueInlineObjectExportStrategy >> export: object on: visitor [

	visitor constructObject: object.
	(visitor filterAttributesToSet: object relevantAttributes for: object)
		do: [ :attribute | visitor visitObjectAttribute: attribute ]
]

{ #category : 'ast' }
FamixValueInlineObjectExportStrategy >> makeVariableExpression: value on: visitor [
	"Used when constructing an object to correctly name the argument variable.
	When inline, the visitor can handle naming the variable on its own."

	^ visitor makeVariableExpression: value
]
