Extension { #name : 'FamixJavaMethod' }

{ #category : '*Famix-Value-Importer' }
FamixJavaMethod >> isProcedure [

	^ declaredType name = 'void'
]
