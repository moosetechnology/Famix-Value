Extension { #name : #FamixJavaMethod }

{ #category : #'*Famix-Value-Exporter' }
FamixJavaMethod >> isSetterLax [
	"Name begins with set AND
		Has 1 parameter AND
			Declared type is void"

	^ self kind = #setter or: [
		  self name isNotNil and: [
			  (self name beginsWith: 'set') and: [
				  self parameters size = 1 and: [
					  self declaredType isNotNil and: [
						  self declaredType name = 'void' ] ] ] ] ]
]
