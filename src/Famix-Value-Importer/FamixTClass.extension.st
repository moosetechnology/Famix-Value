Extension { #name : #FamixTClass }

{ #category : #'*Famix-Value-Importer' }
FamixTClass >> findAttributeNamed: attributeName [

	^ self attributes
		  detect: [ :attr | attr name = attributeName ]
		  ifNone: [
			  self inheritedAttributes
				  detect: [ :attribute | attribute name = attributeName ]
				  ifNone: [ self findAttributeWithSetterNamed: attributeName ] ]
]

{ #category : #'*Famix-Value-Importer' }
FamixTClass >> findAttributeWithSetterNamed: attributeName [
	"Useful when the serialized attribute's name does not exactly match the attribute name.
	I try to find the setter matching the former, then search for the attribute access."

	^ self allMethods
		  detect: [ :method |
			  method isSetter and: [
				  method name endsWith: attributeName caseSensitive: false ] ]
		  ifOne: [ :setter |
			  setter accesses
				  detect: [ :access | access variable isAttribute ]
				  ifOne: [ :access | access variable ] ]
]
