Class {
	#name : #FamixValueInlineObjectExportStrategy,
	#superclass : #FamixValueAbstractObjectExportStrategy,
	#category : #'Famix-Value-Exporter-Strategies'
}

{ #category : #exporting }
FamixValueInlineObjectExportStrategy >> export: object on: visitor [

	visitor constructObject: object.
	(visitor filterAttributesToSet: object relevantAttributes for: object)
		do: [ :attribute | visitor visitObjectAttribute: attribute ]
]
