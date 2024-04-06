Class {
	#name : #FamixValueObjectInlineExportStrategy,
	#superclass : #FamixValueObjectExportStrategy,
	#category : #'Famix-Value-Exporter-Strategies'
}

{ #category : #exporting }
FamixValueObjectInlineExportStrategy >> export: object on: visitor [

	self flag: #TODO. "redo object visit, we need to have attributes ready when calling the constructor.
	We need to know if an attribute has been set using the constructor or if it will be set using a setter!"
	visitor constructObject: object.
	object relevantAttributes do: [ :attribute |
		visitor visitObjectAttribute: attribute ]
]
